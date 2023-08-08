//
//  ProxySettingsView.swift
//  GenshinPizzaHelper
//
//  Created by Bill Haku on 2022/9/5.
//

import SwiftUI

struct ReverseProxySettingsView: View {
    @AppStorage(
        "useProxy",
        store: UserDefaults(suiteName: "group.GenshinPizzaHelper")
    )
    var useProxy: Bool = false
    @AppStorage(
        "reverseProxyHost1",
        store: UserDefaults(suiteName: "group.GenshinPizzaHelper")
    )
    var reverseProxy1: String = ""
    @AppStorage(
        "reverseProxyHost2",
        store: UserDefaults(suiteName: "group.GenshinPizzaHelper")
    )
    var reverseProxy2: String = ""
    @AppStorage(
        "reverseProxyHost3",
        store: UserDefaults(suiteName: "group.GenshinPizzaHelper")
    )
    var reverseProxy3: String = ""
    @AppStorage(
        "reverseProxyHost4",
        store: UserDefaults(suiteName: "group.GenshinPizzaHelper")
    )
    var reverseProxy4: String = ""
    @AppStorage(
        "reverseProxyHost5",
        store: UserDefaults(suiteName: "group.GenshinPizzaHelper")
    )
    var reverseProxy5: String = ""

    var body: some View {
        List {
            Section(header: Text("https://bbs-api-os.hoyolab.com/").textCase(.none)) {
                InfoEditor(
                    title: "服务器",
                    content: $reverseProxy1,
                    placeholderText: "https://bbs-api-os.hoyolab.com/",
                    style: .vertical
                )
            }
            Section(header: Text("https://api-account-os.hoyolab.com/").textCase(.none)) {
                InfoEditor(
                    title: "服务器",
                    content: $reverseProxy2,
                    placeholderText: "https://api-account-os.hoyolab.com/",
                    style: .vertical
                )
            }
            Section(header: Text("https://sg-hk4e-api.hoyolab.com/").textCase(.none)) {
                InfoEditor(
                    title: "服务器",
                    content: $reverseProxy3,
                    placeholderText: "https://sg-hk4e-api.hoyolab.com/",
                    style: .vertical
                )
            }
            Section(header: Text("https://bbs-api-os.hoyoverse.com/").textCase(.none)) {
                InfoEditor(
                    title: "服务器",
                    content: $reverseProxy4,
                    placeholderText: "https://bbs-api-os.hoyoverse.com/",
                    style: .vertical
                )
            }
            Section(header: Text("https://hk4e-api-os.hoyoverse.com/").textCase(.none)) {
                InfoEditor(
                    title: "服务器",
                    content: $reverseProxy5,
                    placeholderText: "https://hk4e-api-os.hoyoverse.com/",
                    style: .vertical
                )
            }
        }
        .navigationTitle("反向代理设置")
    }
}
