//
//  SettingsView.swift
//  GenshinPizzaHepler
//
//  Created by Bill Haku on 2022/8/7.
//  设置View

import AlertToast
import SwiftUI

// MARK: - SettingsView

struct SettingsView: View {
    @EnvironmentObject
    var viewModel: ViewModel

    @StateObject
    var storeManager: StoreManager

    @State
    var isAlertToastShown = false

    var body: some View {
        NavigationView {
            List {
                Section {
                    NavigationLink(
                        destination: AccountManagementView().environmentObject(viewModel)
                    ) {
                        Label(
                            "settings.account.myAccount",
                            systemImage: "person.fill"
                        )
                    }
                }
                Section {
                    let url: String = {
                        switch Bundle.main.preferredLocalizations.first {
                        case "zh-Hans", "zh-Hant", "zh-HK":
                            return "https://gi.pizzastudio.org/static/faq.html"
                        default:
                            return "https://gi.pizzastudio.org/static/faq_en.html"
                        }
                    }()
                    NavigationLink(
                        destination: WebBroswerView(url: url)
                            .navigationTitle("FAQ")
                            .navigationBarTitleDisplayMode(.inline)
                    ) {
                        Label(
                            "settings.misc.FAQ",
                            systemImage: "person.fill.questionmark"
                        )
                    }
                    NavigationLink(
                        destination: ThirdPartyToolsView()
                            .environmentObject(viewModel)
                            .navigationTitle("旅行工具")
                            .navigationBarTitleDisplayMode(.inline)
                    ) {
                        Label(
                            "旅行工具",
                            systemImage: "shippingbox.fill"
                        )
                    }
                }

                Section {
                    // 该功能对 macCatalyst 无效。
                    Button {
                        UIApplication.shared
                            .open(URL(
                                string: UIApplication
                                    .openSettingsURLString
                            )!)
                    } label: {
                        Label {
                            Text("偏好语言")
                                .foregroundColor(.primary)
                        } icon: {
                            Image(systemName: "globe")
                        }
                    }
                    NavigationLink(destination: DisplayOptionsView()) {
                        Label(
                            "settings.display.title",
                            systemImage: "uiwindow.split.2x1"
                        )
                    }
                    NavigationLink(destination: WidgetSettingView()) {
                        Label(
                            "小组件设置",
                            systemImage: "speedometer"
                        )
                    }
                }

                // 通知设置
                NotificationSettingNavigator()

                #if canImport(ActivityKit)
                LiveActivitySettingView()
                #endif

                Section {
                    Button("settings.misc.rateMeOnAppStore") {
                        ReviewHandler.requestReviewIfNotRequestedElseNavigateToAppStore()
                    }
                    NavigationLink(
                        destination: GlobalDonateView(
                            storeManager: storeManager
                        )
                    ) {
                        Text("settings.misc.supportUs")
                    }
                }

                Group {
                    Section {
                        NavigationLink("隐私设置") {
                            PrivacySettingsView()
                        }
                        NavigationLink("祈愿数据管理") {
                            GachaSetting()
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

                Section {
                    // 更多
                    NavigationLink(destination: MoreView()) {
                        Text("settings.more")
                    }
                    #if DEBUG
                    Button("Alert Toast Debug") {
                        //                        UserNotificationCenter.shared
                        //                            .printAllNotificationRequest()
                        isAlertToastShown.toggle()
                    }
                    #endif
                }
            }
            .sectionSpacing(UIFont.systemFontSize)
            .navigationTitle("nav.category.settings.name")
            DisplayOptionsView() // 预设内容页
        }
        .navigationViewStyle(.columns)
        .toast(isPresenting: $isAlertToastShown) {
            AlertToast(
                displayMode: .hud,
                type: .complete(.green),
                title: "Complete"
            )
        }
    }
}
