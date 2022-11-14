//
//  UserData.swift
//  原神披萨小助手
//
//  Created by Bill Haku on 2022/8/6.
//  小组件和主页用到的各类数据和处理工具

import Foundation

struct UserData: Codable, Equatable {
    static func == (lhs: UserData, rhs: UserData) -> Bool {
        return lhs.accountName == rhs.accountName
    }

    init(resin: String, expedition: String, task: String, homeCoin:String) {
        let resinStr = resin.split(separator: "/")
        self.currentResin = Int(resinStr.first ?? "-1") ?? -1
        self.maxResin = Int(resinStr.last ?? "0") ?? 0
        self.resinRecoveryTime = ""

        let taskStr = task.split(separator: "/")
        self.finishedTaskNum = Int(taskStr.first ?? "-1") ?? -1
        self.totalTaskNum = Int(taskStr.last ?? "0") ?? 0
        self.isExtraTaskRewardReceived = Int(taskStr.first ?? "-1") ?? -1 >= Int(taskStr.last ?? "0") ?? 0

        let expeditionStr = expedition.split(separator: "/")
        self.currentExpeditionNum = Int(expeditionStr.first ?? "-1") ?? -1
        self.maxExpeditionNum = Int(expeditionStr.last ?? "0") ?? 0
        self.expeditions = []

        let homeCoinStr = homeCoin.split(separator: "/")
        self.currentHomeCoin = Int(homeCoinStr.first ?? "-1") ?? -1
        self.maxHomeCoin = Int(homeCoinStr.last ?? "0") ?? 0
        self.homeCoinRecoveryTime = ""

        self.remainResinDiscountNum = -1
        self.resinDiscountNumLimit = -1
        self.transformer = TransformerData()
    }

    init(
        accountName: String,

        // 用于测试和提供小组件预览视图的默认数据
        currentResin: Int,
        maxResin: Int,
        resinRecoveryTime: String,

        finishedTaskNum: Int,
        totalTaskNum: Int,
        isExtraTaskRewardReceived: Bool,

        remainResinDiscountNum: Int,
        resinDiscountNumLimit: Int,

        currentExpeditionNum: Int,
        maxExpeditionNum: Int,
        expeditions: [Expedition],

        currentHomeCoin: Int,
        maxHomeCoin: Int,
        homeCoinRecoveryTime: String,

        transformer: TransformerData
    ) {
        self.accountName = accountName

        self.currentResin = currentResin
        self.maxResin = maxResin
        self.resinRecoveryTime = resinRecoveryTime

        self.finishedTaskNum = finishedTaskNum
        self.totalTaskNum = totalTaskNum
        self.isExtraTaskRewardReceived = isExtraTaskRewardReceived

        self.remainResinDiscountNum = remainResinDiscountNum
        self.resinDiscountNumLimit = resinDiscountNumLimit

        self.currentExpeditionNum = currentExpeditionNum
        self.maxExpeditionNum = maxExpeditionNum
        self.expeditions = expeditions

        self.currentHomeCoin = currentHomeCoin
        self.maxHomeCoin = maxResin
        self.homeCoinRecoveryTime = homeCoinRecoveryTime

        self.transformer = transformer
    }

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
        resinRecoveryTime: "\((160-90)*8)",

        finishedTaskNum: 3,
        totalTaskNum: 4,
        isExtraTaskRewardReceived: false,

        remainResinDiscountNum: 2,
        resinDiscountNumLimit: 3,

        currentExpeditionNum: 2,
        maxExpeditionNum: 5,
        expeditions: Expedition.defaultExpeditions,

        currentHomeCoin: 1200,
        maxHomeCoin: 2400,
        homeCoinRecoveryTime: "123",
        
        transformer: TransformerData(recoveryTime: TransformerData.TransRecoveryTime(day: 4, hour: 3, minute: 0, second: 0), obtained: true)
    )
}

extension Expedition {
    static let defaultExpedition: Expedition = Expedition(avatarSideIcon: "https://upload-bbs.mihoyo.com/game_record/genshin/character_side_icon/UI_AvatarIcon_Side_Sara.png", remainedTimeStr: "0", statusStr: "Finished")

    static let defaultExpeditions: [Expedition] = [Expedition(avatarSideIcon: "https://upload-bbs.mihoyo.com/game_record/genshin/character_side_icon/UI_AvatarIcon_Side_Yelan.png", remainedTimeStr: "0", statusStr: "Finished"),
    Expedition(avatarSideIcon: "https://upload-bbs.mihoyo.com/game_record/genshin/character_side_icon/UI_AvatarIcon_Side_Fischl.png", remainedTimeStr: "37036", statusStr: "Ongoing"),
    Expedition(avatarSideIcon: "https://upload-bbs.mihoyo.com/game_record/genshin/character_side_icon/UI_AvatarIcon_Side_Fischl.png", remainedTimeStr: "22441", statusStr: "Ongoing"),
    Expedition(avatarSideIcon: "https://upload-bbs.mihoyo.com/game_record/genshin/character_side_icon/UI_AvatarIcon_Side_Keqing.png", remainedTimeStr: "22441", statusStr: "Ongoing"),
    Expedition(avatarSideIcon: "https://upload-bbs.mihoyo.com/game_record/genshin/character_side_icon/UI_AvatarIcon_Side_Bennett.png", remainedTimeStr: "22441", statusStr: "Ongoing")]
}
