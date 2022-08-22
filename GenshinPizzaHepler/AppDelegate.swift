//
//  AppDelegate.swift
//  GenshinPizzaHepler
//
//  Created by Bill Haku on 2022/8/22.
//

import Foundation
import UIKit

class AppDelegate: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        switch response.actionIdentifier {
        case "OPEN_GENSHIN_ACTION":
            let genshinGameURL = URL(string: "yuanshengame://")!
            UIApplication.shared.open(genshinGameURL) { success in
                print(success)
            }
        default:
            break
        }
        completionHandler()
    }
}
