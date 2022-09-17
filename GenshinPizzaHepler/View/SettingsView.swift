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

    @State var isWidgetTipsSheetShow: Bool = false

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
                } footer: {
                    Button { isWidgetTipsSheetShow.toggle() } label: {
                        Text("如何添加、配置小组件和更换小组件背景？").multilineTextAlignment(.leading)
                            .font(.footnote)
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
                    NavigationLink(destination: GuideVideoLinkView()) {
                        Text("App介绍视频")
                    }
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
        .sheet(isPresented: $isWidgetTipsSheetShow) {
            WidgetTipsView(isSheetShow: $isWidgetTipsSheetShow)
        }
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
                Text("完成")
                    .font(.footnote)
            } else {
                Text("编辑")
                    .font(.footnote)
            }
        }
    }
}
