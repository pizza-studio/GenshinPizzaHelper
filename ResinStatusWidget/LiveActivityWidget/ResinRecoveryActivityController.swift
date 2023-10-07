//
//  ResinRecoveryActivityController.swift
//  GenshinPizzaHepler
//
//  Created by 戴藏龙 on 2022/11/19.
//

#if canImport(ActivityKit)
import ActivityKit
import Foundation
import HBMihoyoAPI
import SwiftUI // 这里用 AppStorage 更省事。哪怕其 binding 特性不起作用，也用不到 binding。

@available(iOS 16.1, *)
class ResinRecoveryActivityController {
    // MARK: Lifecycle

    private init() {
        if let userDefault =
            UserDefaults(suiteName: "group.GenshinPizzaHelper") {
            userDefault.register(
                defaults: [
                    "resinRecoveryLiveActivityShowExpedition": true,
                    "resinRecoveryLiveActivityBackgroundOptions": "[]",
                    "autoUpdateResinRecoveryTimerUsingReFetchData": true,
                ]
            )
        }
        Self.backgroundSettingsSanityCheck()
    }

    // MARK: Public

    public static func backgroundSettingsSanityCheck() {
        let backgrounds = resinRecoveryLiveActivityBackgroundOptions
        guard !backgrounds.isEmpty else { return }
        let allValidValues = NameCard.allLegalCases.map(\.fileName)
        var valuesToKeep = [String]()
        var insaneValueFound = false
        for entry in backgrounds {
            guard !allValidValues.contains(entry) else { continue }
            // 之前的剔除方法无效，现在改了判定规则：
            // 只要发现不合规的 UserDefault 资料，那就全部清空。
            resinRecoveryLiveActivityBackgroundOptions.removeAll()
            return
        }
    }

    // MARK: Internal

    static let shared: ResinRecoveryActivityController = .init()

    @AppStorage(
        "resinRecoveryLiveActivityBackgroundOptions",
        store: UserDefaults(suiteName: "group.GenshinPizzaHelper")
    )
    static var resinRecoveryLiveActivityBackgroundOptions: [String] =
        .init()

    @AppStorage(
        "resinRecoveryLiveActivityShowExpedition",
        store: UserDefaults(suiteName: "group.GenshinPizzaHelper")
    )
    static var showExpedition: Bool = true

    @AppStorage(
        "autoUpdateResinRecoveryTimerUsingReFetchData",
        store: UserDefaults(suiteName: "group.GenshinPizzaHelper")
    )
    static var autoUpdateResinRecoveryTimerUsingReFetchData: Bool = false

    @AppStorage(
        "resinRecoveryLiveActivityUseEmptyBackground",
        store: UserDefaults(suiteName: "group.GenshinPizzaHelper")
    )
    static var resinRecoveryLiveActivityUseEmptyBackground: Bool = false

    @AppStorage(
        "resinRecoveryLiveActivityUseCustomizeBackground",
        store: UserDefaults(suiteName: "group.GenshinPizzaHelper")
    )
    static var resinRecoveryLiveActivityUseCustomizeBackground: Bool = false

    var currentActivities: [Activity<ResinRecoveryAttributes>] {
        Activity<ResinRecoveryAttributes>.activities
    }

    var allowLiveActivity: Bool {
        ActivityAuthorizationInfo().areActivitiesEnabled
    }

    var background: ResinRecoveryActivityBackground {
        if Self.resinRecoveryLiveActivityUseEmptyBackground {
            return .noBackground
        } else if !Self.resinRecoveryLiveActivityUseCustomizeBackground {
            return .random
        } else {
            Self.backgroundSettingsSanityCheck()
            let backgrounds = Self.resinRecoveryLiveActivityBackgroundOptions
            if backgrounds.isEmpty {
                return .customize([NameCard.UI_NameCardPic_Bp20_P.fileName])
            } else {
                return .customize(backgrounds)
            }
        }
    }

    func createResinRecoveryTimerActivity(for account: Account) throws {
        guard allowLiveActivity else {
            throw CreateLiveActivityError.notAllowed
        }
        let accountName = account.config.name ?? ""
        let accountUUID: UUID = account.config.uuid ?? UUID()
        // TODO: debug mode
        guard let data = (try? account.result?.get()) else {
            throw CreateLiveActivityError.noInfo
        }
        guard !currentActivities.map({ $0.attributes.accountUUID })
            .contains(account.config.uuid!) else {
            updateResinRecoveryTimerActivity(for: account)
            return
        }
        let attributes: ResinRecoveryAttributes = .init(
            accountName: accountName,
            accountUUID: accountUUID
        )
        let status: ResinRecoveryAttributes.ResinRecoveryState = .init(
            resinInfo: data.resinInfo,
            expeditionInfo: data.expeditionInfo,
            showExpedition: Self.showExpedition,
            background: background
        )
        print("expedition=\(data.expeditionInfo.allCompleteTime)")
        do {
            let deliveryActivity = try Activity.request(
                attributes: attributes,
                contentState: status
            )
            print("request activity succeed ID=\(deliveryActivity.id)")
        } catch {
            print(
                "Error requesting pizza delivery Live Activity \(error.localizedDescription)."
            )
            throw CreateLiveActivityError
                .otherError(error.localizedDescription)
        }
    }

    func updateResinRecoveryTimerActivity(for account: Account) {
        currentActivities.filter { activity in
            activity.attributes.accountUUID == account.config.uuid ?? UUID()
        }.forEach { activity in
            Task {
                guard let data = (try? account.result?.get())
                else { return }
                guard Date
                    .now <
                    Date(timeIntervalSinceNow: TimeInterval(
                        data.resinInfo
                            .recoveryTime.second
                    )) else {
                    endActivity(for: account)
                    return
                }
                let status: ResinRecoveryAttributes
                    .ResinRecoveryState = .init(
                        resinInfo: data.resinInfo,
                        expeditionInfo: data.expeditionInfo,
                        showExpedition: Self.showExpedition,
                        background: background
                    )
                await activity.update(using: status)
            }
        }
    }

    func endActivity(for account: Account) {
        currentActivities.filter { activity in
            activity.attributes.accountUUID == account.config.uuid ?? UUID()
        }.forEach { activity in
            Task {
                await activity.end()
            }
        }
    }

    func updateAllResinRecoveryTimerActivity(for accounts: [Account]) {
        accounts.forEach { account in
            updateResinRecoveryTimerActivity(for: account)
        }
    }

    func endAllActivity() {
        currentActivities.forEach { activity in
            Task {
                await activity.end()
            }
        }
    }

    func updateAllResinRecoveryTimerActivityUsingReFetchData() {
        let configs = AccountConfigurationModel.shared.fetchAccountConfigs()
        configs.forEach { config in
            updateResinRecoveryTimerActivityUsingReFetchData(for: config)
        }
    }

    func updateResinRecoveryTimerActivity(
        for config: AccountConfiguration,
        using result: FetchResult
    ) {
        guard let activity = currentActivities.first(where: { activity in
            activity.attributes.accountUUID == config.uuid
        }) else { return }
        guard let data = try? result.get() else { return }
        let status: ResinRecoveryAttributes.ResinRecoveryState = .init(
            resinInfo: data.resinInfo,
            expeditionInfo: data.expeditionInfo,
            showExpedition: Self.showExpedition,
            background: background
        )
        Task {
            await activity.update(using: status)
        }
    }

    // MARK: Private

    private func updateResinRecoveryTimerActivityUsingReFetchData(
        for config: AccountConfiguration
    ) {
        guard Self.autoUpdateResinRecoveryTimerUsingReFetchData else { return }
        guard let activity = currentActivities.first(where: { activity in
            activity.attributes.accountUUID == config.uuid
        }) else { return }
        guard Date() > activity.contentState.next20ResinRecoveryTime
            || Date() > activity.contentState.resinFullTime
            || Date() > activity.contentState.allExpeditionCompleteTime
        else { return }
        config.fetchResult { result in
            guard let data = try? result.get() else { return }
            let status: ResinRecoveryAttributes.ResinRecoveryState = .init(
                resinInfo: data.resinInfo,
                expeditionInfo: data.expeditionInfo,
                showExpedition: Self.showExpedition,
                background: self.background
            )
            Task {
                await activity.update(using: status)
            }
        }
    }
}

enum CreateLiveActivityError: Error {
    case notAllowed
    case otherError(String)
    case noInfo
}

extension CreateLiveActivityError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .notAllowed:
            return "系统设置不允许本软件开启实时活动，请前往开启".localized
        case .noInfo:
            return "账号未获取信息".localized
        case let .otherError(message):
            return String(
                format: NSLocalizedString("未知错误：%@", comment: ""),
                message
            )
        }
    }
}
#endif
