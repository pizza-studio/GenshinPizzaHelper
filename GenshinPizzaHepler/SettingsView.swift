//
//  SettingsView.swift
//  GenshinPizzaHepler
//
//  Created by Bill Haku on 2022/8/7.
//

import SwiftUI

struct SettingsView: View {
    @StateObject var viewModel = ViewModel()
    @AppStorage("accountName", store: UserDefaults(suiteName: "group.GenshinPizzaHelper")) var accountName: String?
    @AppStorage("uid", store: UserDefaults(suiteName: "group.GenshinPizzaHelper")) var uid: String?
    @AppStorage("cookie", store: UserDefaults(suiteName: "group.GenshinPizzaHelper")) var cookie: String?
    @AppStorage("server", store: UserDefaults(suiteName: "group.GenshinPizzaHelper")) var server: Server = .china

    var body: some View {
        NavigationView {
            List {
                Section (header: Text("帐户")) {
                    NavigationLink(destination: AccountDetailView()) {
                        AccountInfoView(accountName: accountName ?? uid ?? "0", uid: uid ?? "0", serverName: server.rawValue)
                    }
                }
            }
            .navigationTitle("设置")
        }
        .ignoresSafeArea()
        .navigationViewStyle(.stack)
    }
}
