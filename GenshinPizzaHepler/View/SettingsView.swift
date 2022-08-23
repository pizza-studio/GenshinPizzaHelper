//
//  SettingsView.swift
//  GenshinPizzaHepler
//
//  Created by Bill Haku on 2022/8/7.
//

import SwiftUI
import WidgetKit

struct SettingsView: View {
    @EnvironmentObject var viewModel: ViewModel
    var accounts: [Account] { viewModel.accounts }

    @Environment(\.scenePhase) var scenePhase
    
    
//    @AppStorage("accountNum", store: UserDefaults(suiteName: "group.GenshinPizzaHelper")) var accountNum: Int = 0
//    @AppStorage("accountName", store: UserDefaults(suiteName: "group.GenshinPizzaHelper")) var s: String = ""
//    @AppStorage("uid", store: UserDefaults(suiteName: "group.GenshinPizzaHelper")) var uid: String = ""
//    @AppStorage("cookie", store: UserDefaults(suiteName: "group.GenshinPizzaHelper")) var cookie: String = ""
    
    @State var isGameBlockAvailable: Bool = true
    @State private var sheetType: SettingsViewSheetType? = nil

    var body: some View {
        NavigationView {
            List {
                Section(header: Text("我的帐号")) {
                    ForEach($viewModel.accounts, id: \.config.uuid) { $account in
                        NavigationLink(destination: AccountDetailView(account: $account)) {
                            AccountInfoView(accountConfig: $account.config)
                        }
                    }
                    .onDelete { indexSet in
                        indexSet.forEach { viewModel.deleteAccount(account: accounts[$0]) }
                    }
                    NavigationLink(destination: AddAccountView()) {
                        Label("添加帐户", systemImage: "plus.circle")
                    }
                }
                // TODO: 将检查用户协议改到ContentView去
                .onChange(of: scenePhase, perform: { newPhase in
                    switch newPhase {
                    case .active:
                        // 检查是否同意过用户协议
                        let isPolicyShown = UserDefaults.standard.bool(forKey: "isPolicyShown")
                        if !isPolicyShown {
                            sheetType = .userPolicy
                        }
                        viewModel.fetchAccount()
                        viewModel.refreshData()
                        UIApplication.shared.applicationIconBadgeNumber = 0
                    case .inactive:
                        WidgetCenter.shared.reloadAllTimelines()
                    default:
                        break
                    }
                })

                // 通知设置
                NotificationSettingNavigator()

                // 更多
                NavigationLink(destination: HelpSheetView()) {
                    Text("更多")
                }

            }
            .navigationTitle("设置")
            .toolbar {
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        withAnimation { viewModel.refreshData() }
                        print(accounts.first?.config.uid ?? "nil")
                        WidgetCenter.shared.reloadAllTimelines()
                    }) {
                        Image(systemName: "arrow.counterclockwise")
                    }
                }
                
            }
            .sheet(item: $sheetType) { item in
                switch item {
                case .userPolicy:
                    UserPolicyView(sheet: $sheetType)
                        .allowAutoDismiss(false)
                }
            }
            
        }
        .ignoresSafeArea()
        .navigationViewStyle(.stack)
    }
}

enum SettingsViewSheetType: Identifiable {
    var id: Int {
        hashValue
    }

    case userPolicy
}
