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
    #if !os(watchOS)
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    #endif
    @StateObject var storeManager = StoreManager()

    let productIDs = [
            "Canglong.GenshinPizzaHepler.IAP.6",
            "Canglong.GenshinPizzaHepler.IAP.30",
            "Canglong.GenshinPizzaHepler.IAP.98",
            "Canglong.GenshinPizzaHepler.IAP.198",
            "Canglong.GenshinPizzaHepler.IAP.328",
            "Canglong.GenshinPizzaHepler.IAP.648"
        ]

    init() {
        
        let defaultStandard = UserDefaults.standard
        let isPolicySaved = defaultStandard.bool(forKey: "isPolicyShown")
        if !isPolicySaved {
            defaultStandard.setValue(false, forKey: "isPolicyShown")
        }
        #if !os(watchOS)
        UserNotificationCenter.shared.askPermission()
        #endif
    }
    
    var body: some Scene {
        WindowGroup {
            #if os(watchOS)
            ContentView()
            #else
            ContentView(storeManager: storeManager)
                .environmentObject(viewModel)
                .onAppear {
                    SKPaymentQueue.default().add(storeManager)
                    storeManager.getProducts(productIDs: productIDs)
                }
            #endif
        }
    }
}
