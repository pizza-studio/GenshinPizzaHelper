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
    
    let userDefaults = UserDefaults(suiteName: "group.GenshinPizzaHelper")
    
    private init() {
        if !(userDefaults?.bool(forKey: "notificationCenterInited") ?? false) {
            if let userDefaults = userDefaults {
                userDefaults.set(true, forKey: "notificationCenterInited")
                userDefaults.set(true, forKey: "allowResinNotification")
                userDefaults.set(150.0, forKey: "resinNotificationNum")
                userDefaults.set(true, forKey: "allowHomeCoinNotification")
                userDefaults.set(8.0, forKey: "homeCoinNotificationHourBeforeFull")
                userDefaults.set(true, forKey: "allowExpeditionNotification")
                userDefaults.set(1, forKey: "noticeExpeditionMethodRawValue")
                userDefaults.set(true, forKey: "allowWeeklyBossesNotification")
                userDefaults.set((try! JSONEncoder().encode(DateComponents(calendar: .current, hour: 19, minute: 0, weekday: 7))), forKey: "weeklyBossesNotificationTimePointData")
                userDefaults.set(true, forKey: "allowTransformerNotification")
                userDefaults.set(true, forKey: "allowDailyTaskNotification")
                userDefaults.set((try! JSONEncoder().encode(DateComponents(calendar: .current, hour: 19, minute: 0))), forKey: "dailyTaskNotificationTimePointData")
            }
        }
        
    }
    
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
        
        print("Create User Notification on \(date)")
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
    
    
    var allowResinNotification: Bool {
        userDefaults?.bool(forKey: "allowResinNotification") ?? true
    }
    var resinNotificationNum: Double {
        userDefaults?.double(forKey: "resinNotificationNum") ?? 150
    }
    var resinNotificationTimeFromFull: Int { Int(resinNotificationNum * 8 * 60) }
    var resinNotificationTimeDescription: String { secondsToHoursMinutes(resinNotificationTimeFromFull) }
    
    func createResinNotification(for accountName: String, with resinInfo: ResinInfo, uid: String) {
        print("creating resin user notification")
        print("\(resinInfo.recoveryTime.second)")
        print("\(resinNotificationTimeFromFull)")
        print("\(allowResinNotification)")
        guard resinInfo.recoveryTime.second > resinNotificationTimeFromFull else { return }
        guard allowResinNotification else { return }
        
        let title = "「\(accountName)」的原萃树脂即将回满"
        let body = "「\(accountName)」的原萃树脂，将在\(resinNotificationTimeDescription)后回满。"
        createNotification(
            in: resinInfo.recoveryTime.second - resinNotificationTimeFromFull,
            for: accountName,
            object: .resin,
            title: title,
            body: body,
            uid: uid
        )
    }
    
    
    var allowHomeCoinNotification: Bool {
        userDefaults?.bool(forKey: "allowHomeCoinNotification") ?? true
    }
    var homeCoinNotificationHourBeforeFull: Double {
        userDefaults?.double(forKey: "homeCoinNotificationHourBeforeFull") ?? 8
    }
    var homeCoinNotificationTimeFromFull: Int {
        Int(homeCoinNotificationHourBeforeFull * 60 * 60)
    }
    var homeCoinNotificationTimeDescription: String { secondsToHoursMinutes(homeCoinNotificationTimeFromFull) }
    
    func createHomeCoinNotification(for accountName: String, with homeCoinInfo: HomeCoinInfo, uid: String) {
        print("creating home coin user notification")
        print("\(homeCoinInfo.recoveryTime.second)")
        print("\(homeCoinNotificationTimeFromFull)")
        print("\(allowHomeCoinNotification)")
        guard homeCoinInfo.recoveryTime.second > homeCoinNotificationTimeFromFull else { return }
        guard allowHomeCoinNotification else { return }
        let title = "「\(accountName)」的洞天财瓮即将填满"
        let body = "「\(accountName)」的洞天财瓮即将将在\(homeCoinNotificationTimeDescription)后填满。"
        
        createNotification(
            in: homeCoinInfo.recoveryTime.second - homeCoinNotificationTimeFromFull,
            for: accountName,
            object: .homeCoin,
            title: title,
            body: body,
            uid: uid
        )
    }
    
    
    var allowExpeditionNotification: Bool {
        userDefaults?.bool(forKey: "allowExpeditionNotification") ?? true
    }
    var noticeExpeditionBy: ExpeditionNoticeMethod {
        .init(rawValue: userDefaults?.integer(forKey: "noticeExpeditionMethodRawValue") ?? 1)!
    }
    // TODO: 探索派遣提醒方式
    func createExpeditionNotification(for accountName: String, with expeditionInfo: ExpeditionInfo, uid: String) {
        guard !expeditionInfo.allCompleted && allowExpeditionNotification else { return }
        let object: Object = .expedition
        let title = "「\(accountName)」的探索派遣已全部完成"
        let body = "「\(accountName)」的探索派遣已全部完成。"
        
        createNotification(in: expeditionInfo.allCompleteTime.second, for: accountName, object: object, title: title, body: body, uid: uid)
    }
    
    
    var allowWeeklyBossesNotification: Bool {
        userDefaults?.bool(forKey: "allowWeeklyBossesNotification") ?? true
    }
    var weeklyBossesNotificationTimePoint: DateComponents {
        let data = userDefaults?.data(forKey: "weeklyBossesNotificationTimePointData") ?? (try! JSONEncoder().encode(DateComponents(calendar: .current, hour: 19, minute: 0, weekday: 7)))
        let dateComponents = try! JSONDecoder().decode(DateComponents.self, from: data)
        return dateComponents
    }
    
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
    
    
    
    var allowTransformerNotification: Bool {
        userDefaults?.bool(forKey: "allowTransformerNotification") ?? true
    }
    
    func createTransformerNotification(for accountName: String, with transformerInfo: TransformerInfo, uid: String) {
        guard !transformerInfo.isComplete && allowTransformerNotification && transformerInfo.obtained else { return }
        let title = "「\(accountName)」的参量质变仪已经可以使用"
        let body = "「\(accountName)」的参量质变仪已经可以使用。"
        let object: Object = .transformer
        
        createNotification(in: transformerInfo.recoveryTime.second, for: accountName, object: object, title: title, body: body, uid: uid)
        
    }
    
    
    var allowDailyTaskNotification: Bool {
        userDefaults?.bool(forKey: "allowDailyTaskNotification") ?? true
    }
    var dailyTaskNotificationDateComponents: DateComponents {
        let data = userDefaults?.data(forKey: "dailyTaskNotificationTimePointData") ?? (try! JSONEncoder().encode(DateComponents(calendar: .current, hour: 19, minute: 0)))
        let dateComponents = try! JSONDecoder().decode(DateComponents.self, from: data)
        return dateComponents
    }
    
    func createDailyTaskNotification(for accountName: String, with dailyTaskInfo: DailyTaskInfo, uid: String) {
        guard Date() < Calendar.current.nextDate(after: Date(), matching: dailyTaskNotificationDateComponents, matchingPolicy: .nextTime)! else { return }
        guard !dailyTaskInfo.isTaskRewardReceived else {
            deleteNotification(for: accountName, object: .dailyTask); return
        }
        guard allowDailyTaskNotification else { return }
        let title = "「\(accountName)」的每日委托奖励还未领取"
        let body = "「\(accountName)」的每日委托还剩余\(dailyTaskInfo.totalTaskNum - dailyTaskInfo.finishedTaskNum)个未完成。"
        
        createNotification(at: dailyTaskNotificationDateComponents, for: accountName, object: .dailyTask, title: title, body: body, uid: uid)
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
        print("Creating all notification")
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
