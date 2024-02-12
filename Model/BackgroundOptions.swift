//
//  ColorHandler.swift
//  GenshinPizzaHelper
//
//  Created by Bill Haku on 2022/8/12.
//  Widget和App内的背景支持

import Foundation
import GIPizzaKit
import SwiftUI

// MARK: - BackgroundOptions

enum BackgroundOptions {
    static let colors: [String] = [
        "app.background.gray",
        "app.background.green",
        "app.background.blue",
        "app.background.purple",
        "app.background.gold",
        "app.background.red",
        "game.elements.anemo",
        "game.elements.hydro",
        "game.elements.cryo",
        "game.elements.pyro",
        "game.elements.geo",
        "game.elements.electro",
        "game.elements.dendro",
        "app.background.intertwinedFate",
    ]
    static let elements: [String] = [
        "game.elements.anemo",
        "game.elements.hydro",
        "game.elements.cryo",
        "game.elements.pyro",
        "game.elements.geo",
        "game.elements.electro",
        "game.elements.dendro",
    ]
    static let namecards: [String] = NameCard.allLegalCases.map(\.fileName)

    static let allOptions: [(String, String)] = BackgroundOptions.colors.map { ($0, $0) } + NameCard.allLegalCases
        .map { ($0.fileName, $0.localized) }

    static let elementsAndNamecard: [(String, String)] = BackgroundOptions.elements.map { ($0, $0) } + NameCard
        .allLegalCases
        .map { ($0.fileName, $0.localized) }
}

extension WidgetBackground {
    static let defaultBackground: WidgetBackground = .init(
        identifier: NameCard.defaultValueForWidget.fileName,
        display: NameCard.defaultValueForWidget.localized
    )
    static var randomBackground: WidgetBackground {
        let pickedBackgroundId = BackgroundOptions.allOptions.randomElement()!
        return WidgetBackground(
            identifier: pickedBackgroundId.0,
            display: pickedBackgroundId.1
        )
    }

    static var randomColorBackground: WidgetBackground {
        let pickedBackgroundId = BackgroundOptions.colors.randomElement()!
        return WidgetBackground(
            identifier: pickedBackgroundId,
            display: pickedBackgroundId
        )
    }

    static var randomNamecardBackground: WidgetBackground {
        let pickedBackgroundId = NameCard.allLegalCases.randomElement() ?? .defaultValue
        return WidgetBackground(
            identifier: pickedBackgroundId.fileName,
            display: pickedBackgroundId.localized
        )
    }

    static var randomElementBackground: WidgetBackground {
        let pickedBackgroundId = BackgroundOptions.elements.randomElement()!
        return WidgetBackground(
            identifier: pickedBackgroundId,
            display: pickedBackgroundId
        )
    }

    static var randomElementOrNamecardBackground: WidgetBackground {
        let pickedBackgroundId = BackgroundOptions.elementsAndNamecard.randomElement()!
        return WidgetBackground(
            identifier: pickedBackgroundId.0,
            display: pickedBackgroundId.1
        )
    }
}
