//
//  RecoveryTime.swift
//  GenshinPizzaHepler
//
//  Created by 戴藏龙 on 2022/8/7.
//

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
    
    var describeIntervalLong: String {
        // 描述为 X天 或 X小时X分钟
        if second / 3600 > 24 {
            return "\(second / (3600 * 24))天"
        }
        return "\(second / 3600)小时\((second % 3600) / 60)分钟"
    }
    var describeIntervalShort: String {
        // 描述为 X天 或 X小时 或 X分钟
        if second / 3600 > 24 {
            return "\(second / (3600 * 24))天"
        } else if second / 3600 > 0 {
            return "\(second / 3600)小时"
        } else {
            return "\((second % 3600) / 60)分钟"
        }
    }
    var completeTimePointFromNow: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .short
        dateFormatter.timeStyle = .short
        dateFormatter.doesRelativeDateFormatting = true
        dateFormatter.locale = Locale(identifier: "zh_CN")
        
        let date = Calendar.current.date(byAdding: .second, value: second, to: Date())!

        return dateFormatter.string(from: date)
    }
    
}

