//
//  SettingsView.swift
//  GenshinPizzaHepler
//
//  Created by Bill Haku on 2022/8/7.
//

import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var viewModel: ViewModel
    var accounts: [Account] { viewModel.accounts }
    
    @State var isGameBlockAvailable: Bool = true

    @StateObject var storeManager: StoreManager

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
                        Label("添加帐号", systemImage: "plus.circle")
                    }
                }
                // 通知设置
                NotificationSettingNavigator()
                Section {
                    NavigationLink(destination: BackgroundsPreviewView()) {
                        Text("背景名片预览")
                    }
                }
                // 更多
                NavigationLink(destination: HelpSheetView(storeManager: storeManager)) {
                    Text("更多")
                }
            }
            .navigationTitle("设置")
        }
        .navigationViewStyle(.stack)
    }
}


