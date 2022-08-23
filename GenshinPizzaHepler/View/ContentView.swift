//
//  ContentView.swift
//  GenshinPizzaHepler
//
//  Created by Bill Haku on 2022/8/22.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var viewModel: ViewModel
    @State var selection: Int = 0
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
    }
}
