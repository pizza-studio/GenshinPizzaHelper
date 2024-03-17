// (c) 2022 and onwards Pizza Studio (GPL v3.0 License).
// ====================
// This code is released under the GPL v3.0 License (SPDX-License-Identifier: GPL-3.0)

//  Strings 功能扩充。

import Defaults
import DefaultsKeys
import Foundation

extension String {
    /// 检测是否包含汉字或假名。
    /// Remark: 暂无全形标点检测之功能。
    public var containsKanjiOrKana: Bool {
        range(of: #"\p{Script=Han}|\p{Script=Katakana}|\p{Script=Hiragana}"#, options: .regularExpression) != nil
    }

    public func i18n(_ identifier: String? = nil) -> String {
        let identifier = identifier ?? Bundle.main.preferredLocalizations.first
        let moduleLProjPath = Bundle.module.path(forResource: identifier, ofType: "lproj")
        let bundleLProjPath = Bundle.main.path(forResource: identifier, ofType: "lproj")
        guard let path = moduleLProjPath ?? bundleLProjPath, let langBundle = Bundle(path: path) else {
            return localized
        }
        return NSLocalizedString(self, bundle: langBundle, comment: "")
    }

    public func i18nSPM(_ identifier: String? = nil) -> String {
        let identifier = identifier ?? Bundle.main.preferredLocalizations.first
        let moduleLProjPath = Bundle.module.path(forResource: identifier, ofType: "lproj")
        let bundleLProjPath = Bundle.main.path(forResource: identifier, ofType: "lproj")
        guard let path = moduleLProjPath ?? bundleLProjPath, let langBundle = Bundle(path: path) else {
            return spmLocalized
        }
        return NSLocalizedString(self, bundle: langBundle, comment: "")
    }

    public var localizedWithFix: String {
        if contains("旅行者") || localized.contains("旅行者") {
            return CharacterAsset.Sora.localized + " / " + CharacterAsset.Hotaru.localized
        }
        characterNameCheck: switch Defaults[.useActualCharacterNames] {
        case true where self == "流浪者":
            return CharacterAsset.Kunikuzushi.localizedKey.spmLocalized
        case false
            where self == CharacterAsset.Kunikuzushi.localizedKey.spmLocalized && !Defaults[.customizedNameForWanderer]
            .isEmpty:
            return Defaults[.customizedNameForWanderer]
        default: break characterNameCheck
        }
        guard Defaults[.forceCharacterWeaponNameFixed] else { return spmLocalized }
        if Locale.isUILanguageSimplifiedChinese {
            if spmLocalized == "钟离" {
                return "锺离"
            } else if spmLocalized.contains("钟离") {
                return replacingOccurrences(of: "钟离", with: "锺离")
            }
        } else if Locale.isUILanguageTraditionalChinese {
            if spmLocalized == "霧切之回光" {
                return "霧切之迴光"
            }
            if spmLocalized.contains("堇") {
                return replacingOccurrences(of: "堇", with: "菫")
            }
        }
        return spmLocalized
    }
}
