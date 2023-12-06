//
//  ContentView.swift
//  GenshinPizzaHepler
//
//  Created by Bill Haku on 2022/8/22.
//  根View

import Defaults
import GIPizzaKit
import HBMihoyoAPI
import SFSafeSymbols
import SwiftUI
import WidgetKit

// MARK: - ContentView

struct ContentView: View {
//    @EnvironmentObject
//    var viewModel: ViewModel

    @Environment(\.scenePhase)
    var scenePhase

    @Environment(\.colorScheme)
    var colorScheme

    @State
    var selection: Int = !(0 ..< 3).contains(Defaults[.appTabIndex]) ? 0 : Defaults[.appTabIndex]

    @State
    var sheetType: ContentViewSheetType?
    @State
    var newestVersionInfos: NewestVersion?
    @State
    var isJustUpdated: Bool = false

    @Default(.autoDeliveryResinTimerLiveActivity)
    var autoDeliveryResinTimerLiveActivity: Bool

    @State
    var isPopUpViewShow: Bool = false
    @Namespace
    var animation

    @StateObject
    var storeManager: StoreManager
    @State
    var isJumpToSettingsView: Bool = false

    let appVersion = Bundle.main
        .infoDictionary!["CFBundleShortVersionString"] as! String
    let buildVersion = Int(
        Bundle.main
            .infoDictionary!["CFBundleVersion"] as! String
    )!

    @FetchRequest(sortDescriptors: [.init(
        keyPath: \AccountConfiguration.priority,
        ascending: true
    )])
    var accounts: FetchedResults<AccountConfiguration>

    @State
    var settingForAccount: AccountConfiguration?

    var index: Binding<Int> { Binding(
        get: { selection },
        set: {
            if $0 != selection {
                simpleTaptic(type: .selection)
            }
            selection = $0
            Defaults[.appTabIndex] = $0
            UserDefaults.opSuite.synchronize()
        }
    ) }

    var viewBackgroundColor: UIColor {
        colorScheme == .light ? UIColor.secondarySystemBackground : UIColor.systemBackground
    }

    var sectionBackgroundColor: UIColor {
        colorScheme == .dark ? UIColor.secondarySystemBackground : UIColor.systemBackground
    }

    var body: some View {
        TabView(selection: index) {
            HomeView()
                .tag(0)
                .tabItem {
                    Label("概览", systemSymbol: .listBullet)
                }
            DetailPortalView()
                .tag(1)
                .tabItem {
                    Label("详情", systemSymbol: .personTextRectangle)
                }
            ToolView()
                .tag(2)
                .tabItem {
                    Label("工具", systemSymbol: .shippingboxFill)
                }
            SettingsView(storeManager: storeManager)
                .tag(3)
                .tabItem {
                    Label("nav.category.settings.name", systemSymbol: .gear)
                }
        }
        .onChange(of: scenePhase, perform: { newPhase in
            switch newPhase {
            case .active:
                // 检查是否同意过用户协议
                if !Defaults[.isPolicyShown] { sheetType = .userPolicy }
                UIApplication.shared.applicationIconBadgeNumber = -1

                if Defaults[.isPolicyShown] {
                    // 检查最新版本
                    checkNewestVersion()
                }
            case .inactive:
                WidgetCenter.shared.reloadAllTimelines()
            default:
                break
            }
        })
        .sheet(item: $sheetType) { item in
            switch item {
            case .userPolicy:
                UserPolicyView(sheet: $sheetType)
                    .interactiveDismissDisabled()
            case .foundNewestVersion:
                LatestVersionInfoView(
                    sheetType: $sheetType,
                    newestVersionInfos: $newestVersionInfos,
                    isJustUpdated: $isJustUpdated
                )
                .interactiveDismissDisabled()
            case .accountSetting:
                NavigationView {
                    EditAccountView(account: settingForAccount!)
                        .dismissableSheet(sheet: $sheetType)
                }
            }
        }
        .onOpenURL { url in
            switch url.host {
            case "settings":
                print("jump to settings")
                isJumpToSettingsView.toggle()
                selection = 1
            case "accountSetting":
                selection = 2
                if let accountUUIDString = URLComponents(
                    url: url,
                    resolvingAgainstBaseURL: true
                )?.queryItems?.first(where: { $0.name == "accountUUIDString" })?
                    .value,
                    let account = accounts
                    .first(where: {
                        $0.uuid?.uuidString == accountUUIDString
                    }) {
                    settingForAccount = account
                    sheetType = .accountSetting
                }
            default:
                return
            }
        }
        .onAppear {
            print(
                "Locale: \(Bundle.main.preferredLocalizations.first ?? "Unknown")"
            )
        }
        .navigate(
            to: NotificationSettingView(),
            when: $isJumpToSettingsView
        )
    }

    func checkNewestVersion() {
        DispatchQueue.global(qos: .default).async {
            switch AppConfig.appConfiguration {
            case .AppStore:
                PizzaHelperAPI.fetchNewestVersion(isBeta: false) { result in
                    newestVersionInfos = result
                    guard let newestVersionInfos = newestVersionInfos else {
                        return
                    }
                    // 发现新版本
                    if buildVersion < newestVersionInfos.buildVersion {
                        let checkedUpdateVersions = Defaults[.checkedUpdateVersions]
                        // 若已有存储的检查过的版本号数组
                        if !checkedUpdateVersions.contains(newestVersionInfos.buildVersion) {
                            sheetType = .foundNewestVersion
                        }
                    } else {
                        // App版本号>=服务器版本号
                        let checkedNewestVersion = Defaults[.checkedNewestVersion]
                        // 已经看过的版本号小于服务器版本号，说明是第一次打开该新版本
                        if checkedNewestVersion < newestVersionInfos
                            .buildVersion {
                            isJustUpdated = true
                            sheetType = .foundNewestVersion
                            Defaults[.checkedNewestVersion] = newestVersionInfos.buildVersion
                            UserDefaults.opSuite.synchronize()
                        }
                    }
                }
            case .Debug, .TestFlight:
                PizzaHelperAPI.fetchNewestVersion(isBeta: true) { result in
                    newestVersionInfos = result
                    guard let newestVersionInfos = newestVersionInfos else {
                        return
                    }
                    if buildVersion < newestVersionInfos.buildVersion {
                        if !Defaults[.checkedUpdateVersions].contains(newestVersionInfos.buildVersion) {
                            sheetType = .foundNewestVersion
                        }
                    } else {
                        let checkedNewestVersion = Defaults[.checkedNewestVersion]
                        if checkedNewestVersion < newestVersionInfos
                            .buildVersion {
                            isJustUpdated = true
                            sheetType = .foundNewestVersion
                            Defaults[.checkedNewestVersion] = newestVersionInfos.buildVersion
                            UserDefaults.opSuite.synchronize()
                        }
                    }
                }
            }
        }
    }
}

// MARK: - ContentViewSheetType

enum ContentViewSheetType: Identifiable {
    case userPolicy
    case foundNewestVersion
    case accountSetting

    // MARK: Internal

    var id: Int {
        hashValue
    }
}
