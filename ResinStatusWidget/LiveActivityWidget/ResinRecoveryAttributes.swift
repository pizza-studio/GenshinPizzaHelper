//
//  ResinRecoveryAttributes.swift
//  GenshinPizzaHelper
//
//  Created by 戴藏龙 on 2022/11/18.
//

import Foundation
import ActivityKit

@available(iOS 16.1, *)
struct ResinRecoveryAttributes: ActivityAttributes {
    public typealias ResinRecoveryState = ContentState

    public struct ContentState: Codable, Hashable {
        let resinCountWhenUpdated: Int
        let resinRecoveryTimeUntilFullInSecondWhenUpdated: TimeInterval
        let updatedTime: Date

        init(resinInfo: ResinInfo) {
            resinCountWhenUpdated = resinInfo.currentResin
            resinRecoveryTimeUntilFullInSecondWhenUpdated = TimeInterval(resinInfo.recoveryTime.second)
            updatedTime = resinInfo.updateDate
        }
    }

    let accountName: String
    let accountUUID: UUID
}

@available(iOS 16.1, *)
extension ResinRecoveryAttributes.ResinRecoveryState {
    /// 求余获得**更新时**距离下一个树脂的TimeInterval
    var timeIntervalFromNextResinWhenUpdated: TimeInterval {
        Double(resinRecoveryTimeUntilFullInSecondWhenUpdated).truncatingRemainder(dividingBy: Double(8*60))
    }

    /// 距离信息更新时的TimeInterval
    var timeIntervalFromUpdatedTime: TimeInterval {
        Date().timeIntervalSince(updatedTime)
    }

    /// 当前距离树脂回满需要的TimeInterval
    var resinRecoveryTimeIntervalUntilFull: TimeInterval {
        resinRecoveryTimeUntilFullInSecondWhenUpdated - timeIntervalFromUpdatedTime
    }

    /// 树脂回满的时间点
    var resinFullTime: Date {
        updatedTime.addingTimeInterval(resinRecoveryTimeUntilFullInSecondWhenUpdated)
    }

    /// 当前还需多少树脂才能回满
    var resinToFull: Int {
        Int( ceil( resinRecoveryTimeIntervalUntilFull / (8*60) ) )
    }

    /// 当前树脂数量
    var currentResin: Int {
        160 - resinToFull
    }

    /// 当前距离下个树脂回复所需时间
    var nextResinRecoveryTimeInterval: TimeInterval {
        resinRecoveryTimeIntervalUntilFull.truncatingRemainder(dividingBy: 8*60)
    }

    /// 下个树脂回复的时间点
    var nextResinRecoveryTime: Date {
        Date().addingTimeInterval(nextResinRecoveryTimeInterval)
    }

    /// 下一20倍数树脂
    var next20ResinCount: Int {
        var resin: Int = currentResin
        while resin % 20 != 0 {
            resin += 1
        }
        return resin
    }

    /// 下一20倍数树脂回复所需时间
    var next20ResinRecoveryTimeInterval: TimeInterval {
        resinRecoveryTimeIntervalUntilFull.truncatingRemainder(dividingBy: 8*60*20)
    }

    /// 下一20倍数树脂回复时间点
    var next20ResinRecoveryTime: Date? {
        Date().addingTimeInterval(next20ResinRecoveryTimeInterval)
    }
}
