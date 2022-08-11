//
//  IntentHandler.swift
//  ResinStatusWidgetExtension
//
//  Created by 戴藏龙 on 2022/8/9.
//

import Foundation
import Intents

class IntentHandler: INExtension, SelectAccountIntentHandling {
    func provideAccountIntentOptionsCollection(for intent: SelectAccountIntent, with completion: @escaping (INObjectCollection<AccountIntent>?, Error?) -> Void) {
        let accountConfigurationModel = AccountConfigurationModel.shared
        let accountConfigs: [AccountConfiguration] = accountConfigurationModel.fetchAccountConfigs()

        let accountIntents: [AccountIntent] = accountConfigs.map { config in
            return AccountIntent(identifier: config.uuid!.uuidString, display: config.name!+"(\(config.server.rawValue))")
        }
        let collection = INObjectCollection(items: accountIntents)
        accountIntents.forEach { accountIntent in
            print(accountIntent.description)
        }

        completion(collection, nil)
    }

}


extension WidgetViewConfiguration {
    init(_ intent: SelectAccountIntent, _ noticeMessage: String?) {
        self.showAccountName = intent.showAccountName?.boolValue ?? false
        self.showTransformer = intent.showTransformer?.boolValue ?? true
        self.expeditionViewConfig = ExpeditionViewConfiguration(noticeExpeditionWhenAllCompleted: intent.noticeExpeditionWhenAllCompleted?.boolValue ?? true, expeditionShowingMethod: ExpeditionShowingMethod.init(rawValue: intent.expeditionShowingMethod.rawValue) ?? .byNum)
        self.showWeeklyBosses = intent.showWeeklyBosses?.boolValue ?? true
    }
}
