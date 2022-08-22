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
//                simpleTaptic(type: .medium)
                print("taped here!!")
            }
            self.selection = $0
        }
    )}

    var body: some View {
        TabView(selection: index) {
            HomeView()
                .tag(0)
                .tabItem {
                    Label("主页", systemImage: "house")
                }
            SettingsView()
                .tag(1)
                .environmentObject(viewModel)
                .tabItem {
                    Label("设置", systemImage: "gear")
                }
        }
    }
}
