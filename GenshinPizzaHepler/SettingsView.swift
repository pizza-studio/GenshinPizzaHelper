//
//  SettingsView.swift
//  GenshinPizzaHepler
//
//  Created by Bill Haku on 2022/8/7.
//

import SwiftUI
import WidgetKit

struct SettingsView: View {
    @StateObject var viewModel = ViewModel()
    @AppStorage("accountNum", store: UserDefaults(suiteName: "group.GenshinPizzaHelper")) var accountNum: Int = 0
    @AppStorage("accountName", store: UserDefaults(suiteName: "group.GenshinPizzaHelper")) var accountName: String = ""
    @AppStorage("uid", store: UserDefaults(suiteName: "group.GenshinPizzaHelper")) var uid: String = ""
    @AppStorage("cookie", store: UserDefaults(suiteName: "group.GenshinPizzaHelper")) var cookie: String = ""
    @AppStorage("server", store: UserDefaults(suiteName: "group.GenshinPizzaHelper")) var server: Server = .china

    @State var userData: UserData? = nil

    var body: some View {
        NavigationView {
            List {
                Section (header: Text("我的帐号")) {
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
                    API.Features.fetchInfos(region: server.region, serverID: server.id, uid: uid, cookie: cookie) { _, data, _ in
                        userData = data?.data
                    }
                    if uid != "" && cookie != "" {
                        accountNum = 1
                        let _ = viewModel.get_data(uid: uid, server_id: server.id, cookie: cookie, region: server.region)
                        WidgetCenter.shared.reloadAllTimelines()
                    }
                }
                if userData != nil {
                    Section {
                        GameInfoBlock(userData: userData!)
                            .listRowInsets(.init(top: 0, leading: 0, bottom: 0, trailing: 0))
                    }
                }
            }
            .navigationTitle("原神披萨小助手")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        let _ = viewModel.get_data(uid: uid, server_id: server.id, cookie: cookie, region: server.region)
                        WidgetCenter.shared.reloadAllTimelines()
                    }) {
                        Image(systemName: "arrow.counterclockwise")
                    }
                }
            }
        }
        .ignoresSafeArea()
        .navigationViewStyle(.stack)
    }
}
