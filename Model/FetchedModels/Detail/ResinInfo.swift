//
//  ResinInfo.swift
//  GenshinPizzaHepler
//
//  Created by 戴藏龙 on 2022/8/7.
//  树脂信息

import Foundation

struct ResinInfo: Codable {
    // MARK: Lifecycle

    init(_ currentResin: Int, _ maxResin: Int, _ resinRecoverySecond: Int) {
        self.currentResin = currentResin
        self.maxResin = maxResin
        self.resinRecoverySecond = resinRecoverySecond
        self.updateDate = Date()
    }

    // MARK: Internal

    let currentResin: Int
    let maxResin: Int
    let updateDate: Date

    var isFull: Bool { currentResin == maxResin }

    var recoveryTime: RecoveryTime {
        RecoveryTime(second: resinRecoverySecond)
    }

    var percentage: Double { Double(currentResin) / Double(maxResin) }

    var score: Float {
        if isFull { return 1.1 }
        return Float(percentage)
    }

    // MARK: Private

    private let resinRecoverySecond: Int
}
