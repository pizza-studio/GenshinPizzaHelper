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
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @StateObject var storeManger = StoreManager()

    init() {
        
        let defaultStandard = UserDefaults.standard
        let isPolicySaved = defaultStandard.bool(forKey: "isPolicyShown")
        if !isPolicySaved {
            defaultStandard.setValue(false, forKey: "isPolicyShown")
        }
        
        UserNotificationCenter.shared.askPermission()
        
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView(storeManager: storeManger)
                .environmentObject(viewModel)
        }
    }
}
