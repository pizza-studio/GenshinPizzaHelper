//
//  RecoveryTime.swift
//  原神披萨小助手
//
//  Created by Bill Haku on 2022/8/6.
//

import Foundation

struct RecoveryTime: Codable {
    let day: Int
    let hour: Int
    let minute: Int
    let second: Int

    var secondDelta: Int {
        let hr = self.day * 24 + self.hour
        let min = hr * 60 + self.minute
        let sec = min * 60 + self.second
        return sec
    }

    enum CodingKeys: String, CodingKey {
        case day = "Day"
        case hour = "Hour"
        case minute = "Minute"
        case second = "Second"
    }
}

struct TransformerData: Codable {
    let recoveryTime: RecoveryTime
}
