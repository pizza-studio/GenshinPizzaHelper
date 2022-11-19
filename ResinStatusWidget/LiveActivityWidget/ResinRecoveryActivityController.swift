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

    func createResinRecoveryTimerActivity(for account: Account) {
        let accountName = account.config.name ?? ""
        guard let resinInfo = (try? account.result?.get().resinInfo) else { return }
        let attributes: ResinRecoveryAttributes = .init(accountName: accountName)
        let status: ResinRecoveryAttributes.ResinRecoveryState = .init(resinInfo: resinInfo)
        do {
            var deliveryActivity = try Activity.request(attributes: attributes, contentState: status)
            deliveredActivities.append(.init(account: account, activity: deliveryActivity))
            print("request activity succeed ID=\(deliveryActivity.id)")
        } catch let error {
            print("Error requesting pizza delivery Live Activity \(error.localizedDescription).")
        }
    }

    func updateResinRecoveryTimerActivity(for account: Account) {
        deliveredActivities.filter { map in
            map.account == account
        }.forEach { map in
            Task {
                guard let resinInfo = (try? account.result?.get().resinInfo) else { return }
                guard Date.now < Date(timeIntervalSinceNow: TimeInterval(resinInfo.recoveryTime.second)) else {
                    endActivity(for: map.account)
                    return
                }
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

    func updateAllResinRecoveryTimerActivity() {
        deliveredActivities.forEach { map in
            Task {
                guard let resinInfo = (try? map.account.result?.get().resinInfo) else { return }
                guard Date.now < Date(timeIntervalSinceNow: TimeInterval(resinInfo.recoveryTime.second)) else {
                    endActivity(for: map.account)
                    return
                }
                let status: ResinRecoveryAttributes.ResinRecoveryState = .init(resinInfo: resinInfo)
                await map.activity.update(using: status)
            }
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
        let account: Account
        let activity: Activity<ResinRecoveryAttributes>
    }
}
