//
//  SettingsView.swift
//  GenshinPizzaHepler
//
//  Created by Bill Haku on 2022/8/7.
//  设置View

import AlertToast
import SFSafeSymbols
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
        Group {
            if #available(iOS 16, *) {
                NavigationSplitView {
                    navList
                } detail: {
                    DisplayOptionsView() // 预设内容页
                }
            } else {
                NavigationView {
                    navList
                    DisplayOptionsView() // 预设内容页
                }
            }
        }
        #if DEBUG
            .toast(isPresenting: $isAlertToastShown) {
                AlertToast(
                    displayMode: .hud,
                    type: .complete(.green),
                    title: "Complete"
                )
            }
        #endif
    }

    @ViewBuilder
    var navList: some View {
        List {
            Section {
                NavigationLink(
                    destination: AccountManagementView().environmentObject(viewModel)
                ) {
                    Label(
                        "settings.account.myAccount",
                        systemSymbol: .personFill
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
                        systemSymbol: .personFillQuestionmark
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
                        systemSymbol: .shippingboxFill
                    )
                }
            }

            Section {
                // 该功能对 macCatalyst 无效。
                if OS.type != .macOS {
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
                            Image(systemSymbol: .globe)
                        }
                    }
                }
                NavigationLink(destination: DisplayOptionsView()) {
                    Label(
                        "settings.display.title",
                        systemSymbol: .pc
                    )
                }
                NavigationLink(destination: WidgetSettingView()) {
                    Label(
                        "小组件设置",
                        systemSymbol: .speedometer
                    )
                }
            }

            // 通知设置
            NotificationSettingNavigator()

            #if canImport(ActivityKit)
            LiveActivitySettingView()
            #endif

            Section {
                Button {
                    ReviewHandler.requestReviewIfNotRequestedElseNavigateToAppStore()
                } label: {
                    Label("settings.misc.rateMeOnAppStore", systemSymbol: .arrowUpForwardApp)
                }
                NavigationLink(
                    destination: GlobalDonateView(
                        storeManager: storeManager
                    )
                ) {
                    Label("settings.misc.supportUs", systemSymbol: .dollarsignSquare)
                }
            }

            Group {
                Section {
                    NavigationLink(destination: PrivacySettingsView()) {
                        Label("隐私设置", systemSymbol: .handRaisedSlashFill)
                    }
                    NavigationLink(destination: GachaSetting()) {
                        Label("祈愿数据管理", systemSymbol: .wandAndStars)
                    }
                }
            }

            Section {
                NavigationLink(destination: GuideVideoLinkView()) {
                    Label("App介绍视频", systemSymbol: .personFillQuestionmark)
                }
                NavigationLink(destination: ContactUsView()) {
                    Label("开发者与联系方式", systemSymbol: .personCropCircleBadgeClock)
                }
            }

            Section {
                // 更多
                NavigationLink(destination: MoreView()) {
                    Label("settings.more", systemSymbol: .ellipsisCircle)
                }
                #if DEBUG
                Button("Alert Toast Debug") {
                    //                        UserNotificationCenter.shared
                    //                            .printAllNotificationRequest()
                    isAlertToastShown.toggle()
                }
                #endif
            } footer: {
                Spacer()
            }
        }
        .sectionSpacing(UIFont.systemFontSize)
        .navigationTitle("nav.category.settings.name")
    }
}
