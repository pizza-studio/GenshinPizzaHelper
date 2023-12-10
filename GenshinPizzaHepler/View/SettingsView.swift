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
    enum Navigation {
        case myAccount
        case faq
        case uiPreference
        case widgetSetting
        case notificationSetting
        case resinTimerSetting
        case donate
        case privacy
        case wishDataManagement
        case appIntroductionVideo
        case contact
        case more
    }

    @StateObject
    var storeManager: StoreManager

    @State
    var isAlertToastShown = false

    @State
    var selectedView: Navigation?

    var body: some View {
        NavigationSplitView(columnVisibility: .constant(.all)) {
            List(selection: $selectedView) {
                Section {
                    NavigationLink(value: Navigation.myAccount) {
                        Label(
                            "settings.account.myAccount",
                            systemSymbol: .personFill
                        )
                    }
                    NavigationLink(value: Navigation.faq) {
                        Label(
                            "settings.misc.FAQ",
                            systemSymbol: .personFillQuestionmark
                        )
                    }
                }

                // 通知设置
                NotificationSettingNavigator(selectedView: $selectedView)

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
                    NavigationLink(value: Navigation.uiPreference) {
                        Label(
                            "settings.display.title",
                            systemSymbol: .pc
                        )
                    }
                    NavigationLink(value: Navigation.widgetSetting) {
                        Label(
                            "小组件设置",
                            systemSymbol: .speedometer
                        )
                    }
                }

                #if canImport(ActivityKit)
                if #available(iOS 16.1, *) {
                    LiveActivitySettingView(selectedView: $selectedView)
                }
                #endif

                Section {
                    Button {
                        ReviewHandler.requestReviewIfNotRequestedElseNavigateToAppStore()
                    } label: {
                        Label("settings.misc.rateMeOnAppStore", systemSymbol: .arrowUpForwardApp)
                    }
                    NavigationLink(value: Navigation.donate, label: {
                        Label("settings.misc.supportUs", systemSymbol: .dollarsignSquare)
                    })
                }

                Group {
                    Section {
                        NavigationLink(
                            value: Navigation.privacy,
                            label: { Label("隐私设置", systemSymbol: .handRaisedSlashFill) }
                        )
                        NavigationLink(
                            value: Navigation.wishDataManagement,
                            label: { Label("祈愿数据管理", systemSymbol: .wandAndStars) }
                        )
                    }
                }

                Section {
                    NavigationLink(
                        value: Navigation.appIntroductionVideo,
                        label: { Label("App介绍视频", systemSymbol: .personFillQuestionmark) }
                    )

                    NavigationLink(value: Navigation.contact) {
                        Label("开发者与联系方式", systemSymbol: .personCropCircleBadgeClock)
                    }
                }

                /// 此处只能这样分别弄成两个 Section，否则在某些旧版 iOS 系统下可能会有异常（会出现空白行）。
                #if DEBUG
                Section {
                    // 更多
                    NavigationLink(value: Navigation.more) {
                        Label("settings.more", systemSymbol: .ellipsisCircle)
                    }
                    Button("Alert Toast Debug") {
                        //                        UserNotificationCenter.shared
                        //                            .printAllNotificationRequest()
                        isAlertToastShown.toggle()
                    }
                } footer: {
                    Spacer()
                }
                #else
                Section {
                    // 更多
                    NavigationLink(value: Navigation.more) {
                        Label("settings.more", systemSymbol: .ellipsisCircle)
                    }
                } footer: {
                    Spacer()
                }
                #endif
            }
            .listStyle(.insetGrouped)
            .navigationTitle("nav.category.settings.name")
        } detail: {
            NavigationStack {
                switch selectedView {
                case .myAccount:
                    ManageAccountsView()
                case .faq:
                    let url: String = {
                        switch Bundle.main.preferredLocalizations.first {
                        case "zh-Hans", "zh-Hant", "zh-HK":
                            return "https://gi.pizzastudio.org/static/faq.html"
                        default:
                            return "https://gi.pizzastudio.org/static/faq_en.html"
                        }
                    }()
                    WebBroswerView(url: url)
                        .navigationTitle("FAQ")
                        .navigationBarTitleDisplayMode(.inline)
                case .uiPreference:
                    DisplayOptionsView()
                case .widgetSetting:
                    WidgetSettingView()
                case .notificationSetting:
                    NotificationSettingView()
                case .resinTimerSetting:
                    // TODO: live activity
                    #if canImport(ActivityKit)
                    if #available(iOS 16.1, *) {
                        LiveActivitySettingDetailView()
                    }
                    #else
                    EmptyView()
                    #endif
                case .donate:
                    GlobalDonateView(
                        storeManager: storeManager
                    )
                case .privacy:
                    PrivacySettingsView()
                case .wishDataManagement:
                    GachaSetting()
                case .appIntroductionVideo:
                    GuideVideoLinkView()
                case .contact:
                    ContactUsView()
                case .more:
                    MoreView()
                case nil:
                    DisplayOptionsView()
                }
            }
        }
        .alwaysShowSideBar()
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
}
