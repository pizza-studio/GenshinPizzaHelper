//
//  AppConfig.swift
//  GenshinPizzaHelper
//
//  Created by Bill Haku on 2022/9/26.
//

import Foundation
import SwiftUI

// MARK: - AppConfiguration

enum AppConfiguration {
    case Debug
    case TestFlight
    case AppStore
}

// MARK: - AppConfig

enum AppConfig {
    // MARK: Internal

    // OPENSOURCE: 替换以下内容为「Opensource Secret」
    static let homeAPISalt: String = "2f2d1f9e00719112e88d92d98165f9aa"
    static let uidSalt: String = "GenshinPizzaHelper"

    // This can be used to add debug statements.
    static var isDebug: Bool {
        #if DEBUG
        return true
        #else
        return false
        #endif
    }

    static var appConfiguration: AppConfiguration {
        if isDebug {
            return .Debug
        } else if isTestFlight {
            return .TestFlight
        } else {
            return .AppStore
        }
    }

    // MARK: Private

    // This is private because the use of 'appConfiguration' is preferred.
    private static let isTestFlight = Bundle.main.appStoreReceiptURL?
        .lastPathComponent == "sandboxReceipt"
}
