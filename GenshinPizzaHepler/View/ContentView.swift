//
//  ContentView.swift
//  GenshinPizzaHepler
//
//  Created by Bill Haku on 2022/8/22.
//

import SwiftUI

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

    var body: some View {
        ZStack {
            TabView(selection: index) {
                HomeView(animation: animation)
                    .tag(0)
                    .environmentObject(viewModel)
                    .environmentObject(detail)
                    .tabItem {
                        Label("主页", systemImage: "house")
                    }
                    .statusBar(hidden: true)
                SettingsView()
                    .tag(1)
                    .environmentObject(viewModel)
                    .tabItem {
                        Label("设置", systemImage: "gear")
                    }
            }

            if detail.show {
                AccountDisplayView(detail: detail, animation: animation)
            }
        }
        .onChange(of: scenePhase, perform: { newPhase in
            switch newPhase {
            case .active:
                // 检查是否同意过用户协议
                let isPolicyShown = UserDefaults.standard.bool(forKey: "isPolicyShown")
                if !isPolicyShown {
                    sheetType = .userPolicy
                }
                viewModel.fetchAccount()
                viewModel.refreshData()
                UIApplication.shared.applicationIconBadgeNumber = 0
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
    }
}

enum ContentViewSheetType: Identifiable {
    var id: Int {
        hashValue
    }

    case userPolicy
}
