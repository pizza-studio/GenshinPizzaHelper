//
//  DailyNoteExtension.swift
//  ResinStatusWidgetExtension
//
//  Created by 戴藏龙 on 2023/12/14.
//

import Defaults
import Foundation
import HoYoKit

extension ResinInformation {
    public func calculatedCurrentResin(referTo date: Date) -> Int {
        let secondToFull = resinRecoveryTime.timeIntervalSinceReferenceDate - date.timeIntervalSinceReferenceDate
        guard secondToFull > 0 else { return maxResin }
        return maxResin - Int(secondToFull / 8 / 60)
    }
}

extension HomeCoinInformation {
    public func calculatedCurrentHomeCoin(referTo date: Date) -> Int {
        let secondToFull = fullTime.timeIntervalSinceReferenceDate - date.timeIntervalSinceReferenceDate
        guard secondToFull > 0 else { return maxHomeCoin }
        return maxHomeCoin - Int(secondToFull * Defaults[.homeCoinRefreshFrequencyInHour] / 3600)
    }
}
