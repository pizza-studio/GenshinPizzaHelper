//
//  File.swift
//
//
//  Created by 戴藏龙 on 2023/10/8.
//

import Defaults
import Foundation

extension UserDefaults {
    public static let opSuite = UserDefaults(suiteName: "group.GenshinPizzaHelper") ?? .standard
}

extension Defaults.Keys {
    // MARK: - Shared

    public static let appTabIndex = Key<Int>("appTabIndex", default: 0, suite: .opSuite)
    public static let restoreTabOnLaunching = Key<Bool>("restoreTabOnLaunching", default: true, suite: .opSuite)
    public static let checkedNewestVersion = Key<Int>("checkedNewestVersion", default: 0, suite: .opSuite)
    public static let checkedUpdateVersions = Key<[Int]>("checkedUpdateVersions", default: .init(), suite: .opSuite)
    public static let defaultServer = Key<String>("defaultServer", default: "Asia", suite: .opSuite)
    public static let pinToTopAccountUUIDString = Key<String>("pinToTopAccountUUIDString", default: "", suite: .opSuite)
    public static let lastVersionPromptedForReviewKey = Key<String?>(
        "lastVersionPromptedForReviewKey",
        default: nil,
        suite: .opSuite
    )
    public static let detailPortalViewShowingAccountUUIDString = Key<String?>(
        "detailPortalViewShowingAccountUUIDString",
        default: nil,
        suite: .opSuite
    )

    // MARK: - Account & Privacy & Policy

    public static let cachedCostumeMap = Key<[Int: Int]>("cachedDostumeMap", default: [:], suite: .opSuite)
    public static let allowAbyssDataCollection = Key<Bool>("allowAbyssDataCollection", default: false, suite: .opSuite)
    public static let hasAskedAllowAbyssDataCollection = Key<Bool>(
        "hasAskedAllowAbyssDataCollection",
        default: false,
        suite: .opSuite
    )
    public static let isPolicyShown = Key<Bool>("isPolicyShown", default: false, suite: .opSuite)
//    public static let deviceFingerPrint = Key<String>("device_finger_print", default: "", suite: .opSuite)
    public static let hasUploadedAvatarHoldingDataMD5 = Key<[String]>(
        "hasUploadedAvatarHoldingDataMD5",
        default: .init(),
        suite: .opSuite
    )
    public static let hasUploadedAbyssDataAccountAndSeasonMD5 = Key<[String]>(
        "hasUploadedAbyssDataAccountAndSeasonMD5",
        default: .init(),
        suite: .opSuite
    )

    // MARK: - HTTPMethods, Reverse Proxy, etc.

    public static let useProxy = Key<Bool>("useProxy", default: false, suite: .opSuite)
    public static let proxyHost = Key<String>("proxyHost", default: "", suite: .opSuite)
    public static let proxyPort = Key<String>("proxyPort", default: "", suite: .opSuite)
    public static let proxyUserName = Key<String>("proxyUserName", default: "", suite: .opSuite)
    public static let proxyUserPassword = Key<String>("proxyUserPassword", default: "", suite: .opSuite)
    public static let reverseProxyHost1 = Key<String>("reverseProxyHost1", default: "", suite: .opSuite)
    public static let reverseProxyHost2 = Key<String>("reverseProxyHost2", default: "", suite: .opSuite)
    public static let reverseProxyHost3 = Key<String>("reverseProxyHost3", default: "", suite: .opSuite)
    public static let reverseProxyHost4 = Key<String>("reverseProxyHost4", default: "", suite: .opSuite)
    public static let reverseProxyHost5 = Key<String>("reverseProxyHost5", default: "", suite: .opSuite)

    // MARK: - MainWidgetProvider

    public static let mainWidgetSyncFrequencyInMinute = Key<Double>(
        "mainWidgetSyncFrequencyInMinute",
        default: 60,
        suite: .opSuite
    )
    public static let lockscreenWidgetSyncFrequencyInMinute = Key<Double>(
        "lockscreenWidgetSyncFrequencyInMinute",
        default: 60,
        suite: .opSuite
    )
    public static let lockscreenWidgetRefreshFrequencyInMinute = Key<Double>(
        "lockscreenWidgetRefreshFrequencyInMinute",
        default: 30,
        suite: .opSuite
    )
    public static let homeCoinRefreshFrequencyInHour = Key<Double>(
        "homeCoinRefreshFrequencyInHour",
        default: 30,
        suite: .opSuite
    )
    public static let watchWidgetUseSimplifiedMode = Key<Bool>(
        "watchWidgetUseSimplifiedMode",
        default: true,
        suite: .opSuite
    )

    // MARK: - ResinRecoveryActivityController

    public static let autoDeliveryResinTimerLiveActivity = Key<Bool>(
        "autoDeliveryResinTimerLiveActivity",
        default: false,
        suite: .opSuite
    )
    public static let resinRecoveryLiveActivityShowExpedition = Key<Bool>(
        "resinRecoveryLiveActivityShowExpedition",
        default: true,
        suite: .opSuite
    )
    public static let resinRecoveryLiveActivityBackgroundOptions =
        Key<[String]>("resinRecoveryLiveActivityBackgroundOptions", default: .init(), suite: .opSuite)
    public static let autoUpdateResinRecoveryTimerUsingReFetchData =
        Key<Bool>("autoUpdateResinRecoveryTimerUsingReFetchData", default: true, suite: .opSuite)
    public static let resinRecoveryLiveActivityUseEmptyBackground =
        Key<Bool>("resinRecoveryLiveActivityUseEmptyBackground", default: false, suite: .opSuite)
    public static let resinRecoveryLiveActivityUseCustomizeBackground =
        Key<Bool>("resinRecoveryLiveActivityUseCustomizeBackground", default: false, suite: .opSuite)

    // MARK: - UserNotificationCenter

    public static let allowResinNotification = Key<Bool>("allowResinNotification", default: true, suite: .opSuite)
    // 得保留「resinNotificationNum」原始 rawValue 命名，不然无法继承用户既有设定。
    public static let resinNotificationThreshold = Key<Double>(
        "resinNotificationNum",
        default: 180,
        suite: .opSuite
    )
    public static let allowFullResinNotification = Key<Bool>(
        "allowFullResinNotification",
        default: true,
        suite: .opSuite
    )
    public static let allowHomeCoinNotification = Key<Bool>("allowHomeCoinNotification", default: true, suite: .opSuite)
    public static let homeCoinNotificationHourBeforeFull = Key<Double>(
        "homeCoinNotificationHourBeforeFull",
        default: 8,
        suite: .opSuite
    )
    public static let allowExpeditionNotification = Key<Bool>(
        "allowExpeditionNotification",
        default: true,
        suite: .opSuite
    )
    public static let noticeExpeditionMethodRawValue = Key<Int>(
        "noticeExpeditionMethodRawValue",
        default: 1,
        suite: .opSuite
    )
    public static let allowWeeklyBossesNotification = Key<Bool>(
        "allowWeeklyBossesNotification",
        default: true,
        suite: .opSuite
    )
    public static let allowTransformerNotification = Key<Bool>(
        "allowTransformerNotification",
        default: true,
        suite: .opSuite
    )
    public static let allowDailyTaskNotification = Key<Bool>(
        "allowDailyTaskNotification",
        default: true,
        suite: .opSuite
    )

    public static let weeklyBossesNotificationTimePointData = Key<Data>(
        "weeklyBossesNotificationTimePointData",
        default: try! JSONEncoder().encode(DateComponents(
            calendar: Calendar.current,
            hour: 19,
            minute: 0,
            weekday: 7
        )),
        suite: .opSuite
    )

    public static let dailyTaskNotificationTimePointData = Key<Data>(
        "dailyTaskNotificationTimePointData",
        default: try! JSONEncoder().encode(DateComponents(calendar: Calendar.current, hour: 19, minute: 0)),
        suite: .opSuite
    )

    public static let notificationIgnoreUidsData = Key<Data>(
        "notificationIgnoreUidsData",
        default: try! JSONEncoder().encode([String]()),
        suite: .opSuite
    )

    // MARK: - Display Options

    public static let adaptiveSpacingInCharacterView =
        Key<Bool>("adaptiveSpacingInCharacterView", default: true, suite: .opSuite)
    public static let showRarityAndLevelForArtifacts =
        Key<Bool>("showRarityAndLevelForArtifacts", default: true, suite: .opSuite)
    public static let forceCharacterWeaponNameFixed =
        Key<Bool>("forceCharacterWeaponNameFixed", default: false, suite: .opSuite)
    public static let useActualCharacterNames =
        Key<Bool>("useActualCharacterNames", default: false, suite: .opSuite)
    public static let customizedNameForWanderer =
        Key<String>("customizedNameForWanderer", default: .init(), suite: .opSuite)
    public static let cutShouldersForSmallAvatarPhotos =
        Key<Bool>("cutShouldersForSmallAvatarPhotos", default: false, suite: .opSuite)
    public static let useGuestGachaEvaluator =
        Key<Bool>("useGuestGachaEvaluator", default: false, suite: .opSuite)
    public static let animateOnCallingCharacterShowcase =
        Key<Bool>("animateOnCallingCharacterShowcase", default: true, suite: .opSuite)
}
