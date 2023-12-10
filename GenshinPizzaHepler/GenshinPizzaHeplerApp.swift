//
//  GenshinPizzaHeplerApp.swift
//  GenshinPizzaHepler
//
//  Created by 戴藏龙 on 2022/7/19.
//

import Defaults
import StoreKit
import SwiftUI

// MARK: - GenshinPizzaHeplerApp

@main
struct GenshinPizzaHeplerApp: App {
    // MARK: Lifecycle

    init() {
        if !Defaults[.isPolicyShown] { Defaults[.isPolicyShown] = false }
        UserDefaults.opSuite.synchronize()
        #if !os(watchOS)
        UserNotificationCenter.shared.askPermission()
        if OS.type == .macOS {
            UITabBar.appearance().unselectedItemTintColor = .gray
        }
        #endif
    }

// MARK: Internal

//    let viewModel: ViewModel = .shared
    #if !os(watchOS)
    @UIApplicationDelegateAdaptor(AppDelegate.self)
    var appDelegate
    #endif
    @StateObject
    var storeManager = StoreManager()

    let productIDs = [
        "Canglong.GenshinPizzaHepler.IAP.6",
        "Canglong.GenshinPizzaHepler.IAP.30",
        "Canglong.GenshinPizzaHepler.IAP.98",
        "Canglong.GenshinPizzaHepler.IAP.198",
        "Canglong.GenshinPizzaHepler.IAP.328",
        "Canglong.GenshinPizzaHepler.IAP.648",
    ]

    var body: some Scene {
        #if os(watchOS)
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, AccountConfigurationModel.shared.container.viewContext)
        }
        #else
        WindowGroup {
            ContentView(storeManager: storeManager)
//                .onReceive(NotificationCenter.default.publisher(for: UIScene.willConnectNotification)) { _ in
//                    if OS.type == .macOS {
//                        let windowSize = CGSize(width: 414, height: 896)
//                        UIApplication.shared.connectedScenes.compactMap { $0 as? UIWindowScene }
//                            .forEach { windowScene in
//                                windowScene.sizeRestrictions?.minimumSize = windowSize
//                                windowScene.sizeRestrictions?.maximumSize = windowSize
//                                if #available(iOS 16, *) {
//                                    windowScene.sizeRestrictions?.allowsFullScreen = false
//                                }
//                            }
//                    }
//                }
                .onAppear {
                    SKPaymentQueue.default().add(storeManager)
                    storeManager.getProducts(productIDs: productIDs)
                }
                .environment(\.managedObjectContext, AccountConfigurationModel.shared.container.viewContext)
        }
        #endif
    }
}
