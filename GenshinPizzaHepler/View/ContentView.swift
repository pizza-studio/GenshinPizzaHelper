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

    @State var selection: Int = 0

    @State private var sheetType: ContentViewSheetType? = nil

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

    var body: some View {
        ZStack {
            TabView(selection: index) {
                HomeView(animation: animation, bgFadeOutAnimation: $bgFadeOutAnimation)
                    .tag(0)
                    .environmentObject(viewModel)
                    .environmentObject(detail)
                    .tabItem {
                        Label("主页", systemImage: "house")
                    }
                SettingsView(storeManager: storeManager)
                    .tag(1)
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

                // 同步watch数据
                syncWatch()
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

    private func syncWatch() {
        let messages: [String: Any] = ["accounts": viewModel.accounts]

        self.viewModel.session.sendMessage(messages, replyHandler: nil) { error in
            print("error: \(error.localizedDescription)")
        }
    }
}

enum ContentViewSheetType: Identifiable {
    var id: Int {
        hashValue
    }

    case userPolicy
}
