//
//  IntentHandler.swift
//  ResinStatusWidgetExtension
//
//  Created by 戴藏龙 on 2022/8/9.
//

import Foundation
import GIPizzaKit
import HoYoKit
import Intents

// MARK: - IntentHandler

class IntentHandler: INExtension, SelectAccountIntentHandling,
    SelectOnlyAccountIntentHandling,
    SelectAccountAndShowWhichInfoIntentHandling {
    // MARK: - SelectAccountIntentHandling

    func provideBackgroundOptionsCollection(
        for intent: SelectAccountIntent,
        with completion: @escaping (
            INObjectCollection<WidgetBackground>?,
            Error?
        ) -> ()
    ) {
        let colorOptions: [String] = BackgroundOptions.colors
        let namecardOptions: [NameCard] = NameCard.allLegalCases

        var intents: [WidgetBackground] = []
        colorOptions.forEach { colorName in
            let name = colorName.localized
            let intent = WidgetBackground(identifier: colorName, display: name)
            intents.append(intent)
        }
        namecardOptions.forEach { namecardName in
            let intent = WidgetBackground(
                identifier: namecardName.fileName,
                display: namecardName.localized
            )
            intents.append(intent)
        }
        completion(INObjectCollection(items: intents), nil)
    }

    func provideAccountIntentOptionsCollection(
        for intent: SelectAccountIntent,
        with completion: @escaping (INObjectCollection<AccountIntent>?, Error?)
            -> ()
    ) {
        print("handling intent")
        let accountConfigurationModel = AccountModel.shared
        let accountConfigs: [Account] = accountConfigurationModel
            .fetchAccountConfigs()

        let accountIntents: [AccountIntent] = accountConfigs.map { config in
            AccountIntent(
                identifier: config.uuid!.uuidString,
                display: config.name! + "(\(config.server.localized))"
            )
        }
        let collection = INObjectCollection(items: accountIntents)
        accountIntents.forEach { accountIntent in
            print(accountIntent.description)
        }

        completion(collection, nil)
    }

    // MARK: - SelectOnlyAccountIntentHandling

    func provideAccountOptionsCollection(
        for intent: SelectOnlyAccountIntent,
        with completion: @escaping (INObjectCollection<AccountIntent>?, Error?)
            -> ()
    ) {
        let accountConfigurationModel = AccountModel.shared
        let accountConfigs: [Account] = accountConfigurationModel
            .fetchAccountConfigs()

        let accountIntents: [AccountIntent] = accountConfigs.map { config in
            AccountIntent(
                identifier: config.uuid!.uuidString,
                display: config.name! + "(\(config.server.localized))"
            )
        }
        let collection = INObjectCollection(items: accountIntents)
        accountIntents.forEach { accountIntent in
            print(accountIntent.description)
        }

        completion(collection, nil)
    }

    // MARK: - SelectAccountAndShowWhichInfoIntentHandling

    func provideAccountOptionsCollection(
        for intent: SelectAccountAndShowWhichInfoIntent,
        with completion: @escaping (INObjectCollection<AccountIntent>?, Error?)
            -> ()
    ) {
        let accountConfigurationModel = AccountModel.shared
        let accountConfigs: [Account] = accountConfigurationModel
            .fetchAccountConfigs()

        let accountIntents: [AccountIntent] = accountConfigs.map { config in
            AccountIntent(
                identifier: config.uuid!.uuidString,
                display: config.name! + "(\(config.server.localized))"
            )
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
        self.showAccountName = true
        self.showTransformer = intent.showTransformer?.boolValue ?? true
        self.weeklyBossesShowingMethod = intent.weeklyBossesShowingMethod
        self.randomBackground = intent.randomBackground?.boolValue ?? false
        if let backgrounds = intent.background {
            self.selectedBackgrounds = backgrounds
                .isEmpty ? [.defaultBackground] : backgrounds
        } else {
            self.selectedBackgrounds = [.defaultBackground]
        }
        self.isDarkModeOn = intent.isDarkModeOn?.boolValue ?? true
        self.showMaterialsInLargeSizeWidget = intent
            .showMaterialsInLargeSizeWidget?.boolValue ?? true
    }
}
