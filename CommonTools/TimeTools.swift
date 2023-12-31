//
//  TimeTools.swift
//  原神披萨小助手
//
//  Created by Bill Haku on 2022/8/6.
//  时间工具

import Foundation

func secondsToHoursMinutes(_ seconds: Int) -> String {
    if seconds / 3600 > 24 {
        let cn = "unit.daysOf:%lld"
        return String(
            format: NSLocalizedString(cn, comment: "day"),
            seconds / (3600 * 24)
        )
    }
    let cn = "unit.HHMM:%lldHH%lldMM"
    return String(
        format: NSLocalizedString(cn, comment: "day"),
        seconds / 3600,
        (seconds % 3600) / 60
    )
}

func secondsToHrOrDay(_ seconds: Int) -> String {
    if seconds / 3600 > 24 {
        return "unit.daysOf:\(seconds / (3600 * 24))"
    } else if seconds / 3600 > 0 {
        return "unit.hrs:\(seconds / 3600)"
    } else {
        return "unit.mins:\((seconds % 3600) / 60)"
    }
}

extension Date {
    func adding(seconds: Int) -> Date {
        Calendar.current.date(byAdding: .second, value: seconds, to: self)!
    }
}

func relativeTimePointFromNow(second: Int) -> String {
    let dateFormatter = DateFormatter.Gregorian()
    dateFormatter.dateStyle = .short
    dateFormatter.timeStyle = .short
    dateFormatter.doesRelativeDateFormatting = true
    dateFormatter.locale = Locale(identifier: Locale.current.identifier)

    let date = Calendar.current.date(
        byAdding: .second,
        value: second,
        to: Date()
    )!

    return dateFormatter.string(from: date)
}

// 计算日期相差天数
extension Date {
    static func - (
        recent: Date,
        previous: Date
    )
        -> (month: Int?, day: Int?, hour: Int?, minute: Int?, second: Int?) {
        let day = Calendar.current.dateComponents(
            [.day],
            from: previous,
            to: recent
        ).day
        let month = Calendar.current.dateComponents(
            [.month],
            from: previous,
            to: recent
        ).month
        let hour = Calendar.current.dateComponents(
            [.hour],
            from: previous,
            to: recent
        ).hour
        let minute = Calendar.current.dateComponents(
            [.minute],
            from: previous,
            to: recent
        ).minute
        let second = Calendar.current.dateComponents(
            [.second],
            from: previous,
            to: recent
        ).second

        return (
            month: month,
            day: day,
            hour: hour,
            minute: minute,
            second: second
        )
    }
}

extension DateFormatter {
    public static func Gregorian() -> DateFormatter {
        let result = DateFormatter()
        result.locale = .init(identifier: "en_US_POSIX")
        return result
    }
}

extension TimeInterval {
    static func sinceNow(to date: Date) -> Self {
        date.timeIntervalSinceReferenceDate - Date().timeIntervalSinceReferenceDate
    }

    static func toNow(from date: Date) -> Self {
        Date().timeIntervalSinceReferenceDate - date.timeIntervalSinceReferenceDate
    }

    init(from dateA: Date, to dateB: Date) {
        self = dateB.timeIntervalSinceReferenceDate - dateA.timeIntervalSinceReferenceDate
    }
}
