//
//  TimeTools.swift
//  原神披萨小助手
//
//  Created by Bill Haku on 2022/8/6.
//

import Foundation

func secondsToHoursMinutes(_ seconds: Int) -> String {
    if seconds / 3600 > 24 {
        return "\(seconds / (3600 * 24))天"
    }
    return "\(seconds / 3600)小时\((seconds % 3600) / 60)分钟"
}

func secondsToHrOrDay(_ seconds: Int) -> String {
    if seconds / 3600 > 24 {
        return "\(seconds / (3600 * 24))天"
    } else if seconds / 3600 > 0 {
        return "\(seconds / 3600)小时"
    } else {
        return "\((seconds % 3600) / 60)分钟"
    }
}

extension Date {
    func adding(seconds: Int) -> Date {
        return Calendar.current.date(byAdding: .second, value: seconds, to: self)!
    }
}
