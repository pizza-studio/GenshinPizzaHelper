//
//  ChineseUIAccommodations.swift
//  GenshinPizzaHelper
//
//  Created by ShikiSuen on 2023/3/26.
//  检测当前介面语言是否是简体中文或繁体中文，以及在这种情况下的一些特殊操作。

import Defaults
import Foundation
import GIPizzaKit

extension Locale {
    public static var isUILanguagePanChinese: Bool {
        guard let firstLocale = Bundle.main.preferredLocalizations.first
        else { return false }
        return firstLocale.prefix(3).description == "zh-"
    }

    public static var isUILanguageJapanese: Bool {
        guard let firstLocale = Bundle.main.preferredLocalizations.first
        else { return false }
        return firstLocale.prefix(2).description == "ja"
    }

    public static var isUILanguageSimplifiedChinese: Bool {
        guard let firstLocale = Bundle.main.preferredLocalizations.first
        else { return false }
        return firstLocale.contains("zh-Hans") || firstLocale.contains("zh-CN")
    }

    public static var isUILanguageTraditionalChinese: Bool {
        guard let firstLocale = Bundle.main.preferredLocalizations.first
        else { return false }
        return firstLocale.contains("zh-Hant") || firstLocale
            .contains("zh-TW") || firstLocale.contains("zh-HK")
    }
}

extension String {
    public var localizedWithFix: String {
        if contains("旅行者") || localized.contains("旅行者") {
            return "空".localized + " / " + "荧".localized
        }
        characterNameCheck: switch Defaults[.useActualCharacterNames] {
        case true where self == "流浪者":
            return CharacterAsset.Kunikuzushi.localizedKey.localized
        case false
            where self == CharacterAsset.Kunikuzushi.localizedKey.localized && !Defaults[.customizedNameForWanderer]
            .isEmpty:
            return Defaults[.customizedNameForWanderer]
        default: break characterNameCheck
        }
        guard Defaults[.forceCharacterWeaponNameFixed] else { return localized }
        if Locale.isUILanguageSimplifiedChinese {
            if localized == "钟离" {
                return "锺离"
            } else if localized.contains("钟离") {
                return replacingOccurrences(of: "钟离", with: "锺离")
            }
        } else if Locale.isUILanguageTraditionalChinese {
            if localized == "霧切之回光" {
                return "霧切之迴光"
            }
            if localized.contains("堇") {
                return replacingOccurrences(of: "堇", with: "菫")
            }
        }
        return localized
    }
}
