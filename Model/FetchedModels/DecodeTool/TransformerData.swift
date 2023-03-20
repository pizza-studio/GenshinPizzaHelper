//
//  RecoveryTime.swift
//  原神披萨小助手
//
//  Created by Bill Haku on 2022/8/6.
//

import Foundation

struct TransformerData: Codable {
    // MARK: Lifecycle

    init() {
        self.obtained = false
        self.recoveryTime = TransRecoveryTime()
    }

    init(recoveryTime: TransRecoveryTime, obtained: Bool) {
        self.recoveryTime = recoveryTime
        self.obtained = obtained
    }

    // MARK: Internal

    struct TransRecoveryTime: Codable {
        // MARK: Lifecycle

        init() {
            self.day = -1
            self.hour = -1
            self.minute = -1
            self.second = -1
        }

        init(day: Int, hour: Int, minute: Int, second: Int) {
            self.day = day
            self.hour = hour
            self.minute = minute
            self.second = second
        }

        // MARK: Internal

        enum CodingKeys: String, CodingKey {
            case day = "Day"
            case hour = "Hour"
            case minute = "Minute"
            case second = "Second"
        }

        let day: Int
        let hour: Int
        let minute: Int
        let second: Int
    }

    let recoveryTime: TransRecoveryTime
    let obtained: Bool
}
