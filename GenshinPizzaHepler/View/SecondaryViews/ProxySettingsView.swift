//
//  ProxySettingsView.swift
//  GenshinPizzaHelper
//
//  Created by Bill Haku on 2022/9/5.
//

import Defaults
import SwiftUI

struct ReverseProxySettingsView: View {
    @Default(.useProxy)
    var useProxy: Bool
    @Default(.reverseProxyHost1)
    var reverseProxy1: String
    @Default(.reverseProxyHost2)
    var reverseProxy2: String
    @Default(.reverseProxyHost3)
    var reverseProxy3: String
    @Default(.reverseProxyHost4)
    var reverseProxy4: String
    @Default(.reverseProxyHost5)
    var reverseProxy5: String

    var body: some View {
        List {
            Section(header: Text(verbatim: "https://bbs-api-os.hoyolab.com/").textCase(.none)) {
                InfoEditor(
                    title: "settings.account.server",
                    content: $reverseProxy1,
                    placeholderText: "https://bbs-api-os.hoyolab.com/",
                    style: .vertical
                )
            }
            Section(header: Text(verbatim: "https://api-account-os.hoyolab.com/").textCase(.none)) {
                InfoEditor(
                    title: "settings.account.server",
                    content: $reverseProxy2,
                    placeholderText: "https://api-account-os.hoyolab.com/",
                    style: .vertical
                )
            }
            Section(header: Text(verbatim: "https://sg-hk4e-api.hoyolab.com/").textCase(.none)) {
                InfoEditor(
                    title: "settings.account.server",
                    content: $reverseProxy3,
                    placeholderText: "https://sg-hk4e-api.hoyolab.com/",
                    style: .vertical
                )
            }
            Section(header: Text(verbatim: "https://bbs-api-os.hoyoverse.com/").textCase(.none)) {
                InfoEditor(
                    title: "settings.account.server",
                    content: $reverseProxy4,
                    placeholderText: "https://bbs-api-os.hoyoverse.com/",
                    style: .vertical
                )
            }
            Section(header: Text(verbatim: "https://hk4e-api-os.hoyoverse.com/").textCase(.none)) {
                InfoEditor(
                    title: "settings.account.server",
                    content: $reverseProxy5,
                    placeholderText: "https://hk4e-api-os.hoyoverse.com/",
                    style: .vertical
                )
            }
        }
        .navigationTitle("settings.reverseProxy.navTitle")
    }
}
