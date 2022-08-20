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
        content.subtitle = body
        
        if let url = imageURL(of: object) {
            content.attachments = [try! UNNotificationAttachment(identifier: object.rawValue, url: url)]
        }
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: date, repeats: false)
        
        let request = UNNotificationRequest(identifier: id, content: content, trigger: trigger)
        
        center.add(request)
        print("success create user notification")
    }
    
    func imageURL(of object: Object) -> URL? {
        switch object {
        case .resin:
            return Bundle.main.url(forResource: "树脂", withExtension: "png")
        case .homeCoin:
            return Bundle.main.url(forResource: "洞天宝钱", withExtension: "png")
        case .expedition:
            return Bundle.main.url(forResource: "派遣探索", withExtension: "png")
        case .weeklyBosses:
            return Bundle.main.url(forResource: "周本", withExtension: "png")
        case .transformer:
            return Bundle.main.url(forResource: "参量质变仪", withExtension: "png")
        case .dailyTask:
            return Bundle.main.url(forResource: "每日任务", withExtension: "png")
        }
    }
    
    // TODO: 用UserDefault储存
    let allowResinNotification = true
    let resinNotificationTimeFromFull: Int = 545
    var resinNotificationTimeDescription: String { secondsToHoursMinutes(resinNotificationTimeFromFull) }
    
    func createResinNotification(for accountName: String, with resinInfo: ResinInfo) {
        print("creating resin user notification")
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
    let noticeExpeditionBy: ExpeditionNoticeMethod = .allCompleted
    
    func createExpeditionNotification(for accountName: String, with expeditionInfo: ExpeditionInfo) {
        guard !expeditionInfo.allCompleted && allowExpeditionNotification else { return }
        let object: Object = .expedition
        let title = "\(accountName)的探索派遣已全部完成"
        let body = "\(accountName)的探索派遣已全部完成。"
        
        createNotification(in: expeditionInfo.allCompleteTime.second, for: accountName, object: object, title: title, body: body)
    }
    
    
    let allowWeeklyBossesNotification = true
    let weeklyBossesNotificationTimePoint = DateComponents(hour: 7, weekday: 6)
    
    func createWeeklyBossesNotification(for accountName: String, with weeklyBossesInfo: WeeklyBossesInfo) {
        guard Date() < Calendar.current.nextDate(after: Date(), matching: weeklyBossesNotificationTimePoint, matchingPolicy: .nextTime)! else { return }
        guard weeklyBossesInfo.remainResinDiscountNum != 0 else {
            deleteNotification(for: accountName, object: .weeklyBosses); return
        }
        guard allowWeeklyBossesNotification else { return }
        let title = "\(accountName)的征讨领域树脂折扣还未用尽。"
        let body = "\(accountName)的征讨领域树脂折扣还有\(weeklyBossesInfo.remainResinDiscountNum))次。"
        
        createNotification(at: weeklyBossesNotificationTimePoint, for: accountName, object: .weeklyBosses, title: title, body: body)
    }
    
    let allowTransformerNotification = true
    
    func createTransformerNotification(for accountName: String, with transformerInfo: TransformerInfo) {
        guard !transformerInfo.isComplete && allowTransformerNotification else { return }
        let title = "\(accountName)的参量质变仪已经可以使用"
        let body = "\(accountName)的参量质变仪已经可以使用。"
        let object: Object = .transformer
        
        createNotification(in: transformerInfo.recoveryTime.second, for: accountName, object: object, title: title, body: body)
        
    }
    
    let allowDailyTaskNotification = true
    
    var dailyTaskNotificationDateComponents = DateComponents(hour: 19)
    
    func createDailyTaskNotification(for accountName: String, with dailyTaskInfo: DailyTaskInfo) {
        guard Date() < Calendar.current.nextDate(after: Date(), matching: dailyTaskNotificationDateComponents, matchingPolicy: .nextTime)! else { return }
        guard !dailyTaskInfo.isTaskRewardReceived else {
            deleteNotification(for: accountName, object: .dailyTask); return
        }
        guard allowWeeklyBossesNotification else { return }
        let title = "\(accountName)的每日委托奖励还未领取"
        let body = "\(accountName)的每日委托还剩\(dailyTaskInfo.totalTaskNum - dailyTaskInfo.finishedTaskNum))个未完成。"
        
        createNotification(at: weeklyBossesNotificationTimePoint, for: accountName, object: .dailyTask, title: title, body: body)
    }
    
    func deleteNotification(for accountName: String, object: Object) {
        let id = accountName + object.rawValue
        center.removePendingNotificationRequests(withIdentifiers: [id])
    }
    
    
    func deleteAllNotification(for accountName: String) {
        let removeIdentifiers: [String] = Object.allCases.map { object in
            accountName + object.rawValue
        }
        center.removePendingNotificationRequests(withIdentifiers: removeIdentifiers)
    }
    
    func createAllNotification(for accountName: String, with userData: UserData) {
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
