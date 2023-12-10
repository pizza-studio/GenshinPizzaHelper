//
//  AppDelegate.swift
//  GenshinPizzaHepler
//
//  Created by Bill Haku on 2022/8/22.
//

import Foundation
import UIKit

class AppDelegate: NSObject, UIApplicationDelegate,
    UNUserNotificationCenterDelegate {
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [
            UIApplication
                .LaunchOptionsKey: Any
        ]? = nil
    )
        -> Bool {
        let nc = UNUserNotificationCenter.current()
        nc.delegate = self
        return true
    }

    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> ()
    ) {
        defer { completionHandler() }
        switch response.actionIdentifier {
        case "OPEN_GENSHIN_ACTION":
            let genshinAppLocalHeader = "yuanshengame://"
            let isGenshinInstalled = GenshinCalculatorLink.isInstallation(urlString: genshinAppLocalHeader)
            if isGenshinInstalled, let gameURL = URL(string: genshinAppLocalHeader) {
                UIApplication.shared.open(gameURL) { _ in
                    print("open genshin game succeeded")
                }
            } else if let webGenshinURL = URL(string: "https://ys.mihoyo.com/cloud/") {
                UIApplication.shared.open(webGenshinURL) { _ in
                    print("open webGenshin succeeded")
                }
            }
        case "OPEN_NOTIFICATION_SETTING_ACTION":
            let url = URL(string: "ophelper://settings/")!
            UIApplication.shared.open(url) { _ in
                print("open notification settings success")
            }
        default:
            break
        }
    }
}
