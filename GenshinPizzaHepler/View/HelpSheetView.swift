//
//  HelpSheetView.swift
//  GenshinPizzaHepler
//
//  Created by Bill Haku on 2022/8/8.
//

import SwiftUI

struct HelpSheetView: View {
    @Binding var sheet: SettingsViewSheetType?

    var body: some View {
        NavigationView {
            List {
                Section {
                    Link("获取Cookie的脚本", destination: URL(string: "https://www.icloud.com/shortcuts/fe68f22c624949c9ad8959993239e19c")!)
                }
                Section {
                    Button("在App Store评分") {
                        ReviewHandler.requestReview()
                    }
                    NavigationLink(destination: WebBroswerView(url: "http://zhuaiyuwen.xyz/static/donate.html").navigationTitle("支持我们")) {
                        Text("支持我们")
                    }
                }
                Section {
                    NavigationLink(destination: WebBroswerView(url: "http://zhuaiyuwen.xyz/static/policy.html").navigationTitle("用户协议")) {
                        Text("用户协议与免责声明")
                    }
                    NavigationLink(destination: AboutView()) {
                        Text("关于小助手")
                    }
                }
            }
            .navigationBarTitle("其他信息", displayMode: .inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("完成") {
                        sheet = nil
                    }
                }
            }
        }
    }
}
