//
//  GDGenshinDictionaryView.swift
//  GenshinPizzaHelper
//
//  Created by Bill Haku on 2022/10/3.
//

import GIPizzaKit
import HBMihoyoAPI
import SFSafeSymbols
import SwiftUI

@available(iOS 15, *)
struct GenshinDictionary: View {
    @State
    var dictionaryData: [GDDictionary]?
    @State
    private var searchText: String = ""
    @State
    private var showSafari: Bool = false
    @State
    private var showInfoSheet: Bool = false
    var searchResults: [GDDictionary]? {
        if searchText.isEmpty || dictionaryData == nil {
            return dictionaryData?.sorted {
                $0.id < $1.id
            }
        } else {
            return dictionaryData!.filter {
                $0.en.localizedCaseInsensitiveContains(searchText) ||
                    ($0.zhCN != nil && $0.zhCN!.contains(searchText)) ||
                    ($0.ja != nil && $0.ja!.contains(searchText)) ||
                    (
                        $0
                            .variants != nil &&
                            (
                                (
                                    $0.variants!.en != nil && $0.variants!.en!
                                        .contains(where: {
                                            $0
                                                .caseInsensitiveCompare(
                                                    searchText
                                                ) ==
                                                .orderedSame
                                        })
                                ) ||
                                    (
                                        $0.variants!.zhCN != nil && $0
                                            .variants!.zhCN!
                                            .contains(searchText)
                                    ) ||
                                    (
                                        $0.variants!.ja != nil && $0
                                            .variants!.ja!
                                            .contains(searchText)
                                    )
                            )
                    ) ||
                    (
                        $0.tags != nil && $0.tags!
                            .contains(where: {
                                $0
                                    .caseInsensitiveCompare(searchText) ==
                                    .orderedSame
                            })
                    )
            }
            .sorted {
                $0.id < $1.id
            }
        }
    }

    let alphabet = [
        "A",
        "B",
        "C",
        "D",
        "E",
        "F",
        "G",
        "H",
        "I",
        "J",
        "K",
        "L",
        "M",
        "N",
        "O",
        "P",
        "Q",
        "R",
        "S",
        "T",
        "U",
        "V",
        "W",
        "X",
        "Y",
        "Z",
    ]

    func checkLetterInSearchResults(_ letter: String) -> Bool {
        let searchResults = searchResults ?? []
        return searchResults.filter { $0.id.hasPrefix(letter.lowercased()) }
            .isEmpty
    }

    var body: some View {
        if let searchResults = searchResults,
           let dictionaryData = dictionaryData {
            ScrollViewReader { value in
                List {
                    ForEach(alphabet, id: \.self) { letter in
                        if !checkLetterInSearchResults(letter) {
                            Section(header: Text(letter)) {
                                ForEach(
                                    searchResults
                                        .filter {
                                            $0.id
                                                .hasPrefix(
                                                    letter
                                                        .lowercased()
                                                )
                                        },
                                    id: \.id
                                ) { item in
                                    dictionaryItemCell(word: item)
                                        .id(item.id)
                                        .contextMenu {
                                            Button("app.dictionary.copy.en") {
                                                UIPasteboard.general
                                                    .string = item.en
                                            }
                                            if let zhcn = item.zhCN {
                                                Button("app.dictionary.copy.zh") {
                                                    UIPasteboard.general
                                                        .string = zhcn
                                                }
                                            }
                                            if let ja = item.ja {
                                                Button("app.dictionary.copy.ja") {
                                                    UIPasteboard.general
                                                        .string = ja
                                                }
                                            }
                                        }
                                }
                            }.id(letter)
                        }
                    }
                }
                .searchable(
                    text: $searchText,
                    placement: .navigationBarDrawer(displayMode: .always),
                    prompt: "app.dictionary.tip.search"
                )
                .overlay(alignment: .trailing) {
                    if searchText.isEmpty {
                        VStack(spacing: 5) {
                            ForEach(0 ..< alphabet.count, id: \.self) { idx in
                                Button(action: {
                                    withAnimation {
                                        value.scrollTo(
                                            alphabet[idx],
                                            anchor: .top
                                        )
                                    }
                                }, label: {
                                    Text(alphabet[idx])
                                        .font(.footnote)
                                })
                            }
                        }
                    }
                }
            }
            .navigationTitle("tools.dictionary.title")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItemGroup(placement: .navigationBarTrailing) {
                    Button(action: {
                        showInfoSheet.toggle()
                    }) {
                        Image(systemSymbol: .infoCircle)
                    }
                    Button(action: {
                        showSafari.toggle()
                    }) {
                        Image(systemSymbol: .safari)
                    }
                }
            }
            .fullScreenCover(isPresented: $showSafari, content: {
                SFSafariViewWrapper(
                    url: URL(string: "https://genshin-dictionary.com/")!
                )
                .ignoresSafeArea()
            })
            .sheet(isPresented: $showInfoSheet) {
                NavigationStack {
                    VStack(alignment: .leading) {
                        Text("app.dictionary.tip.info")
                        Text(String(format: "app.dictionary.tip.count:%lld", dictionaryData.count))
                        Text("app.dictionary.tip.contact")
                        Spacer()
                    }
                    .padding(.horizontal)
                    .multilineTextAlignment(.leading)
                    .navigationBarTitle("app.dictionary.about.title")
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .navigationBarTrailing) {
                            Button(action: {
                                showInfoSheet.toggle()
                            }) {
                                Text("sys.done")
                            }
                        }
                    }
                }
            }
        } else {
            ProgressView().navigationTitle("tools.dictionary.title")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(action: {
                            showSafari.toggle()
                        }) {
                            Image(systemSymbol: .safari)
                        }
                    }
                }
                .fullScreenCover(isPresented: $showSafari, content: {
                    SFSafariViewWrapper(
                        url: URL(string: "https://genshin-dictionary.com/")!
                    )
                    .ignoresSafeArea()
                })
                .onAppear {
                    DispatchQueue.global().async {
                        API.OpenAPIs.fetchGenshinDictionaryData { result in
                            dictionaryData = result
                        }
                    }
                }
        }
    }

    @ViewBuilder
    func dictionaryItemCell(word: GDDictionary) -> some View {
        VStack(alignment: .leading) {
            Text(DictLang.en.i18nHeader).bold() + Text(word.en)
            if let zhcn = word.zhCN {
                Text(DictLang.zh.i18nHeader).bold() + Text(zhcn)
            }
            if let ja = word.ja {
                if let jaPron = word.pronunciationJa {
                    Text(DictLang.ja.i18nHeader).bold() + Text(ja) + Text(" (\(jaPron))")
                        .font(.footnote)
                } else {
                    Text(DictLang.ja.i18nHeader).bold()
                }
            }
            if let tags = word.tags {
                ScrollView(.horizontal) {
                    HStack(spacing: 3) {
                        ForEach(tags, id: \.self) { tag in
                            Text(tag)
                                .font(.footnote)
                                .foregroundColor(.white)
                                .padding(.horizontal, 6)
                                .background(
                                    Capsule()
                                        .fill(.blue)
                                        .frame(height: 15)
                                        .frame(maxWidth: 100)
                                )
                        }
                    }
                }
                .padding(.top, -5)
            }
        }
    }

    private enum DictLang {
        case en
        case zh
        case ja

        // MARK: Internal

        var i18nHeader: String {
            switch self {
            case .en: return "app.dictionary.content.en.header".localized
            case .zh: return "app.dictionary.content.zh.header".localized
            case .ja: return "app.dictionary.content.ja.header".localized
            }
        }
    }
}
