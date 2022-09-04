//
//  RecoveryTime.swift
//  GenshinPizzaHepler
//
//  Created by 戴藏龙 on 2022/8/7.
//  回复时间计算工具

import Foundation

struct RecoveryTime {
    let second: Int
    
    init(second: Int) {
        self.second = second
    }
    
    init(_ day: Int, _ hour: Int, _ minute: Int, _ second: Int) {
        self.second = day*24*60*60 + hour*60*60 + minute*60 + second
    }
    
    var isComplete: Bool { second == 0 }
    
    var describeIntervalLong: String? {
        guard second != 0 else { return nil }
        // 描述为 X天 或 X小时X分钟
        if second / 3600 >= 24 {
            let localizedString = NSLocalizedString("%lld天", comment: "day")
            return String(format: localizedString, second / (3600 * 24) + 1)
        }
        let localizedString = NSLocalizedString("%lld小时%lld分钟", comment: "hour & min")
        return String(format: localizedString, second / 3600, (second % 3600) / 60)
    }
    var describeIntervalShort: String? {
        guard second != 0 else { return nil }
        // 描述为 X天 或 X小时 或 X分钟
        if second / 3600 >= 24 {
            let localizedString = NSLocalizedString("%lld天", comment: "day")
            return String(format: localizedString, 1 + second / (3600 * 24))
        } else if second / 3600 > 0 {
            let localizedString = NSLocalizedString("%lld小时", comment: "hour")
            return String(format: localizedString, second / 3600)
        } else {
            let localizedString = NSLocalizedString("%lld分钟", comment: "min")
            return String(format: localizedString, (second % 3600) / 60)
        }
    }
    var completeTimePointFromNow: String? {
        guard second != 0 else { return nil }
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .short
        dateFormatter.timeStyle = .short
        dateFormatter.doesRelativeDateFormatting = true
        dateFormatter.locale = Locale(identifier: Locale.current.identifier)
        
        let date = Calendar.current.date(byAdding: .second, value: second, to: Date())!

        return dateFormatter.string(from: date)
    }
    
    
}

