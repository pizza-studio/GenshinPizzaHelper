// (c) 2022 and onwards Pizza Studio (GPL v3.0 License).
// ====================
// This code is released under the GPL v3.0 License (SPDX-License-Identifier: GPL-3.0)

import AppTrackingTransparency
import Defaults
import DefaultsKeys
import Foundation
import GIPizzaKit

extension AppConfig {
    static func requestConsentForSpiralAbyssDataUpload() {
        ATTrackingManager.requestTrackingAuthorization { status in
            switch status {
            case .denied, .restricted:
                Defaults[.hasAskedAllowAbyssDataCollection] = true
                Defaults[.allowAbyssDataCollection] = false
            case .authorized:
                Defaults[.allowAbyssDataCollection] = true
            default:
                break
            }
        }
    }

    static var textsForSpiralAbyssDataConsent: (title: String, desc: String) {
        (
            String(localized: .init(stringLiteral: "settings.privacy.abyssDataCollect")),
            String(localized: .init(stringLiteral: "settings.privacy.abyssDataCollect.detail"))
        )
    }
}
