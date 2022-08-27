//
//  GenshinPizzaHeplerApp.swift
//  GenshinPizzaHepler
//
//  Created by 戴藏龙 on 2022/7/19.
//

import SwiftUI
import StoreKit

@main
struct GenshinPizzaHeplerApp: App {
    let viewModel: ViewModel = .shared
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @StateObject var storeManager = StoreManager()

    let productIDs = [
            "Canglong.GenshinPizzaHepler.IAP.6"
        ]

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
            ContentView(storeManager: storeManager)
                .environmentObject(viewModel)
                .onAppear {
                    SKPaymentQueue.default().add(storeManager)
                    storeManager.getProducts(productIDs: productIDs)
                }
        }
    }
}
