//
//  TimeTools.swift
//  原神披萨小助手
//
//  Created by Bill Haku on 2022/8/6.
//

import Foundation

func secondsToHoursMinutes(_ seconds: Int) -> String {
    if seconds / 3600 > 24 {
        let cn = "%lld天"
        return String(format: NSLocalizedString(cn, comment: "day"), seconds / (3600 * 24))
    }
    let cn = "%lld小时%lld分钟"
    return String(format: NSLocalizedString(cn, comment: "day"), seconds / 3600, (seconds % 3600) / 60)
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

func relativeTimePointFromNow(second: Int) -> String {
    let dateFormatter = DateFormatter()
    dateFormatter.dateStyle = .short
    dateFormatter.timeStyle = .short
    dateFormatter.doesRelativeDateFormatting = true
    dateFormatter.locale = Locale(identifier: Locale.current.identifier)

    let date = Calendar.current.date(byAdding: .second, value: second, to: Date())!

    return dateFormatter.string(from: date)
}
