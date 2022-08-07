//
//  UserData.swift
//  原神披萨小助手
//
//  Created by Bill Haku on 2022/8/6.
//

import Foundation

struct UserData: Codable {
    
    // 树脂
    // decode
    let currentResin: Int
    let maxResin: Int
    let resinRecoveryTime: String
    
    var resinInfo: ResinInfo {
        ResinInfo(currentResin, maxResin, Int(resinRecoveryTime)!)
    }
    
    // 每日任务
    let finishedTaskNum: Int
    let totalTaskNum: Int
    let isExtraTaskRewardReceived: Bool
    
    var dailyTaskInfo: DailyTaskInfo {
        DailyTaskInfo(totalTaskNum: totalTaskNum, finishedTaskNum: finishedTaskNum, isTaskRewardReceived: isExtraTaskRewardReceived)
    }
    
    // 周本
    let remainResinDiscountNum: Int
    let resinDiscountNumLimit: Int
    
    var weeklyBossesInfo: WeeklyBossesInfo {
        WeeklyBossesInfo(remainResinDiscountNum: remainResinDiscountNum, resinDiscountNumLimit: resinDiscountNumLimit)
    }
    
    // 派遣探索
    let currentExpeditionNum: Int
    let maxExpeditionNum: Int
    let expeditions: [Expedition]
    
    var expeditionInfo: ExpeditionInfo {
        ExpeditionInfo(currentExpedition: currentExpeditionNum, maxExpedition: maxExpeditionNum, expeditions: expeditions)
    }
    
    // 洞天宝钱
    let currentHomeCoin: Int
    let maxHomeCoin: Int
    let homeCoinRecoveryTime: String
    
    var homeCoinInfo: HomeCoinInfo {
        HomeCoinInfo(currentHomeCoin, maxHomeCoin, Int(homeCoinRecoveryTime)!)
    }
    
    // 参量质变仪
    let transformerData: TransformerData
    
    var transformerInfo: TransformerInfo {
        TransformerInfo(transformerData)
    }
}
