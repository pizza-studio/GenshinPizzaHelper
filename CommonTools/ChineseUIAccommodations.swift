//
//  ChineseUIAccommodations.swift
//  GenshinPizzaHelper
//
//  Created by ShikiSuen on 2023/3/26.
//  检测当前介面语言是否是简体中文或繁体中文，以及在这种情况下的一些特殊操作。

import Foundation

extension Locale {
    public static var isUILanguagePanChinese: Bool {
        guard let firstLocale = Locale.preferredLanguages.first
        else { return false }
        return firstLocale.contains("zh-")
    }

    public static var isUILanguageSimplifiedChinese: Bool {
        guard let firstLocale = Locale.preferredLanguages.first
        else { return false }
        return firstLocale.contains("zh-Hans") || firstLocale.contains("zh-CN")
    }

    public static var isUILanguageTraditionalChinese: Bool {
        guard let firstLocale = Locale.preferredLanguages.first
        else { return false }
        return firstLocale.contains("zh-Hant") || firstLocale
            .contains("zh-TW") || firstLocale.contains("zh-HK")
    }
}

extension String {
    /// 該函式也會修正從 Mihoyo 抓到的原始資料當中的文字。
    public var hasCharacterWeaponNameFixed: String {
        if AppConfig.useActualCharacterNames {
            if contains("旅行者") {
                var hotaru = "荧".localized
                if AppConfig.forcehasCharacterWeaponNameFixed,
                   Locale.isUILanguageTraditionalChinese {
                    hotaru = "螢"
                }
                return "空".localized + "/" + hotaru
            } else if self == "流浪者" {
                return "雷电国崩".localized
            } else if contains("流浪者") {
                return replacingOccurrences(of: "流浪者", with: "雷电国崩").localized
            }
        }
        guard AppConfig.forcehasCharacterWeaponNameFixed
        else { return self }
        if Locale.isUILanguageSimplifiedChinese {
            if self == "钟离" {
                return "锺离"
            } else if self == "钟离・天星" {
                return "锺离・天星"
            } else if contains("钟离") {
                return replacingOccurrences(of: "钟离", with: "锺离")
            }
        } else if Locale.isUILanguageTraditionalChinese {
            if self == "霧切之回光" {
                return "霧切之迴光"
            }
            if contains("堇") {
                return replacingOccurrences(of: "堇", with: "菫")
            }
            if contains("熒") {
                return replacingOccurrences(of: "熒", with: "螢")
            }
        }
        return self
    }
}

extension AppConfig {
    internal static var forcehasCharacterWeaponNameFixed: Bool {
        let user = UserDefaults(suiteName: "group.GenshinPizzaHelper")
        return user?
            .bool(forKey: "forcehasCharacterWeaponNameFixed") ?? false
    }

    internal static var useActualCharacterNames: Bool {
        let user = UserDefaults(suiteName: "group.GenshinPizzaHelper")
        return user?
            .bool(forKey: "useActualCharacterNames") ?? true
    }
}
