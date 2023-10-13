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
    @StateObject
    var storeManager: StoreManager

    var body: some View {
        Group {
            if #available(iOS 16, *) {
                SettingViewIOS16(storeManager: storeManager)
            } else {
                SettingViewIOS15(storeManager: storeManager)
            }
        }
    }
}

// MARK: - SettingViewIOS16

@available(iOS 16.0, *)
struct SettingViewIOS16: View {
    enum Navigation {
        case myAccount
        case faq
        case tool
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

    @EnvironmentObject
    var viewModel: ViewModel

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
                }
                Section {
                    NavigationLink(value: Navigation.faq) {
                        Label(
                            "settings.misc.FAQ",
                            systemSymbol: .personFillQuestionmark
                        )
                    }
                    NavigationLink(value: Navigation.tool) {
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

                // 通知设置
                NotificationSettingNavigatorIOS16(selectedView: $selectedView)

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

                Section {
                    // 更多
                    NavigationLink(value: Navigation.more) {
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
            #if DEBUG
                .toast(isPresenting: $isAlertToastShown) {
                    AlertToast(
                        displayMode: .hud,
                        type: .complete(.green),
                        title: "Complete"
                    )
                }
            #endif
        } detail: {
            NavigationStack {
                if let selectedView {
                    switch selectedView {
                    case .myAccount:
                        AccountManagementView().environmentObject(viewModel)
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
                    case .tool:
                        ThirdPartyToolsView()
                            .environmentObject(viewModel)
                            .navigationTitle("旅行工具")
                            .navigationBarTitleDisplayMode(.inline)
                    case .uiPreference:
                        DisplayOptionsView()
                    case .widgetSetting:
                        WidgetSettingView()
                    case .notificationSetting:
                        NotificationSettingView()
                    case .resinTimerSetting:
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
                    }
                } else {
                    EmptyView()
                }
            }
        }
        .navigationSplitViewStyle(.balanced)
    }
}

// MARK: - SettingViewIOS15

private struct SettingViewIOS15: View {
    @EnvironmentObject
    var viewModel: ViewModel

    @StateObject
    var storeManager: StoreManager

    @State
    var isAlertToastShown = false

    var body: some View {
        NavigationView {
            navList
            DisplayOptionsView() // 预设内容页
        }
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
