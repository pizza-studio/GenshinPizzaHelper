//
//  IntentHandler.swift
//  ResinStatusWidgetExtension
//
//  Created by 戴藏龙 on 2022/8/9.
//

import Foundation
import Intents

class IntentHandler: INExtension, SelectAccountIntentHandling {
    func provideBackgoundOptionsCollection(for intent: SelectAccountIntent, with completion: @escaping (INObjectCollection<WidgetBackground>?, Error?) -> Void) {
        let colorOptions: [String] = BackgroundOptions.colors
        let namecardOptions: [String] = BackgroundOptions.namecards
        
        var intents: [WidgetBackground] = []
        colorOptions.forEach { colorName in
            let intent = WidgetBackground.init(identifier: colorName, display: colorName)
            intents.append(intent)
        }
        namecardOptions.forEach { namecardName in
            let intent = WidgetBackground.init(identifier: namecardName, display: namecardName)
            intents.append(intent)
        }
        completion(INObjectCollection(items: intents), nil)
    }
    
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
        self.weeklyBossesShowingMethod = intent.weeklyBossesShowingMethod
        self.randomBackground = intent.randomBackground?.boolValue ?? false
        self.selectedBackground = intent.backgound ?? WidgetBackground.defaultBackground
        self.isDarkModeOn = intent.isDarkModeOn?.boolValue ?? true
        self.showMaterialsInLargeSizeWidget = intent.showMaterialsInLargeSizeWidget?.boolValue ?? true
    }
}
