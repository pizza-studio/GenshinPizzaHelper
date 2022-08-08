//
//  GenshinPizzaHeplerApp.swift
//  GenshinPizzaHepler
//
//  Created by 戴藏龙 on 2022/7/19.
//

import SwiftUI

@main
struct GenshinPizzaHeplerApp: App {
    let viewModel: ViewModel = .shared
    
    var body: some Scene {
        WindowGroup {
            SettingsView()
                .environmentObject(viewModel)
        }
    }
}
