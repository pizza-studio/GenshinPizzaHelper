//
//  ResinRecoveryAttributes.swift
//  GenshinPizzaHelper
//
//  Created by 戴藏龙 on 2022/11/18.
//

import Foundation
import HoYoKit
#if canImport(ActivityKit)
import ActivityKit

@available(iOS 16.1, *)
struct ResinRecoveryAttributes: ActivityAttributes {
    // MARK: Public

    public typealias ResinRecoveryState = ContentState

    public struct ContentState: Codable, Hashable {
        // MARK: Lifecycle

        init(
            resinInfo: ResinInformation,
            expeditionInfo: some ExpeditionInformation,
            showExpedition: Bool,
            background: ResinRecoveryActivityBackground
        ) {
            self.resinCountWhenUpdated = resinInfo.currentResin
            self.resinRecoveryTime = resinInfo.resinRecoveryTime
            if let expeditionInfo = expeditionInfo as? GeneralDailyNote.ExpeditionInformation {
                self.expeditionAllCompleteTime = expeditionInfo.expeditions.map(\.finishTime).max()
            } else {
                self.expeditionAllCompleteTime = nil
            }
            self.showExpedition = showExpedition
            self.background = background
        }

        // MARK: Internal

        let resinCountWhenUpdated: Int
        let resinRecoveryTime: Date
        let expeditionAllCompleteTime: Date?
        let showExpedition: Bool

        let background: ResinRecoveryActivityBackground
    }

    // MARK: Internal

    let accountName: String
    let accountUUID: UUID
}

@available(iOS 16.1, *)
extension ResinRecoveryAttributes.ResinRecoveryState {
    var currentResin: Int {
        let secondRemaining = resinRecoveryTime.timeIntervalSinceReferenceDate - Date().timeIntervalSinceReferenceDate
        let minuteRemaining = Double(secondRemaining) / 60
        let currentResin: Int
        if minuteRemaining <= 0 {
            currentResin = 160
        } else {
            currentResin = 160 - Int(ceil(minuteRemaining / 8))
        }
        return currentResin
    }

    /// 下一20倍数树脂
    var next20ResinCount: Int {
        Int(ceil((Double(currentResin) + 0.01) / 20.0)) * 20
    }

    var showNext20Resin: Bool {
        next20ResinCount != 160
    }

    /// 下一20倍数树脂回复时间点
    var next20ResinRecoveryTime: Date {
        Date(timeIntervalSinceNow: TimeInterval((next20ResinCount - currentResin) * 8 * 60))
    }
}

enum ResinRecoveryActivityBackground: Codable, Equatable, Hashable {
    case random
    case customize([String])
    case noBackground
}
#endif
