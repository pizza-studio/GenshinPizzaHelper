//
//  ProxySettingsView.swift
//  GenshinPizzaHelper
//
//  Created by Bill Haku on 2022/9/5.
//

import SwiftUI

struct ProxySettingsView: View {
    @AppStorage("useProxy", store: UserDefaults(suiteName: "group.GenshinPizzaHelper")) var useProxy: Bool = false

    var body: some View {
        List {
            Section {
                Toggle("启用代理", isOn: $useProxy)
            }
        }
        .navigationTitle("代理设置")
    }
}
