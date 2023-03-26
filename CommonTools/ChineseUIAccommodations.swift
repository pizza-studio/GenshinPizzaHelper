//
//  ChineseUIAccommodations.swift
//  GenshinPizzaHelper
//
//  Created by ShikiSuen on 2023/3/26.
//  检测当前介面语言是否是简体中文或繁体中文，以及在这种情况下的一些特殊操作。

import Foundation

extension Locale {
    internal static var forceFixWrongChineseCharsUsedByMihoyo: Bool {
        let user = UserDefaults(suiteName: "group.GenshinPizzaHelper")
        return user?
            .bool(forKey: "forceFixWrongChineseCharsUsedByMihoyo") ?? false
    }

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
    public var fixWrongChineseCharsUsedByMihoyo: String {
        guard Locale.forceFixWrongChineseCharsUsedByMihoyo else { return self }
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
        }
        return self
    }
}
