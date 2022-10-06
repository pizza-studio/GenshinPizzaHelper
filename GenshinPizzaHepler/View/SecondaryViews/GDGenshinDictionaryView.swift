//
//  GDGenshinDictionaryView.swift
//  GenshinPizzaHelper
//
//  Created by Bill Haku on 2022/10/3.
//

import SwiftUI

@available (iOS 15, *)
struct GenshinDictionary: View {
    @State var dictionaryData: [GDDictionary]?
    @State private var searchText: String = ""
    @State private var showSafari: Bool = false
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
                    ($0.variants != nil && (($0.variants!.en != nil && $0.variants!.en!.contains(where: {$0.caseInsensitiveCompare(searchText) == .orderedSame})) ||
                                             ($0.variants!.zhCN != nil && $0.variants!.zhCN!.contains(searchText)) ||
                                             ($0.variants!.ja != nil && $0.variants!.ja!.contains(searchText)))) ||
                    ($0.tags != nil && $0.tags!.contains(where: {$0.caseInsensitiveCompare(searchText) == .orderedSame}))
                }
                .sorted {
                    $0.id < $1.id
                }
            }
        }

    var body: some View {
        if let searchResults = searchResults, let dictionaryData = dictionaryData {
            List {
                Section {
                    ForEach(searchResults, id: \.id) { item in
                        dictionaryItemCell(word: item)
                            .contextMenu {
                                Button("复制英语") {
                                    UIPasteboard.general.string = item.en
                                }
                                if let zhcn = item.zhCN {
                                    Button("复制中文") {
                                        UIPasteboard.general.string = zhcn
                                    }
                                }
                                if let ja = item.ja {
                                    Button("复制日语") {
                                        UIPasteboard.general.string = ja
                                    }
                                }
                            }
                    }
                } header: {
                    VStack(alignment: .leading) {
                        Text("以下内容由「原神中英日辞典」提供")
                        Text("当前共收录\(dictionaryData.count)条原神专有词汇")
                    }
                }
            }
            .searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .always), prompt: "支持易错字、简写和英文标签")
            .navigationTitle("原神中英日辞典")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showSafari.toggle()
                    }) {
                        Image(systemName: "safari")
                    }
                }
            }
            .fullScreenCover(isPresented: $showSafari, content: {
                SFSafariViewWrapper(url: URL(string: "https://genshin-dictionary.com/")!)
                    .ignoresSafeArea()
            })
        } else {
            ProgressView()
                .onAppear {
                    DispatchQueue.global().async {
                        API.OpenAPIs.fetchGenshinDictionaryData() { result in
                            self.dictionaryData = result
                        }
                    }
                }
        }
    }

    @ViewBuilder
    func dictionaryItemCell(word: GDDictionary) -> some View {
        VStack(alignment: .leading) {
            Text("**英语** \(word.en)")
            if let zhcn = word.zhCN {
                Text("**中文** \(zhcn)")
            }
            if let ja = word.ja {
                if let jaPron = word.pronunciationJa {
                    Text("**日语** \(ja)") + Text(" (\(jaPron))").font(.footnote)
                } else {
                    Text("**日语** \(ja)")
                }
            }
        }
    }
}
