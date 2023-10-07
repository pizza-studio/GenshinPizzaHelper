//
//  NSDateImpl.swift
//  GenshinPizzaHelper
//
//  Created by ShikiSuen on 2023/10/7.
//

import Foundation

extension Date {
    public static func Specify(day: Int, month: Int, year: Int) -> Date? {
        var month = max(1, min(12, month))
        var year = max(1965, min(9999, year))
        var day = max(1, min(31, day))
        var comps = DateComponents()
        comps.setValue(day, for: .day)
        comps.setValue(month, for: .month)
        comps.setValue(year, for: .year)
        let gregorian = Calendar(identifier: .gregorian)
        var date = gregorian.date(from: comps)
        while date == nil, day > 28 {
            day -= 1
            comps.setValue(day, for: .day)
            date = gregorian.date(from: comps)
        }
        return date
    }
}
