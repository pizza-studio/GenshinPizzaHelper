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
                return dictionaryData
            } else {
                return dictionaryData!.filter {
                    $0.en.contains(searchText) ||
                    ($0.zhCN != nil && $0.zhCN!.contains(searchText)) ||
                    ($0.ja != nil && $0.ja!.contains(searchText)) ||
                     ($0.variants != nil && (($0.variants!.en != nil && $0.variants!.en!.contains(searchText)) ||
                                             ($0.variants!.zhCN != nil && $0.variants!.zhCN!.contains(searchText)) ||
                                             ($0.variants!.ja != nil && $0.variants!.ja!.contains(searchText))))
                }
            }
        }

    var body: some View {
        if let dictionaryData = dictionaryData, let searchResults = searchResults {
            List {
                ForEach(searchResults, id: \.id) { item in
                    NavigationLink(destination: Text(item.id)) {
                        Text(item.en)
                    }
                }
            }
            .searchable(text: $searchText)
            .navigationTitle("Contacts")
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
}
