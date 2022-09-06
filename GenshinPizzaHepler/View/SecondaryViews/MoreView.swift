//
//  HelpSheetView.swift
//  GenshinPizzaHepler
//
//  Created by Bill Haku on 2022/8/8.
//  更多页面

import SwiftUI

struct MoreView: View {
    @EnvironmentObject var viewModel: ViewModel
    let localeID = Locale.current.identifier

    @StateObject var storeManager: StoreManager

    var body: some View {
        List {
            Section {
                Link("获取Cookie的脚本", destination: URL(string: "https://www.icloud.com/shortcuts/fe68f22c624949c9ad8959993239e19c")!)
            }
            Section {
                NavigationLink(destination: ProxySettingsView()) {
                    Text("代理设置")
                }
            }
            Section {
                NavigationLink(destination: WebBroswerView(url: "http://zhuaiyuwen.xyz/static/faq.html").navigationTitle("FAQ")) {
                    Text("常见使用问题（FAQ）")
                }
                NavigationLink(destination: WebBroswerView(url: "http://zhuaiyuwen.xyz/static/policy.html").navigationTitle("用户协议")) {
                    Text("用户协议与免责声明")
                }
                NavigationLink(destination: ContactUsView()) {
                    Text("开发者与联系方式")
                }
                NavigationLink(destination: AboutView()) {
                    Text("关于小助手")
                }
            }
        }
        .navigationBarTitle("更多", displayMode: .inline)
    }
}
