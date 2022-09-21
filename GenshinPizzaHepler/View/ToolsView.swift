//
//  ToolsView.swift
//  GenshinPizzaHepler
//
//  Created by Bill Haku on 2022/9/17.
//

import SwiftUI

struct ToolsView: View {
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("我的角色")) {
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
                        .padding(.vertical)
                    }
                    .padding(.horizontal)
                    .listRowInsets(.init(top: 0, leading: 0, bottom: 0, trailing: 0))
                    .listRowBackground(Color(UIColor.secondarySystemBackground).opacity(0.6))
                }
                Section(header: Text("第三方工具")) {
                    Text("原神中日英词典")
                }
            }
            .listStyle(.plain)
            .navigationTitle("原神小工具")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}
