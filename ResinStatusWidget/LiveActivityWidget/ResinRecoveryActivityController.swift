//
//  ResinRecoveryActivityController.swift
//  GenshinPizzaHepler
//
//  Created by 戴藏龙 on 2022/11/19.
//

import Foundation
import ActivityKit

@available(iOS 16.1, *)
class ResinRecoveryActivityController {
    var currentActivities: [Activity<ResinRecoveryAttributes>] {
        Activity<ResinRecoveryAttributes>.activities
    }

    private init() {}

    static let shared: ResinRecoveryActivityController = .init()

    var allowLiveActivity: Bool {
        ActivityAuthorizationInfo.init().areActivitiesEnabled
    }

    func createResinRecoveryTimerActivity(for account: Account) throws {
        guard allowLiveActivity else {
            throw CreateLiveActivityError.notAllowed
        }
        let accountName = account.config.name ?? ""
        let accountUUID: UUID = account.config.uuid ?? UUID()
        // TODO: debug mode
        guard let resinInfo = (try? account.result?.get().resinInfo) else {
            throw CreateLiveActivityError.noInfo
        }
        guard !currentActivities.map({$0.attributes.accountUUID}).contains(account.config.uuid!) else {
            updateResinRecoveryTimerActivity(for: account)
            return
        }
        let attributes: ResinRecoveryAttributes = .init(accountName: accountName, accountUUID: accountUUID)
        let status: ResinRecoveryAttributes.ResinRecoveryState = .init(resinInfo: resinInfo)
        do {
            let deliveryActivity = try Activity.request(attributes: attributes, contentState: status)
            print("request activity succeed ID=\(deliveryActivity.id)")
        } catch let error {
            print("Error requesting pizza delivery Live Activity \(error.localizedDescription).")
            throw CreateLiveActivityError.otherError(error.localizedDescription)
        }
    }

    func updateResinRecoveryTimerActivity(for account: Account) {
        currentActivities.filter { activity in
            activity.attributes.accountUUID == account.config.uuid ?? UUID()
        }.forEach { activity in
            Task {
                guard let resinInfo = (try? account.result?.get().resinInfo) else { return }
                guard Date.now < Date(timeIntervalSinceNow: TimeInterval(resinInfo.recoveryTime.second)) else {
                    endActivity(for: account)
                    return
                }
                let status: ResinRecoveryAttributes.ResinRecoveryState = .init(resinInfo: resinInfo)
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
}

enum CreateLiveActivityError: Error {
    case notAllowed
    case otherError(String)
    case noInfo
}
