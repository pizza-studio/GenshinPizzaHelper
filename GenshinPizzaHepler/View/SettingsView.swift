//
//  SettingsView.swift
//  GenshinPizzaHepler
//
//  Created by Bill Haku on 2022/8/7.
//  设置View

import SwiftUI

struct SettingsView: View {
    @State var editMode: EditMode = .inactive

    @EnvironmentObject var viewModel: ViewModel
    var accounts: [Account] { viewModel.accounts }
    
    @State var isGameBlockAvailable: Bool = true

    @StateObject var storeManager: StoreManager

    var body: some View {
        NavigationView {
            List {
                Section {
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
                } header: {
                    HStack {
                        Text("我的帐号")
                        Spacer()
                        EditModeButton(editMode: $editMode)
                    }
                }
                // 通知设置
                NotificationSettingNavigator()
                Section {
                    Button("在App Store评分") {
                        ReviewHandler.requestReview()
                    }
                    NavigationLink(destination: GlobalDonateView(storeManager: storeManager)) {
                        Text("支持我们")
                    }
                }
                Section {
                    NavigationLink(destination: BackgroundsPreviewView()) {
                        Text("背景名片预览")
                    }
                }
                // 更多
                NavigationLink(destination: MoreView(storeManager: storeManager)) {
                    Text("更多")
                }
            }
            .environment(\.editMode, $editMode)
            .navigationTitle("设置")
        }
        .navigationViewStyle(.stack)
    }
}

private struct EditModeButton: View {
    @Binding var editMode: EditMode
    var body: some View {
        Button {
            withAnimation(.easeInOut(duration: 0.1)) {
                if editMode.isEditing {
                    editMode = .inactive
                } else {
                    editMode = .active
                }
            }
        } label: {
            if editMode.isEditing {
                Text("完成".localized)
            } else {
                Text("编辑".localized)
            }
        }
    }
}
