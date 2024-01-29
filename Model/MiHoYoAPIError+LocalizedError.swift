//
//  MiHoYoAPIError+LocalizedError.swift
//  GenshinPizzaHelper
//
//  Created by 戴藏龙 on 2023/12/5.
//

import Foundation
import HoYoKit

extension MiHoYoAPIError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .verificationNeeded:
            String(localized: "MiHoYoAPIError.verificationNeeded.errorDescription")
        case .fingerPrintNeeded:
            String(localized: "MiHoYoAPIError.fingerPrintNeeded.errorDescription")
        case .noStokenV2:
            String(localized: "MiHoYoAPIError.noStokenV2.errorDescription")
        case let .other(retcode, message):
            "(\(retcode)): \(message)"
        }
    }
}
