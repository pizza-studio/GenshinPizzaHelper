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
    
    func createNotificationContent(object: Object, title: String?, body: String) -> UNMutableNotificationContent {
        let content = UNMutableNotificationContent()
        if let title = title {
            content.title = title
        }
        content.body = body
        
//        if let url = imageURL(of: object) {
//            do {
//                let attachment = try UNNotificationAttachment(identifier: object.rawValue, url: url)
//                content.attachments = [attachment]
//                print("user notification: attach image success")
//            } catch {
//                print(error)
//            }
//        }
        
        return content
    }
    
    private func createNotification(in second: Int, for accountName: String, object: Object, title: String, body: String, uid: String) {
        let timeInterval = TimeInterval(second)
        let id = uid + object.rawValue
        
        let content = createNotificationContent(object: object, title: title, body: body)
                
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: timeInterval, repeats: false)
        let request = UNNotificationRequest(identifier: id, content: content, trigger: trigger)
        
        center.add(request)
        print(request)
        print("user notification: success create ")
    }
    
    func createNotification(at date: DateComponents, for accountName: String, object: Object, title: String, body: String, uid: String) {
        let id = uid + object.rawValue
        
        let content = createNotificationContent(object: object, title: title, body: body)
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: date, repeats: false)
        
        let request = UNNotificationRequest(identifier: id, content: content, trigger: trigger)
        
        center.add(request)
        print("Adding user notification: \(request)")
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
    
    func createResinNotification(for accountName: String, with resinInfo: ResinInfo, uid: String) {
        print("creating resin user notification")
        guard resinInfo.recoveryTime.second > resinNotificationTimeFromFull else { return }
        guard allowResinNotification else { return }
        let title = "「\(accountName)」的原萃树脂即将回满"
        let body = "「\(accountName)」现有\(resinInfo.currentResin)个原萃树脂，将在\(resinNotificationTimeDescription)后回满。"
        createNotification(
            in: resinInfo.recoveryTime.second - resinNotificationTimeFromFull,
            for: accountName,
            object: .resin,
            title: title,
            body: body,
            uid: uid
        )
    }
    
    
    let allowHomeCoinNotification = true
    let homeCoinNotificationTimeFromFull: Int = 60 * 60
    var homeCoinNotificationTimeDescription: String { secondsToHoursMinutes(homeCoinNotificationTimeFromFull) }
    
    func createHomeCoinNotification(for accountName: String, with homeCoinInfo: HomeCoinInfo, uid: String) {
        guard homeCoinInfo.recoveryTime.second > homeCoinNotificationTimeFromFull else { return }
        guard allowHomeCoinNotification else { return }
        let title = "「\(accountName)」的洞天财瓮即将填满"
        let body = "「\(accountName)」现有\(homeCoinInfo.currentHomeCoin)个洞天宝钱，将在\(homeCoinNotificationTimeDescription)后回满。"
        
        createNotification(
            in: homeCoinInfo.recoveryTime.second - homeCoinNotificationTimeFromFull,
            for: accountName,
            object: .homeCoin,
            title: title,
            body: body,
            uid: uid
        )
    }
    
    
    let allowExpeditionNotification = true
    let noticeExpeditionBy: ExpeditionNoticeMethod = .allCompleted
    
    func createExpeditionNotification(for accountName: String, with expeditionInfo: ExpeditionInfo, uid: String) {
        guard !expeditionInfo.allCompleted && allowExpeditionNotification else { return }
        let object: Object = .expedition
        let title = "「\(accountName)」的探索派遣已全部完成"
        let body = "「\(accountName)」的探索派遣已全部完成。"
        
        createNotification(in: expeditionInfo.allCompleteTime.second, for: accountName, object: object, title: title, body: body, uid: uid)
    }
    
    
    let allowWeeklyBossesNotification = true
    let weeklyBossesNotificationTimePoint = DateComponents(hour: 7, weekday: 6)
    
    func createWeeklyBossesNotification(for accountName: String, with weeklyBossesInfo: WeeklyBossesInfo, uid: String) {
        guard Date() < Calendar.current.nextDate(after: Date(), matching: weeklyBossesNotificationTimePoint, matchingPolicy: .nextTime)! else { return }
        guard weeklyBossesInfo.remainResinDiscountNum != 0 else {
            deleteNotification(for: accountName, object: .weeklyBosses); return
        }
        guard allowWeeklyBossesNotification else { return }
        let title = "「\(accountName)」的周本树脂折扣还未用尽。"
        let body = "「\(accountName)」的周本树脂折扣树脂折扣还剩\(weeklyBossesInfo.remainResinDiscountNum))次。"
        
        createNotification(at: weeklyBossesNotificationTimePoint, for: accountName, object: .weeklyBosses, title: title, body: body, uid: uid)
    }
    
    
    
    let allowTransformerNotification = true
    
    func createTransformerNotification(for accountName: String, with transformerInfo: TransformerInfo, uid: String) {
        guard !transformerInfo.isComplete && allowTransformerNotification else { return }
        let title = "「\(accountName)」的参量质变仪已经可以使用"
        let body = "「\(accountName)」的参量质变仪已经可以使用。"
        let object: Object = .transformer
        
        createNotification(in: transformerInfo.recoveryTime.second, for: accountName, object: object, title: title, body: body, uid: uid)
        
    }
    
    
    
    let allowDailyTaskNotification = true
    var dailyTaskNotificationDateComponents = DateComponents(hour: 13, minute: 50)
    
    func createDailyTaskNotification(for accountName: String, with dailyTaskInfo: DailyTaskInfo, uid: String) {
        guard Date() < Calendar.current.nextDate(after: Date(), matching: dailyTaskNotificationDateComponents, matchingPolicy: .nextTime)! else { return }
        guard !dailyTaskInfo.isTaskRewardReceived else {
            deleteNotification(for: accountName, object: .dailyTask); return
        }
        guard allowWeeklyBossesNotification else { return }
        let title = "「\(accountName)」的每日委托奖励还未领取"
        let body = "「\(accountName)」的每日委托还剩余\(dailyTaskInfo.totalTaskNum - dailyTaskInfo.finishedTaskNum))个未完成。"
        
        createNotification(at: weeklyBossesNotificationTimePoint, for: accountName, object: .dailyTask, title: title, body: body, uid: uid)
    }
    
    func deleteNotification(for uid: String, object: Object) {
        let id = uid + object.rawValue
        center.removePendingNotificationRequests(withIdentifiers: [id])
    }
    
    
    func deleteAllNotification(for uid: String) {
        let removeIdentifiers: [String] = Object.allCases.map { object in
            uid + object.rawValue
        }
        center.removePendingNotificationRequests(withIdentifiers: removeIdentifiers)
    }
    
    func createAllNotification(for accountName: String, with userData: UserData, uid: String) {
        createResinNotification(for: accountName, with: userData.resinInfo, uid: uid)
        createHomeCoinNotification(for: accountName, with: userData.homeCoinInfo, uid: uid)
        createExpeditionNotification(for: accountName, with: userData.expeditionInfo, uid: uid)
        createWeeklyBossesNotification(for: accountName, with: userData.weeklyBossesInfo, uid: uid)
        createTransformerNotification(for: accountName, with: userData.transformerInfo, uid: uid)
        createDailyTaskNotification(for: accountName, with: userData.dailyTaskInfo, uid: uid)
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
