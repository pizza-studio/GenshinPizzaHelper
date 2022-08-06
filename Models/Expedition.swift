//
//  Expedition.swift
//  原神披萨小助手
//
//  Created by Bill Haku on 2022/8/6.
//

import Foundation

struct Expedition: Codable {
    let avatarSideIcon: String

    let remainedTimeStr: String
    var remainedTime: Int {
        Int(remainedTimeStr)!
    }

    let statusStr: String
    var status: Status {
        Status(rawValue: statusStr)!
    }

    enum Status: String {
        case ongoing = "Ongoing"
        case completed = "Finished"
    }

    enum CodingKeys: String, CodingKey {
        case avatarSideIcon = "avatarSideIcon"
        case remainedTimeStr = "remainedTime"
        case statusStr = "status"
    }
}

extension Array where Element == Expedition {
    var currentOngoingTask: Int {
        self.filter { expedition in
            expedition.status == .ongoing
        }
        .count
    }
}
