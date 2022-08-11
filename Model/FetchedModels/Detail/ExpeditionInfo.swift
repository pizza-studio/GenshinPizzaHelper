//
//  ExpeditionDetail.swift
//  GenshinPizzaHepler
//
//  Created by 戴藏龙 on 2022/8/7.
//

import Foundation

struct ExpeditionInfo {
    let currentExpedition: Int
    let maxExpedition: Int
    
    let expeditions: [Expedition]
    
    var currentOngoingTask: Int {
        expeditions.filter { expedition in
            expedition.isComplete == false
        }
        .count
    }
    
    var anyCompleted: Bool { currentOngoingTask < maxExpedition }
    var nextCompleteTime: RecoveryTime {
        RecoveryTime(second: expeditions.min {
            $0.recoveryTime.second < $1.recoveryTime.second
        }?.recoveryTime.second ?? 0)
    }
    
    var allCompleted: Bool { currentOngoingTask == 0 }
    var allCompleteTime: RecoveryTime {
        RecoveryTime(second: expeditions.max {
            $0.recoveryTime.second < $1.recoveryTime.second
        }?.recoveryTime.second ?? 0)
    }
}

struct Expedition: Codable {
    let avatarSideIcon: String
    let remainedTimeStr: String
    let statusStr: String
    
    var avatarSideIconUrl: URL { URL(string: avatarSideIcon)! }
    var recoveryTime: RecoveryTime {
        RecoveryTime(second: Int(remainedTimeStr)!)
    }
    var isComplete: Bool {
        recoveryTime.isComplete
    }
    
    enum CodingKeys: String, CodingKey {
        case avatarSideIcon = "avatarSideIcon"
        case remainedTimeStr = "remainedTime"
        case statusStr = "status"
    }
}
