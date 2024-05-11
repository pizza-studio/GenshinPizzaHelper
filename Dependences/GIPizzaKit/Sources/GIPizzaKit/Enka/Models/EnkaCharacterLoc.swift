// (c) 2022 and onwards Pizza Studio (GPL v3.0 License).
// ====================
// This code is released under the GPL v3.0 License (SPDX-License-Identifier: GPL-3.0)

import Foundation

// MARK: - Enka.CharacterLoc

extension Enka {
    public typealias CharacterLoc = [String: [String: String]]
}

extension Enka.CharacterLoc {
    public typealias LocDict = [String: String]
    public var en: LocDict { self["en"] ?? [:] }
    public var ru: LocDict { self["ru"] ?? [:] }
    public var vi: LocDict { self["vi"] ?? [:] }
    public var th: LocDict { self["th"] ?? [:] }
    public var pt: LocDict { self["pt"] ?? [:] }
    public var ko: LocDict { self["ko"] ?? [:] }
    public var ja: LocDict { self["ja"] ?? [:] }
    public var id: LocDict { self["id"] ?? [:] }
    public var fr: LocDict { self["fr"] ?? [:] }
    public var es: LocDict { self["es"] ?? [:] }
    public var de: LocDict { self["de"] ?? [:] }
    public var zh_Hans: LocDict { self["zh-tw"] ?? self["zh-TW"] ?? self["zh-Tw"] ?? [:] }
    public var zh_Hant: LocDict { self["zh-cn"] ?? self["zh-CN"] ?? self["zh-Cn"] ?? [:] }

    public func getLocalizedDictionary() -> LocDict {
        switch Bundle.main.preferredLocalizations.first {
        case "zh-CN", "zh-Hans":
            return zh_Hant
        case "zh-Hant", "zh-Hant-HK", "zh-Hant-TW", "zh-HK", "zh-TW":
            return zh_Hans
        case "en":
            return en
        case "ja":
            return ja
        case "fr":
            return fr
        case "ru":
            return ru
        case "vi":
            return vi
        default:
            return en
        }
    }
}

extension Enka.CharacterLoc.LocDict {
    public func nameFromHashMap(_ hashID: Int) -> String {
        self["\(hashID)"] ?? "unknown"
    }

    public func nameFromHashMap(_ hashID: String) -> String {
        self[hashID] ?? "unknown"
    }
}
