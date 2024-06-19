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

// MARK: - GenshinDictionary

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
            return dictionaryData?.sorted { $0.id < $1.id }
        } else if let dictionaryData {
            return dictionaryData.filter {
                $0.contains(target: searchText)
            }
            .sorted {
                $0.id < $1.id
            }
        } else {
            return nil
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

    var body: some View {
        let hasResults = searchResults?.isEmpty ?? false
        if hasResults, let dictionaryData {
            ScrollViewReader { value in
                renderScrollViewContent()
                    .overlay(alignment: .trailing) {
                        if searchText.isEmpty {
                            VStack(spacing: 5) {
                                ForEach(0 ..< alphabet.count, id: \.self) { idx in
                                    Button(action: {
                                        withAnimation {
                                            value.scrollTo(alphabet[idx], anchor: .top)
                                        }
                                    }, label: {
                                        Text(alphabet[idx]).font(.footnote)
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
                    Button {
                        showInfoSheet.toggle()
                    } label: {
                        Image(systemSymbol: .infoCircle)
                    }
                    Button {
                        showSafari.toggle()
                    } label: {
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
                infoSheet(dataCount: dictionaryData.count)
            }
        } else {
            ProgressView().navigationTitle("tools.dictionary.title")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button {
                            showSafari.toggle()
                        } label: {
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
                let header = Text(DictLang.ja.i18nHeader).bold()
                if let jaPron = word.pronunciationJa {
                    header + Text(ja) + Text(" (\(jaPron))")
                        .font(.footnote)
                } else {
                    header
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

    private func checkLetterInSearchResults(_ letter: String) -> [GDDictionary] {
        searchResults?.filter { $0.id.hasPrefix(letter.lowercased()) } ?? []
    }

    @ViewBuilder
    private func infoSheet(dataCount: Int) -> some View {
        NavigationStack {
            VStack(alignment: .leading) {
                Text("app.dictionary.tip.info")
                Text(String(format: "app.dictionary.tip.count:%lld", dataCount))
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

    @ViewBuilder
    private func renderScrollViewContent() -> some View {
        List {
            ForEach(alphabet, id: \.self) { letter in
                renderEachSearchResult(byLetter: letter)
            }
        }
        .searchable(
            text: $searchText,
            placement: .navigationBarDrawer(displayMode: .always),
            prompt: "app.dictionary.tip.search"
        )
    }

    @ViewBuilder
    private func renderEachSearchResult(byLetter letter: String) -> some View {
        let matchedResults = checkLetterInSearchResults(letter)
        if !matchedResults.isEmpty {
            Section(header: Text(letter)) {
                ForEach(matchedResults) { item in
                    dictionaryItemCell(word: item)
                        .id(item.id)
                        .contextMenu {
                            Button("app.dictionary.copy.en") {
                                UIPasteboard.general.string = item.en
                            }
                            if let zhcn = item.zhCN {
                                Button("app.dictionary.copy.zh") {
                                    UIPasteboard.general.string = zhcn
                                }
                            }
                            if let ja = item.ja {
                                Button("app.dictionary.copy.ja") {
                                    UIPasteboard.general.string = ja
                                }
                            }
                        }
                }
            }.id(letter)
        }
    }
}

extension GDDictionary {
    public func contains(target: String) -> Bool {
        guard !baseDataContains(target) else { return true }
        guard !variantDataContains(target) else { return true }
        guard !tagContains(target) else { return true }
        return false
    }

    private func baseDataContains(_ target: String) -> Bool {
        [en, zhCN, ja].compactMap { $0?.localizedCaseInsensitiveContains(target) }.contains(true)
    }

    private func variantDataContains(_ target: String) -> Bool {
        guard let variants = variants else { return false }
        let allVariants: [String] = [variants.en, variants.zhCN, variants.ja].compactMap { $0 }.reduce([], +)
        for variant in allVariants {
            if variant.localizedCaseInsensitiveContains(target) {
                return true
            }
        }
        return false
    }

    private func tagContains(_ target: String) -> Bool {
        tags?.contains { $0.caseInsensitiveCompare(target) == .orderedSame } ?? false
    }
}
