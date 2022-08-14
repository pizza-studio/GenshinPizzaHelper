//
//  UserData.swift
//  原神披萨小助手
//
//  Created by Bill Haku on 2022/8/6.
//

import Foundation

struct UserData: Codable {
    
    var accountName: String?
    
    mutating func addName(_ name: String) { accountName = name }
    
    // 树脂
    // decode
    private let currentResin: Int
    private let maxResin: Int
    private let resinRecoveryTime: String
    
    var resinInfo: ResinInfo {
        ResinInfo(currentResin, maxResin, Int(resinRecoveryTime)!)
    }
    
    // 每日任务
    private let finishedTaskNum: Int
    private let totalTaskNum: Int
    private let isExtraTaskRewardReceived: Bool
    
    var dailyTaskInfo: DailyTaskInfo {
        DailyTaskInfo(totalTaskNum: totalTaskNum, finishedTaskNum: finishedTaskNum, isTaskRewardReceived: isExtraTaskRewardReceived)
    }
    
    // 周本
    private let remainResinDiscountNum: Int
    private let resinDiscountNumLimit: Int
    
    var weeklyBossesInfo: WeeklyBossesInfo {
        WeeklyBossesInfo(remainResinDiscountNum: remainResinDiscountNum, resinDiscountNumLimit: resinDiscountNumLimit)
    }
    
    // 派遣探索
    private let currentExpeditionNum: Int
    private let maxExpeditionNum: Int
    private let expeditions: [Expedition]
    
    var expeditionInfo: ExpeditionInfo {
        ExpeditionInfo(currentExpedition: currentExpeditionNum, maxExpedition: maxExpeditionNum, expeditions: expeditions)
    }
    
    // 洞天宝钱
    private let currentHomeCoin: Int
    private let maxHomeCoin: Int
    private let homeCoinRecoveryTime: String
    
    var homeCoinInfo: HomeCoinInfo {
        HomeCoinInfo(currentHomeCoin, maxHomeCoin, Int(homeCoinRecoveryTime)!)
    }
    
    // 参量质变仪
    private let transformer: TransformerData
    
    var transformerInfo: TransformerInfo {
        TransformerInfo(transformer)
    }
}

extension UserData {
    static let defaultData = UserData(
        accountName: "荧",
        
        // 用于测试和提供小组件预览视图的默认数据
        currentResin: 90,
        maxResin: 160,
        resinRecoveryTime: "123",

        finishedTaskNum: 3,
        totalTaskNum: 4,
        isExtraTaskRewardReceived: false,

        remainResinDiscountNum: 2,
        resinDiscountNumLimit: 3,

        currentExpeditionNum: 2,
        maxExpeditionNum: 5,
        expeditions: [defaultExpedition],

        currentHomeCoin: 1200,
        maxHomeCoin: 2400,
        homeCoinRecoveryTime: "123",
        
        transformer: TransformerData(recoveryTime: TransformerData.TransRecoveryTime(day: 4, hour: 3, minute: 0, second: 0), obtained: true)
    )
    
    private static let defaultExpedition: Expedition = Expedition(avatarSideIcon: "https://upload-bbs.mihoyo.com/game_record/genshin/character_side_icon/UI_AvatarIcon_Side_Sara.png", remainedTimeStr: "0", statusStr: "Finished")
}
