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
            "MiHoYoAPIError.verificationNeeded.errorDescription"
        case .fingerPrintNeeded:
            "MiHoYoAPIError.fingerPrintNeeded.errorDescription"
        case let .other(retcode, message):
            "(\(retcode)): \(message)"
        }
    }
}
