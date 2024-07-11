// (c) 2022 and onwards Pizza Studio (GPL v3.0 License).
// ====================
// This code is released under the GPL v3.0 License (SPDX-License-Identifier: GPL-3.0)

import Foundation
import SwiftUI

// MARK: - AppConfiguration

public enum AppConfiguration {
    case Debug
    case TestFlight
    case AppStore
}

// MARK: - AppConfig

public enum AppConfig {
    // MARK: Public

    // This can be used to add debug statements.
    public static var isDebug: Bool {
        #if DEBUG
        return true
        #else
        return false
        #endif
    }

    public static var appConfiguration: AppConfiguration {
        if isDebug {
            return .Debug
        } else if isTestFlight {
            return .TestFlight
        } else {
            return .AppStore
        }
    }

    // MARK: Internal

    // OPENSOURCE: 替换以下内容为「Opensource Secret」
    static let homeAPISalt: String = "2f2d1f9e00719112e88d92d98165f9aa"
    static let uidSalt: String = "GenshinPizzaHelper"

    // MARK: Private

    // This is private because the use of 'appConfiguration' is preferred.
    private static let isTestFlight = Bundle.main.appStoreReceiptURL?
        .lastPathComponent == "sandboxReceipt"
}
