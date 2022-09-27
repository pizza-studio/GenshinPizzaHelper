//
//  ContentView.swift
//  GenshinPizzaHepler
//
//  Created by Bill Haku on 2022/8/22.
//  根View

import SwiftUI
import WidgetKit

struct ContentView: View {
    @EnvironmentObject var viewModel: ViewModel

    @Environment(\.scenePhase) var scenePhase

    // TODO: Replace to 0 in release, to 1 for debug
    @State var selection: Int = 0

    @State private var sheetType: ContentViewSheetType? = nil
    @State var newestVersionInfos: NewestVersion? = nil
    @State var isJustUpdated: Bool = false

    var index: Binding<Int> { Binding(
        get: { self.selection },
        set: {
            if $0 != self.selection {
                simpleTaptic(type: .medium)
            }
            self.selection = $0
        }
    )}

    @State var isPopUpViewShow: Bool = false
    @StateObject var detail = DisplayContentModel()
    @Namespace var animation

    @StateObject var storeManager: StoreManager
    @State var isJumpToSettingsView: Bool = false
    @State var bgFadeOutAnimation: Bool = false

    let appVersion = Bundle.main.infoDictionary!["CFBundleShortVersionString"] as! String
    let buildVersion = Int(Bundle.main.infoDictionary!["CFBundleVersion"] as! String)!

    var body: some View {
        ZStack {
            TabView(selection: index) {
                HomeView(animation: animation, bgFadeOutAnimation: $bgFadeOutAnimation)
                    .tag(0)
                    .environmentObject(viewModel)
                    .environmentObject(detail)
                    .tabItem {
                        Label("概览", systemImage: "list.bullet")
                    }
                // TODO: Replace to 15.0 for develop, stay 17 when not ready
                if #available(iOS 17.0, *) {
                    ToolsView()
                        .tag(1)
                        .environmentObject(viewModel)
                        .tabItem {
                            Label("工具", systemImage: "shippingbox")
                        }
                }
                SettingsView(storeManager: storeManager)
                    .tag(2)
                    .environmentObject(viewModel)
                    .tabItem {
                        Label("设置", systemImage: "gear")
                    }
            }

            if detail.show {
                AccountDisplayView(detail: detail, animation: animation, bgFadeOutAnimation: $bgFadeOutAnimation)
            }
        }
        .onChange(of: scenePhase, perform: { newPhase in
            switch newPhase {
            case .active:
                // 检查是否同意过用户协议
                let isPolicyShown = UserDefaults.standard.bool(forKey: "isPolicyShown")
                if !isPolicyShown { sheetType = .userPolicy }
                DispatchQueue.main.async {
                    bgFadeOutAnimation = true
                }
                DispatchQueue.main.async {
                    viewModel.fetchAccount()
                }
                DispatchQueue.main.async {
                    viewModel.refreshData()
                }
                UIApplication.shared.applicationIconBadgeNumber = -1

                // 检查最新版本
                checkNewestVersion()

                // 强制显示背景颜色
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                    bgFadeOutAnimation = false
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
                    .allowAutoDismiss(false)
            case .foundNewestVersion:
                newestVersionInfoView()
            }
        }
        .onOpenURL { url in
            switch url.host {
            case "settings":
                print("jump to settings")
                isJumpToSettingsView.toggle()
                self.selection = 1
            default:
                return
            }
        }
        .navigate(to: NotificationSettingView().environmentObject(viewModel), when: $isJumpToSettingsView)
    }

    func checkNewestVersion() {
        DispatchQueue.global(qos: .default).async {
            switch AppConfig.appConfiguration {
            case .AppStore:
                API.HomeAPIs.fetchNewestVersion(isBeta: false) { result in
                    newestVersionInfos = result
                    guard let newestVersionInfos = newestVersionInfos else {
                        return
                    }
                    if buildVersion < newestVersionInfos.buildVersion {
                        let checkedUpdateVersions = UserDefaults.standard.object(forKey: "checkedUpdateVersions") as! [Int]?
                        if checkedUpdateVersions != nil {
                            if !(checkedUpdateVersions!.contains(newestVersionInfos.buildVersion)) {
                                sheetType = .foundNewestVersion
                            }
                        } else {
                            sheetType = .foundNewestVersion
                        }
                    } else {
                        let checkedNewestVersion = UserDefaults.standard.integer(forKey: "checkedNewestVersion")
                        if checkedNewestVersion < newestVersionInfos.buildVersion {
                            isJustUpdated = true
                            sheetType = .foundNewestVersion
                            UserDefaults.standard.setValue(newestVersionInfos.buildVersion, forKey: "checkedNewestVersion")
                            UserDefaults.standard.synchronize()
                        }
                    }
                }
            case .Debug, .TestFlight:
                API.HomeAPIs.fetchNewestVersion(isBeta: true) { result in
                    newestVersionInfos = result
                    guard let newestVersionInfos = newestVersionInfos else {
                        return
                    }
                    if buildVersion < newestVersionInfos.buildVersion {
                        let checkedUpdateVersions = UserDefaults.standard.object(forKey: "checkedUpdateVersions") as! [Int]?
                        if checkedUpdateVersions != nil {
                            if !(checkedUpdateVersions!.contains(newestVersionInfos.buildVersion)) {
                                sheetType = .foundNewestVersion
                            }
                        } else {
                            sheetType = .foundNewestVersion
                        }
                    } else {
                        let checkedNewestVersion = UserDefaults.standard.integer(forKey: "checkedNewestVersion")
                        if checkedNewestVersion < newestVersionInfos.buildVersion {
                            isJustUpdated = true
                            sheetType = .foundNewestVersion
                            UserDefaults.standard.setValue(newestVersionInfos.buildVersion, forKey: "checkedNewestVersion")
                            UserDefaults.standard.synchronize()
                        }
                    }
                }
            }
        }
    }

    @ViewBuilder
    func newestVersionInfoView() -> some View {
        NavigationView {
            VStack(alignment: .leading) {
                HStack {
                    Text(newestVersionInfos?.shortVersion ?? "Error").font(.largeTitle) +
                    Text(" (\(newestVersionInfos?.buildVersion ?? -1))")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Spacer()
                    Image("AppIconHD")
                        .resizable()
                        .frame(width: 50, height: 50)
                        .cornerRadius(10)
                }
                Divider()
                    .padding(.vertical)
                Text("更新内容：")
                    .font(.subheadline)
                if newestVersionInfos != nil {
                    ForEach(getLocalizedUpdateInfos(meta: newestVersionInfos!), id:\.self) { item in
                        Text("- \(item)")
                    }
                } else {
                    Text("Error")
                }
                if !isJustUpdated {
                    switch AppConfig.appConfiguration {
                    case .TestFlight, .Debug :
                        Link (destination: URL(string: "itms-beta://beta.itunes.apple.com/v1/app/1635319193")!) {
                            Text("前往TestFlight更新")
                        }
                        .padding(.top)
                    case .AppStore:
                        Link (destination: URL(string: "itms-apps://apps.apple.com/us/app/原神披萨小助手/id1635319193")!) {
                            Text("前往App Store更新")
                        }
                        .padding(.top)
                    }
                }
                Spacer()
            }
            .padding(.horizontal)
            .navigationTitle(isJustUpdated ? "感谢您更新到最新版本" : "发现新版本")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("完成") {
                        var checkedUpdateVersions = UserDefaults.standard.object(forKey: "checkedUpdateVersions") as? [Int] ?? []
                        checkedUpdateVersions.append(newestVersionInfos!.buildVersion)
                        UserDefaults.standard.set(checkedUpdateVersions, forKey: "checkedUpdateVersions")
                        print(checkedUpdateVersions)
                        UserDefaults.standard.synchronize()
                        sheetType = nil
                    }
                }
            }
        }
    }

    func getLocalizedUpdateInfos(meta: NewestVersion) -> [String] {
        switch Locale.current.languageCode {
        case "zh":
            return meta.updates.zhcn
        case "en":
            return meta.updates.en
        case "ja":
            return meta.updates.ja
        case "fr":
            return meta.updates.fr
        default:
            return meta.updates.en
        }
    }
}

enum ContentViewSheetType: Identifiable {
    var id: Int {
        hashValue
    }

    case userPolicy
    case foundNewestVersion
}
