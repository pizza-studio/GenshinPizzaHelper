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
    @State var isHelpSheepShow: Bool = false
    @State var isGameBlockAvailable: Bool = true

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
                    API.Features.fetchInfos(region: server.region, serverID: server.id, uid: uid, cookie: cookie) { retCode, data, _ in
                        isGameBlockAvailable = retCode == 0
                        userData = data?.data
                    }
                    if uid != "" && cookie != "" {
                        accountNum = 1
                        let _ = viewModel.get_data(uid: uid, server_id: server.id, cookie: cookie, region: server.region)
                        WidgetCenter.shared.reloadAllTimelines()
                    }
                }
                if accountNum >= 1 {
                    Section {
                        if !isGameBlockAvailable {
                            HStack {
                                Spacer()
                                Image(systemName: "exclamationmark.arrow.triangle.2.circlepath")
                                    .foregroundColor(.red)
                                Spacer()
                            }
                        } else {
                            GameInfoBlock(userData: userData)
                                .listRowInsets(.init(top: 0, leading: 0, bottom: 0, trailing: 0))
                                .animation(.linear)
                        }
                    }
                }
            }
            .navigationTitle("原神披萨小助手")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        let _ = viewModel.get_data(uid: uid, server_id: server.id, cookie: cookie, region: server.region)
                        userData = nil
                        API.Features.fetchInfos(region: server.region, serverID: server.id, uid: uid, cookie: cookie) { retCode, data, _ in
                            isGameBlockAvailable = retCode == 0
                            userData = data?.data
                        }
                        WidgetCenter.shared.reloadAllTimelines()
                    }) {
                        Image(systemName: "arrow.counterclockwise")
                    }
                }
                ToolbarItemGroup(placement: .bottomBar) {
                    Button(action: {
                        isHelpSheepShow.toggle()
                    }) {
                        Image(systemName: "info.circle")
                    }
                    Spacer()
                }
            }
            .sheet(isPresented: $isHelpSheepShow) {
                HelpSheetView(isShow: $isHelpSheepShow)
            }
        }
        .ignoresSafeArea()
        .navigationViewStyle(.stack)
    }
}
