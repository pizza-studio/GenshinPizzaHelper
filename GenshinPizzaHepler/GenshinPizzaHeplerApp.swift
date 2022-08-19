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
        UserNotificationCenter.shared.askPermission()
        UserNotificationCenter.shared.createResinNotification(for: "Hi", with: ResinInfo(60, 60, 60*60+15))
        
    }
    
    var body: some Scene {
        WindowGroup {
            SettingsView()
                .environmentObject(viewModel)
        }
    }
}
