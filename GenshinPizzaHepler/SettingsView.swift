//
//  SettingsView.swift
//  GenshinPizzaHepler
//
//  Created by Bill Haku on 2022/8/7.
//

import SwiftUI

struct SettingsView: View {
    @StateObject var viewModel = ViewModel()
    @AppStorage("accountNum", store: UserDefaults(suiteName: "group.GenshinPizzaHelper")) var accountNum: Int = 0
    @AppStorage("accountName", store: UserDefaults(suiteName: "group.GenshinPizzaHelper")) var accountName: String = ""
    @AppStorage("uid", store: UserDefaults(suiteName: "group.GenshinPizzaHelper")) var uid: String = ""
    @AppStorage("cookie", store: UserDefaults(suiteName: "group.GenshinPizzaHelper")) var cookie: String = ""
    @AppStorage("server", store: UserDefaults(suiteName: "group.GenshinPizzaHelper")) var server: Server = .china

    var body: some View {
        NavigationView {
            List {
                Section (header: Text("帐号")) {
                    if accountNum != 1 {
                        NavigationLink(destination: AddAccountView()) {
                            Label("添加帐户", systemImage: "plus.circle")
                        }
                    } else {
                        NavigationLink(destination: AccountDetailView()) {
                            AccountInfoView(accountName: accountName, uid: uid,region: server.region.value, serverName: server.rawValue)
                        }
//                        Label("添加帐户", systemImage: "plus.circle")
                    }
                }
                .onAppear {
                    if uid != "" && cookie != "" {
                        accountNum = 1
                    }
                }
            }
            .navigationTitle("设置")
        }
        .ignoresSafeArea()
        .navigationViewStyle(.stack)
    }
}
