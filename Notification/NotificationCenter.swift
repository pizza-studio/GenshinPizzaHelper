//
//  NotificationCenter.swift
//  GenshinPizzaHepler
//
//  Created by 戴藏龙 on 2022/8/20.
//  通知功能提供

import Defaults
import Foundation
import HoYoKit
import UserNotifications

class UserNotificationCenter {
    // MARK: Lifecycle

    private init() {
        center.setNotificationCategories([normalNotificationCategory])
    }

    // MARK: Internal

    enum Object: String, CaseIterable {
        case resin
        case resinFull
        case homeCoin
        case expedition
        case weeklyBosses
        case transformer
        case dailyTask
    }

    static let shared: UserNotificationCenter = .init()

    // Define the custom actions.
    let openGenshin = UNNotificationAction(
        identifier: "OPEN_GENSHIN_ACTION",
        title: "打开《原神》".localized,
        options: [.foreground]
    )
    let openNotificationSetting = UNNotificationAction(
        identifier: "OPEN_NOTIFICATION_SETTING_ACTION",
        title: "通知设置".localized,
        options: [.foreground]
    )
    let center = UNUserNotificationCenter.current()

    // Define the notification type
    var normalNotificationCategory: UNNotificationCategory {
        UNNotificationCategory(
            identifier: "NORMAL_NOTIFICATION",
            actions: [openGenshin, openNotificationSetting],
            intentIdentifiers: [],
            hiddenPreviewsBodyPlaceholder: "",
            options: .customDismissAction
        )
    }

    var ignoreUids: [String] {
        let data = Defaults[.notificationIgnoreUidsData]
        let ignoreUids: [String] = try! JSONDecoder()
            .decode([String].self, from: data)
        return ignoreUids
    }

    func printAllNotificationRequest() {
        let center = UNUserNotificationCenter.current()
        center.getPendingNotificationRequests(completionHandler: { requests in
            for request in requests {
                print(request)
                print(request.content.title, request.content.body)
            }
        })
    }

    func testNotification() {
        let timeInterval = TimeInterval(5)
        let id = "12345678"

        let content = createNotificationContent(
            object: .resin,
            title: "hi",
            body: "hh"
        )

        let trigger = UNTimeIntervalNotificationTrigger(
            timeInterval: timeInterval,
            repeats: false
        )
        let request = UNNotificationRequest(
            identifier: id,
            content: content,
            trigger: trigger
        )

        center.add(request)
        print(request)
        print("user notification: success create ")
    }

    func askPermission() {
        center
            .requestAuthorization(options: [
                .alert,
                .sound,
                .badge,
            ]) { _, error in
                if let error = error {
                    print(error.localizedDescription)
                }
            }
    }

    func deleteNotification(
        for uid: String,
        object: Object,
        idSuffix: String = ""
    ) {
        let id = uid + object.rawValue + idSuffix
        center.removePendingNotificationRequests(withIdentifiers: [id])
    }

    func deleteAllNotification() {
        center.getDeliveredNotifications { notifications in
            let ids = notifications.map { notification in
                notification.request.identifier
            }
            self.center.removePendingNotificationRequests(withIdentifiers: ids)
        }
    }

    func deleteAllNotification(for uid: String) {
        Object.allCases.forEach { object in
            center.getDeliveredNotifications { notifications in
                notifications.forEach { notification in
                    if notification.request.identifier
                        .contains(uid + object.rawValue) {
                        self.center
                            .removePendingNotificationRequests(
                                withIdentifiers: [
                                    notification
                                        .request.identifier,
                                ]
                            )
                    }
                }
            }
        }
    }

    func deleteAllNotification(object: Object) {
        center.getDeliveredNotifications { notifications in
            let ids = notifications.filter { notification in
                notification.request.identifier.contains(object.rawValue)
            }.map { notification in
                notification.request.identifier
            }
            self.center.removePendingNotificationRequests(withIdentifiers: ids)
        }
    }

    func createAllNotification(
        for accountName: String,
        with data: some DailyNote,
        uid: String
    ) {
        print("Creating all notification")
        guard !ignoreUids.contains(uid) else { return }
        createResinNotification(
            for: accountName,
            with: data.resinInformation,
            uid: uid
        )
        createFullResinNotification(
            for: accountName,
            with: data.resinInformation,
            uid: uid
        )
        createHomeCoinNotification(
            for: accountName,
            with: data.homeCoinInformation,
            uid: uid
        )
        createExpeditionNotification(
            for: accountName,
            with: data.expeditionInformation,
            uid: uid
        )
        createDailyTaskNotification(
            for: accountName,
            with: data.dailyTaskInformation,
            uid: uid
        )
        if let data = data as? GeneralDailyNote {
            createWeeklyBossesNotification(
                for: accountName,
                with: data.weeklyBossesInformation,
                uid: uid
            )
            createTransformerNotification(
                for: accountName,
                with: data.transformerInformation,
                uid: uid
            )
        }
    }

    // MARK: Private

//    private func imageURL(of object: Object) -> URL? {
//        switch object {
//        case .resin:
//            return Bundle.main.url(forResource: "树脂", withExtension: "png")
//        case .homeCoin:
//            return Bundle.main.url(forResource: "洞天宝钱", withExtension: "png")
//        case .expedition:
//            return Bundle.main.url(forResource: "派遣探索", withExtension: "png")
//        case .weeklyBosses:
//            return Bundle.main.url(forResource: "周本", withExtension: "png")
//        case .transformer:
//            return Bundle.main.url(forResource: "参量质变仪", withExtension: "png")
//        case .dailyTask:
//            return Bundle.main.url(forResource: "每日任务", withExtension: "png")
//        }
//    }

    // 树脂
    private var allowResinNotification: Bool {
        Defaults[.allowResinNotification]
    }

    private var resinNotificationNum: Double {
        Defaults[.resinNotificationNum]
    }

    private var allowFullResinNotification: Bool {
        Defaults[.allowFullResinNotification]
    }

    private var allowHomeCoinNotification: Bool {
        Defaults[.allowHomeCoinNotification]
    }

    private var homeCoinNotificationTimeFromFull: Int {
        Int(Defaults[.homeCoinNotificationHourBeforeFull]) * 60 * 60
    }

    private var homeCoinNotificationTimeDescription: String {
        relativeTimePointFromNow(second: homeCoinNotificationTimeFromFull)
    }

    private var allowExpeditionNotification: Bool {
        Defaults[.allowExpeditionNotification]
    }

    private var noticeExpeditionBy: ExpeditionNoticeMethod {
        .init(rawValue: Defaults[.noticeExpeditionMethodRawValue]) ?? .unknown
    }

    private var weeklyBossesNotificationTimePoint: DateComponents {
        let data = Defaults[.weeklyBossesNotificationTimePointData]
        let dateComponents = try! JSONDecoder()
            .decode(DateComponents.self, from: data)
        return dateComponents
    }

    private var allowTransformerNotification: Bool {
        Defaults[.allowTransformerNotification]
    }

    private var allowDailyTaskNotification: Bool {
        Defaults[.allowDailyTaskNotification]
    }

    private var dailyTaskNotificationDateComponents: DateComponents {
        let data = Defaults[.dailyTaskNotificationTimePointData]
        let dateComponents = try! JSONDecoder()
            .decode(DateComponents.self, from: data)
        return dateComponents
    }

    private func createNotificationContent(
        object: Object,
        title: String?,
        body: String
    )
        -> UNMutableNotificationContent {
        let content = UNMutableNotificationContent()
        if let title = title {
            content.title = title
        }
        content.body = body
        content.categoryIdentifier = "NORMAL_NOTIFICATION"
        content.sound = .default
        content.badge = 1

        return content
    }

    private func createNotification(
        in second: Int,
        for accountName: String,
        object: Object,
        title: String,
        body: String,
        uid: String,
        idSuffix: String = ""
    ) {
        guard second > 0 else { return }
        let timeInterval = TimeInterval(second)
        let id = uid + object.rawValue + idSuffix

        let content = createNotificationContent(
            object: object,
            title: title,
            body: body
        )

        let trigger = UNTimeIntervalNotificationTrigger(
            timeInterval: timeInterval,
            repeats: false
        )
        let request = UNNotificationRequest(
            identifier: id,
            content: content,
            trigger: trigger
        )

        center.add(request)
        print(request)
        print("user notification: success create ")
    }

    private func createNotification(
        at date: DateComponents,
        for accountName: String,
        object: Object,
        title: String,
        body: String,
        uid: String,
        idSuffix: String = ""
    ) {
        let id = uid + object.rawValue + idSuffix

        let content = createNotificationContent(
            object: object,
            title: title,
            body: body
        )

        print("Create User Notification on \(date)")
        let trigger = UNCalendarNotificationTrigger(
            dateMatching: date,
            repeats: false
        )

        let request = UNNotificationRequest(
            identifier: id,
            content: content,
            trigger: trigger
        )

        center.add(request)
        print("Adding user notification: \(request)")
    }

    private func createResinNotification(
        for accountName: String,
        with resinInfo: ResinInformation,
        uid: String
    ) {
        let resinNotificationTimeFromFull = (
            160 - Int(resinNotificationNum)
        ) * 8 * 60
        var resinNotificationTimeDescription: String {
            dateFormatter.string(from: resinInfo.resinRecoveryTime)
        }
        guard resinInfo.currentResin < Int(resinNotificationNum),
              allowResinNotification else {
            deleteNotification(for: uid, object: .resin); return
        }

        let titleCN = "「%@」原粹树脂提醒"
        let title = String(
            format: NSLocalizedString(titleCN, comment: "noti title"),
            accountName
        )
        let bodyCN = "「%@」现有%lld原粹树脂，将在%@ 回满。"
        let body = String(
            format: NSLocalizedString(bodyCN, comment: "noti body"),
            accountName,
            Int(resinNotificationNum),
            resinNotificationTimeDescription
        )
        createNotification(
            in: Int(TimeInterval.sinceNow(to: Calendar.current.date(byAdding: .second, value: -resinNotificationTimeFromFull, to: resinInfo.resinRecoveryTime)!)),
            for: accountName,
            object: .resin,
            title: title,
            body: body,
            uid: uid
        )
    }

    private func createFullResinNotification(
        for accountName: String,
        with resinInfo: ResinInformation,
        uid: String
    ) {
        guard resinInfo.currentResin < 160, allowFullResinNotification,
              allowResinNotification else {
            deleteNotification(for: uid, object: .resin); return
        }
        let titleCN = "notification.noticeForChar:%@"
        let title = String(
            format: NSLocalizedString(titleCN, comment: "noti title"),
            accountName
        )
        let bodyCN = "notification.filledFor:%@"
        let body = String(
            format: NSLocalizedString(bodyCN, comment: "noti body"),
            accountName
        )
        createNotification(
            in: Int(TimeInterval.sinceNow(to: resinInfo.resinRecoveryTime)),
            for: accountName,
            object: .resinFull,
            title: title,
            body: body,
            uid: uid
        )
    }

    private func createHomeCoinNotification(
        for accountName: String,
        with homeCoinInfo: HomeCoinInformation,
        uid: String
    ) {
        guard Int(TimeInterval.sinceNow(to: homeCoinInfo.fullTime
            )) > homeCoinNotificationTimeFromFull,
            allowHomeCoinNotification else {
            deleteNotification(for: uid, object: .homeCoin); return
        }
        guard allowHomeCoinNotification else { return }

        var currentHomeCoinWhenNotify: Int {
            let totalTime = TimeInterval.sinceNow(to: homeCoinInfo.fullTime)
            var recoveryPercentageWhenNotify: Double {
                1 - (Double(homeCoinNotificationTimeFromFull) / totalTime)
            }
            return Int(
                Double(homeCoinInfo.maxHomeCoin) *
                    recoveryPercentageWhenNotify
            )
        }

        let titleCN = "「%@」洞天宝钱提醒"
        let title = String(
            format: NSLocalizedString(titleCN, comment: "noti title"),
            accountName
        )
        let bodyCN = "「%@」的洞天财瓮现有%lld洞天宝钱，将在%@ 填满。"
        let body = String(
            format: NSLocalizedString(bodyCN, comment: "no body"),
            accountName,
            currentHomeCoinWhenNotify,
            homeCoinNotificationTimeDescription
        )

        createNotification(
            in: Int(TimeInterval.sinceNow(to: homeCoinInfo.fullTime)),
            for: accountName,
            object: .homeCoin,
            title: title,
            body: body,
            uid: uid
        )
    }

    private func createExpeditionNotification(
        for accountName: String,
        with expeditionInfo: some ExpeditionInformation,
        uid: String
    ) {
        guard let expeditionInfo = expeditionInfo as? GeneralDailyNote.ExpeditionInformation else {
            return
        }
        guard !expeditionInfo.allCompleted,
              allowExpeditionNotification else {
            deleteNotification(for: uid, object: .expedition); return
        }
        let object: Object = .expedition
        let titleCN = "「%@」探索派遣提醒"
        let title = String(
            format: NSLocalizedString(titleCN, comment: "noti title"),
            accountName
        )
        let bodyCN = "「%@」的探索派遣已全部完成。"
        let body = String(
            format: NSLocalizedString(bodyCN, comment: "noti body"),
            accountName
        )
        guard let allCompleteTime = expeditionInfo.expeditions.map(\.finishTime).max() else { return }
        createNotification(
            in: Int(TimeInterval.sinceNow(to: allCompleteTime)),
            for: accountName,
            object: object,
            title: title,
            body: body,
            uid: uid
        )
    }

    private func createWeeklyBossesNotification(
        for accountName: String,
        with weeklyBossesInfo: GeneralDailyNote.WeeklyBossesInformation,
        uid: String
    ) {
        guard Date() < Calendar.current.nextDate(
            after: Date(),
            matching: weeklyBossesNotificationTimePoint,
            matchingPolicy: .nextTime
        )! else { return }
        guard weeklyBossesInfo.remainResinDiscount != 0 else {
            deleteNotification(for: uid, object: .weeklyBosses); return
        }
        guard Defaults[.allowWeeklyBossesNotification] else { return }
        let titleCN = "「%@」周本折扣提醒"
        let title = String(
            format: NSLocalizedString(titleCN, comment: "notification title"),
            accountName
        )
        let bodyCN = "「%@」的周本树脂折扣树脂折扣还剩%lld次。"
        let body = String(
            format: NSLocalizedString(bodyCN, comment: "notification body"),
            accountName,
            weeklyBossesInfo.remainResinDiscount
        )

        createNotification(
            at: weeklyBossesNotificationTimePoint,
            for: accountName,
            object: .weeklyBosses,
            title: title,
            body: body,
            uid: uid
        )
    }

    private func createTransformerNotification(
        for accountName: String,
        with transformerInfo: GeneralDailyNote.TransformerInformation,
        uid: String
    ) {
        guard transformerInfo.recoveryTime > Date(), allowTransformerNotification,
              transformerInfo.obtained else {
            deleteNotification(for: uid, object: .transformer); return
        }
        let titleCN = "「%@」参量质变仪提醒"
        let title = String(
            format: NSLocalizedString(titleCN, comment: "notification title"),
            accountName
        )
        let bodyCN = "「%@」的参量质变仪已经可以使用。"
        let body = String(
            format: NSLocalizedString(bodyCN, comment: "body"),
            accountName
        )
        let object: Object = .transformer

        createNotification(
            in: Int(TimeInterval.sinceNow(to: transformerInfo.recoveryTime)),
            for: accountName,
            object: object,
            title: title,
            body: body,
            uid: uid
        )
    }

    private func createDailyTaskNotification(
        for accountName: String,
        with dailyTaskInfo: DailyTaskInformation,
        uid: String
    ) {
        guard Date() < Calendar.current.nextDate(
            after: Date(),
            matching: dailyTaskNotificationDateComponents,
            matchingPolicy: .nextTime
        )! else { return }
        guard !dailyTaskInfo.isExtraRewardReceived else {
            deleteNotification(for: uid, object: .dailyTask); return
        }
        guard allowDailyTaskNotification else { return }
        let titleCN = "「%@」每日委托提醒"
        let title = String(
            format: NSLocalizedString(titleCN, comment: "noti title"),
            accountName
        )
        var body: String {
            if dailyTaskInfo.totalTaskCount - dailyTaskInfo.finishedTaskCount != 0 {
                let cn = "「%@」的每日委托还剩余%lld个未完成。"
                return String(
                    format: NSLocalizedString(cn, comment: "cn"),
                    accountName,
                    dailyTaskInfo.totalTaskCount - dailyTaskInfo.finishedTaskCount
                )
            } else {
                let cn = "「%@」的每日委托奖励还未领取。"
                return String(
                    format: NSLocalizedString(cn, comment: "cn"),
                    accountName
                )
            }
        }

        createNotification(
            at: dailyTaskNotificationDateComponents,
            for: accountName,
            object: .dailyTask,
            title: title,
            body: body,
            uid: uid
        )
    }
}

private let dateFormatter: DateFormatter = {
    let dateFormatter = DateFormatter.Gregorian()
    dateFormatter.dateStyle = .short
    dateFormatter.timeStyle = .short
    dateFormatter.doesRelativeDateFormatting = true
    dateFormatter.locale = Locale(identifier: Locale.current.identifier)
    return dateFormatter
}()

extension TimeInterval {
    static func sinceNow(to date: Date) -> Self {
        return date.timeIntervalSinceReferenceDate - Date().timeIntervalSinceReferenceDate
    }

    static func toNow(from date: Date) -> Self {
        return Date().timeIntervalSinceReferenceDate - date.timeIntervalSinceReferenceDate
    }

    init(from dateA: Date, to dateB: Date) {
        self = dateB.timeIntervalSinceReferenceDate - dateA.timeIntervalSinceReferenceDate
    }
}
