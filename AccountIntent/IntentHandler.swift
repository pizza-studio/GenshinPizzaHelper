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
        print("handling intent")
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
        self.expeditionViewConfig = ExpeditionViewConfiguration(noticeExpeditionWhenAllCompleted: (intent.expeditionNoticeMethod.rawValue != 2), expeditionShowingMethod: ExpeditionShowingMethod.init(rawValue: intent.expeditionShowingMethod.rawValue) ?? .byNum)
        self.showWeeklyBosses = intent.showWeeklyBosses?.boolValue ?? true
        // TODO: 改成Intent中的东西
//        self.colorHandler = ColorHandler(widgetBackgroundColor: .purple)
        self.backgroundColor = WidgetBackgroundColor.init(rawValue: intent.backgoundColor.rawValue) ?? .purple
    }
}
