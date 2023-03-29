//
//  SettingsView.swift
//  GenshinPizzaHepler
//
//  Created by Bill Haku on 2022/8/7.
//  设置View

import SwiftUI

// MARK: - SettingsView

struct SettingsView: View {
    @State
    var editMode: EditMode = .inactive

    @EnvironmentObject
    var viewModel: ViewModel
    @State
    var isGameBlockAvailable: Bool = true

    @StateObject
    var storeManager: StoreManager

    @State
    var isWidgetTipsSheetShow: Bool = false

    var accounts: [Account] { viewModel.accounts }

    var body: some View {
        NavigationView {
            List {
                Section {
                    ForEach(
                        $viewModel.accounts,
                        id: \.config.uuid
                    ) { $account in
                        NavigationLink(
                            destination: AccountDetailView(account: $account)
                        ) {
                            AccountInfoView(account: account)
                        }
                    }
                    .onDelete { indexSet in
                        indexSet
                            .forEach {
                                viewModel.deleteAccount(account: accounts[$0])
                            }
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
                        Text("使用小组件遇到了问题？")
                            .multilineTextAlignment(.leading)
                            .font(.footnote)
                    }
                }

                Section {
                    let url: String = {
                        switch Bundle.main.preferredLocalizations.first {
                        case "zh-Hans", "zh-Hant", "zh-HK":
                            return "https://ophelper.top/static/faq.html"
                        default:
                            return "https://ophelper.top/static/faq_en.html"
                        }
                    }()
                    NavigationLink(
                        destination: WebBroswerView(url: url)
                            .navigationTitle("FAQ")
                            .navigationBarTitleDisplayMode(.inline)
                    ) {
                        Label(
                            "常见使用问题（FAQ）",
                            systemImage: "person.fill.questionmark"
                        )
                    }
                    #if DEBUG
                        Button("debug") {
                            UserNotificationCenter.shared
                                .printAllNotificationRequest()
                        }
                    #endif
                }

                NavigationLink(destination: DisplayOptionsView()) {
                    Label {
                        Text("界面偏好设置")
                    } icon: {
                        Image(systemName: "uiwindow.split.2x1")
                    }
                }

                // 小组件相关设置
                NavigationLink("小组件设置", destination: { WidgetSettingView() })

                // 通知设置
                NotificationSettingNavigator()

                #if canImport(ActivityKit)
                    LiveActivitySettingView()
                #endif

                Section {
                    Button("在App Store评分") {
                        ReviewHandler.requestReview()
                    }
                    NavigationLink(
                        destination: GlobalDonateView(
                            storeManager: storeManager
                        )
                    ) {
                        Text("支持我们")
                    }
                }

                Group {
                    Section {
                        NavigationLink("隐私设置") {
                            PrivacySettingsView()
                        }
                    }
                }

                Section {
                    NavigationLink(destination: GuideVideoLinkView()) {
                        Text("App介绍视频")
                    }
                    NavigationLink(destination: ContactUsView()) {
                        Text("开发者与联系方式")
                    }
                }
                // 更多
                NavigationLink(destination: MoreView()) {
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

// MARK: - EditModeButton

private struct EditModeButton: View {
    @Binding
    var editMode: EditMode

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
