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
    var deliveredActivities: [MapActivityAndAccount] = .init()

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
        // TODO: debug mode
        guard let resinInfo = (try? account.result?.get().resinInfo) else { return }
        guard !deliveredActivities.map({$0.account.config.uuid!}).contains(account.config.uuid!) else {
            updateResinRecoveryTimerActivity(for: account)
            return
        }
        let attributes: ResinRecoveryAttributes = .init(accountName: accountName)
        let status: ResinRecoveryAttributes.ResinRecoveryState = .init(resinInfo: resinInfo)
        do {
            let deliveryActivity = try Activity.request(attributes: attributes, contentState: status)
            deliveredActivities.append(.init(account: account, activity: deliveryActivity))
            print("request activity succeed ID=\(deliveryActivity.id)")
        } catch let error {
            print("Error requesting pizza delivery Live Activity \(error.localizedDescription).")
            throw CreateLiveActivityError.otherError(error.localizedDescription)
        }
    }

    func updateResinRecoveryTimerActivity(for account: Account) {
        deliveredActivities.filter { map in
            map.account == account
        }.enumerated().forEach { index, map in
            Task {
                guard let resinInfo = (try? account.result?.get().resinInfo) else { return }
                guard Date.now < Date(timeIntervalSinceNow: TimeInterval(resinInfo.recoveryTime.second)) else {
                    endActivity(for: map.account)
                    return
                }
                deliveredActivities[index].account = account
                let status: ResinRecoveryAttributes.ResinRecoveryState = .init(resinInfo: resinInfo)
                await map.activity.update(using: status)
            }
        }
    }

    func endActivity(for account: Account) {
        deliveredActivities.filter { map in
            map.account == account
        }.forEach { map in
            Task {
                await map.activity.end()
            }
        }
    }

    func updateAllResinRecoveryTimerActivity(for accounts: [Account]) {
        accounts.forEach { account in
            updateResinRecoveryTimerActivity(for: account)
        }
    }

    func endAllActivity() {
        deliveredActivities.enumerated().map { index, map in
            deliveredActivities.remove(at: index)
            return map.activity
        }.forEach { activity in
            Task {
                await activity.end()
            }
        }
    }

    func checkActivityAvaliable() {
        deliveredActivities.enumerated().forEach { index, map in
            guard let resinInfo = try? map.account.result?.get().resinInfo else {
                deliveredActivities.remove(at: index)
                return
            }
            if Date() > resinInfo.updateDate.addingTimeInterval(TimeInterval(resinInfo.recoveryTime.second)) {
                deliveredActivities.remove(at: index)
            }
        }
    }

    struct MapActivityAndAccount {
        var account: Account
        let activity: Activity<ResinRecoveryAttributes>
    }
}

enum CreateLiveActivityError: Error {
    case notAllowed
    case otherError(String)
}
