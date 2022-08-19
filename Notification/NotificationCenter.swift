//
//  NotificationCenter.swift
//  GenshinPizzaHepler
//
//  Created by 戴藏龙 on 2022/8/20.
//

import Foundation
import UserNotifications

class UserNotificationCenter {
    static let shared: UserNotificationCenter = .init()
    
    private init() {}
    
    let center = UNUserNotificationCenter.current()
    
    func askPermission() {
        center.requestAuthorization(options: [.alert, .sound, .badge, .provisional]) { guarted, error in
            if let error = error {
                print(error.localizedDescription)
            }
        }
    }
    
    private func createNotification(in second: Int, for accountName: String, object: Object, title: String, body: String) {
        let timeInterval = TimeInterval(second)
        let id = accountName + object.rawValue
        
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: timeInterval, repeats: false)
        let request = UNNotificationRequest(identifier: id, content: content, trigger: trigger)
        
        center.add(request)
    }
    
    private func createNotification(at date: DateComponents, for accountName: String, object: Object, title: String, body: String) {
        let id = accountName + object.rawValue
        
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: date, repeats: false)
        
        let request = UNNotificationRequest(identifier: id, content: content, trigger: trigger)
        
        center.add(request)
    }
    
    
    // TODO: 用UserDefault储存
    let allowResinNotification = true
    let resinNotificationTimeFromFull: Int = 60 * 60
    var resinNotificationTimeDescription: String { secondsToHoursMinutes(resinNotificationTimeFromFull) }
    
    func createResinNotification(for accountName: String, with resinInfo: ResinInfo) {
        guard resinInfo.recoveryTime.second > resinNotificationTimeFromFull else { return }
        guard allowResinNotification else { return }
        let title = "\(accountName)的树脂即将回满"
        let body = "\(accountName)的树脂还有\(resinNotificationTimeDescription)回满。"
        
        createNotification(
            in: resinInfo.recoveryTime.second - resinNotificationTimeFromFull,
            for: accountName,
            object: .resin,
            title: title,
            body: body
        )
    }
    
    
    let allowHomeCoinNotification = true
    let homeCoinNotificationTimeFromFull: Int = 60 * 60
    var homeCoinNotificationTimeDescription: String { secondsToHoursMinutes(homeCoinNotificationTimeFromFull) }
    
    func createHomeCoinNotification(for accountName: String, with homeCoinInfo: HomeCoinInfo) {
        guard homeCoinInfo.recoveryTime.second > homeCoinNotificationTimeFromFull else { return }
        guard allowHomeCoinNotification else { return }
        let title = "\(accountName)的洞天宝钱即将回满"
        let body = "\(accountName)的洞天宝钱还有\(homeCoinNotificationTimeDescription))回满。"
        
        createNotification(
            in: homeCoinInfo.recoveryTime.second - homeCoinNotificationTimeFromFull,
            for: accountName,
            object: .homeCoin,
            title: title,
            body: body
        )
    }
    
    
    let allowExpeditionNotification = true
    let expeditionNotificationTimeFromFinished: Int = 60 * 60
    var expeditionNotificationTimeDescription: String { secondsToHoursMinutes(expeditionNotificationTimeFromFinished) }
    let noticeExpeditionBy: ExpeditionNoticeMethod = .allCompleted
    
    func createExpeditionNotification(for accountName: String, with expeditionInfo: ExpeditionInfo) {
        guard expeditionInfo.allCompleteTime.second > expeditionNotificationTimeFromFinished else { return }
        guard allowExpeditionNotification else { return }
        let title = "\(accountName)的探索派遣即将全部完成"
        let body = "\(accountName)的探索派遣还有\(expeditionNotificationTimeDescription))回满。"
        
        createNotification(
            in: expeditionInfo.allCompleteTime.second - expeditionNotificationTimeFromFinished,
            for: accountName,
            object: .expedition,
            title: title,
            body: body
        )
    }
    
    
    let allowWeeklyBossesNotification = true
    let weeklyBossesNotificationTimePoint = DateComponents(hour: 7, weekday: 6)
    
    func createWeeklyBossesNotification(for accountName: String, with weeklyBossesInfo: WeeklyBossesInfo) {
        guard Date() < Calendar.current.nextDate(after: Date(), matching: weeklyBossesNotificationTimePoint, matchingPolicy: .nextTime)! else { return }
        guard weeklyBossesInfo.remainResinDiscountNum != 0 else { return }
        guard allowWeeklyBossesNotification else { return }
        let title = "\(accountName)的征讨领域树脂折扣还未用尽。"
        let body = "\(accountName)的征讨领域树脂折扣还有\(weeklyBossesInfo.remainResinDiscountNum))次。"
        
        createNotification(at: weeklyBossesNotificationTimePoint, for: accountName, object: .weeklyBosses, title: title, body: body)
    }
    
    let allowTransformerNotification = true
    let transformerNotificationTimeFromFinished: Int = 60 * 60
    var transformerNotificationTimeDescription: String { secondsToHoursMinutes(transformerNotificationTimeFromFinished) }
    
    func createTransformerNotification(for accountName: String, with transformerInfo: TransformerInfo) {
        guard transformerInfo.recoveryTime.second > transformerNotificationTimeFromFinished else { return }
        guard allowTransformerNotification else { return }
        let title = "\(accountName)的探索派遣即将全部完成"
        let body = "\(accountName)的探索派遣还有\(expeditionNotificationTimeDescription))回满。"
        
        createNotification(
            in: transformerInfo.recoveryTime.second - transformerNotificationTimeFromFinished,
            for: accountName,
            object: .transformer,
            title: title,
            body: body
        )
    }
    
    let allowDailyTaskNotification = true
    
    var dailyTaskNotificationDateComponents = DateComponents(hour: 19)
    
    func createDailyTaskNotification(for accountName: String, with dailyTaskInfo: DailyTaskInfo) {
        guard Date() < Calendar.current.nextDate(after: Date(), matching: dailyTaskNotificationDateComponents, matchingPolicy: .nextTime)! else { return }
        guard !dailyTaskInfo.isTaskRewardReceived else { return }
        guard allowWeeklyBossesNotification else { return }
        let title = "\(accountName)的每日委托奖励还未领取"
        let body = "\(accountName)的每日委托还剩\(dailyTaskInfo.totalTaskNum - dailyTaskInfo.finishedTaskNum))个未完成。"
        
        createNotification(at: weeklyBossesNotificationTimePoint, for: accountName, object: .dailyTask, title: title, body: body)
    }
    
    func deleteAllNotification(for accountName: String) {
        let removeIdentifiers: [String] = Object.allCases.map { object in
            accountName + object.rawValue
        }
        center.removeDeliveredNotifications(withIdentifiers: removeIdentifiers)
    }
    
    func createAllNotification(for accountName: String, with userData: UserData) {
        deleteAllNotification(for: accountName)
        createResinNotification(for: accountName, with: userData.resinInfo)
        createHomeCoinNotification(for: accountName, with: userData.homeCoinInfo)
        createExpeditionNotification(for: accountName, with: userData.expeditionInfo)
        createWeeklyBossesNotification(for: accountName, with: userData.weeklyBossesInfo)
        createTransformerNotification(for: accountName, with: userData.transformerInfo)
        createDailyTaskNotification(for: accountName, with: userData.dailyTaskInfo)
    }
    
}

enum Object: String, CaseIterable {
    case resin = "resin"
    case homeCoin = "homeCoin"
    case expedition = "expedition"
    case weeklyBosses = "weeklyBosses"
    case transformer = "transformer"
    case dailyTask = "dailyTask"
}
