//
//  ProxySettingsView.swift
//  GenshinPizzaHelper
//
//  Created by Bill Haku on 2022/9/5.
//

import SwiftUI

struct ProxySettingsView: View {
    @AppStorage("useProxy", store: UserDefaults(suiteName: "group.GenshinPizzaHelper")) var useProxy: Bool = false
    @AppStorage("proxyHost", store: UserDefaults(suiteName: "group.GenshinPizzaHelper")) var proxyHost: String = ""
    @AppStorage("proxyPort", store: UserDefaults(suiteName: "group.GenshinPizzaHelper")) var proxyPort: String = ""

    var body: some View {
        List {
            Section {
                Toggle("启用代理", isOn: $useProxy)
            }
            Section (header: Text("代理配置")) {
                InfoEditor(title: "服务器", content: $proxyHost)
                InfoEditor(title: "端口", content: $proxyPort, keyboardType: .numberPad)
            }
        }
        .navigationTitle("代理设置")
    }
}
