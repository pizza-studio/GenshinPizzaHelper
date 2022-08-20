//
//  UserNotificationConfiguration.swift
//  GenshinPizzaHelper
//
//  Created by 戴藏龙 on 2022/8/20.
//

import Foundation

struct UserNotificationConfiguration: Codable {
    
    var allowResinNotification: Bool = true
    var resinNotificationNum: Int = 150
    var resinNotificationTimeFromFull: Int {
        resinNotificationNum * 8
    }
    
    var allowHomeCoinNotification = true
    var homeCoinNotificationTimeFromFull: Int = 60 * 60
    
    var allowExpeditionNotification = true
    private var noticeExpeditionMethodRawValue = 1
    var noticeExpeditionBy: ExpeditionNoticeMethod {
        get {
            .init(rawValue: noticeExpeditionMethodRawValue)!
        }
        set {
            noticeExpeditionMethodRawValue = newValue.rawValue
        }
    }
    
    var allowWeeklyBossesNotification = true
    var weeklyBossesNotificationTimePoint = DateComponents(hour: 19, weekday: 6)
    
    var allowTransformerNotification = true
    
    var allowDailyTaskNotification = true
    var dailyTaskNotificationDateComponents = DateComponents(hour: 19, minute: 30)
    
    var ignoreUids: [String] = []
    
}
