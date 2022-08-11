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

    init() {
        
        let defaultStandard = UserDefaults.standard
        let isPolicySaved = defaultStandard.bool(forKey: "isPolicyShown")
        if !isPolicySaved {
            defaultStandard.setValue(false, forKey: "isPolicyShown")
        }
        
    }
    
    var body: some Scene {
        WindowGroup {
            SettingsView()
                .environmentObject(viewModel)
        }
    }
}
