// (c) 2022 and onwards Pizza Studio (GPL v3.0 License).
// ====================
// This code is released under the GPL v3.0 License (SPDX-License-Identifier: GPL-3.0)

import Defaults
import Foundation
import HBMihoyoAPI
import HoYoKit

// MARK: - EnkaGI.ResourceType

extension EnkaGI {
    // MARK: - EnkaGI.ResourceType

    public enum ResourceType: String {
        case affixes
        case characters
        case costumes
        case loc
        case namecards
        case pfps
        case honker_avatars
        case honker_characters
        case honker_meta
        case honker_ranks
        case honker_relics
        case honker_skills
        case honker_skilltree
        case honker_weps

        // MARK: Public

        public var json: String {
            rawValue.contains("honker_") ? "hsr/\(rawValue).json" : "\(rawValue).json"
        }

        public func subURLComponents(serverType: EnkaGI.JSONGitServerType? = nil) -> String {
            serverType != nil ? "store/\(json)" : "api/players/\(json)"
        }
    }
}

// MARK: - EnkaGI.JSONGitServerType

extension EnkaGI {
    public enum JSONGitServerType: Int {
        case global = 1
        case mainlandCN = 2
    }
}

extension HoYoKit.Server {
    public var jsonServer: EnkaGI.JSONGitServerType {
        [.china, .bilibili].contains(self) ? .mainlandCN : .global
    }
}

// MARK: - EnkaGI.Exception

extension EnkaGI {
    public enum Exception: Error {
        case enkaDBOnlineFetchFailure(details: String)
        case enkaProfileQueryFailure(message: String)
        case refreshTooFast(dateWhenRefreshable: Date)
        case dataInvalid
    }
}

#if hasFeature(RetroactiveAttribute)
extension EnkaGI.Exception: @retroactive LocalizedError {}
#else
extension EnkaGI.Exception: LocalizedError {}
#endif

extension EnkaGI.Exception {
    public var errorDescription: String? {
        switch self {
        case let .enkaDBOnlineFetchFailure(details: details):
            return String(format: "error.EnkaAPI.Query.OnlineFetchFailure:%@".localized, arguments: [details])
        case let .enkaProfileQueryFailure(message: message):
            return String(format: "error.EnkaAPI.Query.ProfileQueryFailure:%@".localized, arguments: [message])
        case let .refreshTooFast(dateWhenRefreshable: dateWhenRefreshable):
            return String(
                format: "error.EnkaAPI.Query.PlzRefrainFromQueryingUntil:%@".localized,
                arguments: [dateWhenRefreshable.description]
            )
        case .dataInvalid:
            return "error.EnkaAPI.Query.DataInvalid".localized
        }
    }
}

// MARK: - EnkaGI.DBModels

extension EnkaGI {
    public enum DBModels {
        public typealias LocTable = EnkaGI.CharacterLoc.LocDict
        public typealias CharacterDict = EnkaGI.CharacterMap
        public typealias RawLocTables = EnkaGI.CharacterLoc
    }
}

// MARK: - EnkaGI.JSONType

extension EnkaGI {
    public enum JSONType: String, CaseIterable {
        case affixes
        case characters
        case locTable = "loc"
        case namecards
        case pfps
        case retrieved = "N/A" // The JSON file retrieved from Enka Networks website per each query.

        // MARK: Public

        // Bundle JSON Accessor.
        public var bundledJSONData: Data? {
            guard rawValue != "N/A" else { return nil }
            guard let url = Bundle.module.url(forResource: rawValue, withExtension: "json") else { return nil }
            do {
                return try Data(contentsOf: url)
            } catch {
                NSLog("EnkaKitGI: Cannot access bundled JSON data \(rawValue).json.")
                return nil
            }
        }
    }
}

// MARK: - EnkaAPI LangCode

extension Locale {
    public static var langCodeForEnkaAPI: String {
        let languageCode = Locale.preferredLanguages.first
            ?? Bundle.module.preferredLocalizations.first
            ?? Bundle.main.preferredLocalizations.first
            ?? "en"
        switch languageCode.prefix(7).lowercased() {
        case "zh-hans": return "zh-cn"
        case "zh-hant": return "zh-tw"
        default: break
        }
        switch languageCode.prefix(5).lowercased() {
        case "zh-cn": return "zh-cn"
        case "zh-tw": return "zh-tw"
        default: break
        }
        switch languageCode.prefix(2).lowercased() {
        case "ja", "jp": return "ja"
        case "ko", "kr": return "ko"
        default: break
        }
        let valid = EnkaGI.EnkaDB.allowedLangTags.contains(languageCode)
        return valid ? languageCode.prefix(2).description : "en"
    }
}
