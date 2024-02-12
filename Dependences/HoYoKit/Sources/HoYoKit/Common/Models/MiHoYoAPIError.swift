//
//  File.swift
//
//
//  Created by 戴藏龙 on 2023/5/2.
//

import Foundation

// MARK: - MiHoYoAPIError

/// The error returned by miHoYo when `retcode != 0`
@available(iOS 15.0, *)
public enum MiHoYoAPIError: Error {
    case verificationNeeded
    case fingerPrintNeeded
    case noStokenV2
    case other(retcode: Int, message: String)

    // MARK: Lifecycle

    public init(retcode: Int, message: String) {
        if retcode == 1034 || retcode == 10103 {
            self = .verificationNeeded
        } else if retcode == 5003 {
            self = .fingerPrintNeeded
        } else {
            self = .other(retcode: retcode, message: message)
        }
    }
}
