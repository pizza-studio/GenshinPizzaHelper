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
    var searchResults: [GDDictionary]? {
            if searchText.isEmpty || dictionaryData == nil {
                return dictionaryData?.sorted {
                    $0.id < $1.id
                }
            } else {
                return dictionaryData!.filter {
                    $0.en.contains(searchText) ||
                    ($0.zhCN != nil && $0.zhCN!.contains(searchText)) ||
                    ($0.ja != nil && $0.ja!.contains(searchText)) ||
                     ($0.variants != nil && (($0.variants!.en != nil && $0.variants!.en!.contains(searchText)) ||
                                             ($0.variants!.zhCN != nil && $0.variants!.zhCN!.contains(searchText)) ||
                                             ($0.variants!.ja != nil && $0.variants!.ja!.contains(searchText)))) ||
                    ($0.tags != nil && $0.tags!.contains(searchText))
                }
                .sorted {
                    $0.id < $1.id
                }
            }
        }

    var body: some View {
        if let searchResults = searchResults {
            List {
                ForEach(searchResults, id: \.id) { item in
                    dictionaryItemCell(word: item)
                }
            }
            .searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .always))
            .navigationTitle("原神中英日辞典")
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
