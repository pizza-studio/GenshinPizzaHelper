//
//  ResinInfo.swift
//  GenshinPizzaHepler
//
//  Created by 戴藏龙 on 2022/8/7.
//  树脂信息

import Foundation

public struct ResinInfo: Codable {
    // MARK: Lifecycle

    public init(
        _ currentResin: Int,
        _ maxResin: Int,
        _ resinRecoverySecond: Int
    ) {
        self.currentResin = currentResin
        self.maxResin = maxResin
        self.resinRecoverySecond = resinRecoverySecond
        self.updateDate = Date()
    }

    // MARK: Public

    public static let defaultMaxResin: Int = {
        guard let threshold = Date(day: 5, month: 6, year: 2024), Date.now < threshold else {
            return 200
        }
        return 160
    }()

    public let currentResin: Int
    public let maxResin: Int
    public let updateDate: Date

    public var isFull: Bool { currentResin == maxResin }

    public var recoveryTime: RecoveryTime {
        RecoveryTime(second: resinRecoverySecond)
    }

    public var percentage: Double { Double(currentResin) / Double(maxResin) }

    public var score: Float {
        if isFull { return 1.1 }
        return Float(percentage)
    }

    // MARK: Private

    private let resinRecoverySecond: Int
}
