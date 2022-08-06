//
//  UserData.swift
//  原神披萨小助手
//
//  Created by Bill Haku on 2022/8/6.
//

import Foundation

struct UserData: Codable {
    let currentResin: Int
    let currentHomeCoin: Int
    var currentExpeditionNum: Int {
        expeditions.currentOngoingTask
    }
    let finishedTaskNum: Int

    let transformer: TransformerData
    var transformerTimeSecondInt: Int {
        transformer.recoveryTime.secondDelta
    }

    let expeditions: [Expedition]

    let resinRecoveryTime: String
    var resinRecoveryHour: Float {
        (Float(resinRecoveryTime) ?? 0.0)/(60*60)
    }
    var resinRecoveryTimeInt: Int {
        Int(resinRecoveryTime)!
    }
}
