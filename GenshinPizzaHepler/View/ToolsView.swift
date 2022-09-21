//
//  ToolsView.swift
//  GenshinPizzaHepler
//
//  Created by Bill Haku on 2022/9/17.
//

import SwiftUI

@available(iOS 15.0, *)
struct ToolsView: View {
    var body: some View {
        NavigationView {
            List {
                Section {
                    VStack {
                        HStack {
                            Text("我的角色")
                                .font(.footnote)
                            Spacer()
                        }
                        Divider()
                    }
                    .listRowSeparator(.hidden)
                    ScrollView(.horizontal) {
                        HStack {
                            Image(systemName: "safari")
                                .resizable()
                                .frame(width: 50, height: 50)
                            Image(systemName: "safari")
                                .resizable()
                                .frame(width: 50, height: 50)
                            Image(systemName: "safari")
                                .resizable()
                                .frame(width: 50, height: 50)
                        }
                        .padding()
                    }
                    .listRowInsets(.init(top: 0, leading: 0, bottom: 0, trailing: 0))
                }
                
                Section {
                    VStack {
                        HStack {
                            Text("第三方工具")
                                .font(.footnote)
                            Spacer()
                        }
                    }
                    Text("原神中日英词典")
                    Text("原神计算器")
                }

            }
            .navigationTitle("原神小工具")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}
