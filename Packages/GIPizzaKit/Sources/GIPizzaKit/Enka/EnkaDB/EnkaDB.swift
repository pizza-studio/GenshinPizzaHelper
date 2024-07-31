// (c) 2022 and onwards Pizza Studio (GPL v3.0 License).
// ====================
// This code is released under the GPL v3.0 License (SPDX-License-Identifier: GPL-3.0)

import Combine
import Foundation

extension EnkaGI {
    public class EnkaDB: Codable, ObservableObject {
        // MARK: Lifecycle

        public init(
            locTag: String? = nil,
            locTable: EnkaGI.DBModels.LocTable,
            characters: EnkaGI.DBModels.CharacterDict
        ) {
            let locTag = locTag ?? Locale.langCodeForEnkaAPI
            self.langTag = Self.sanitizeLangTag(locTag)
            self.locTable = locTable
            self.characters = characters
        }

        /// Use bundled resources to initiate an EnkaDB instance.
        public init?(locTag: String? = nil) {
            do {
                let locTables = try EnkaGI.JSONType.locTable.bundledJSONData
                    .assertedParseAs(EnkaGI.DBModels.RawLocTables.self)
                let locTag = locTag ?? Locale.langCodeForEnkaAPI
                guard let locTableSpecified = locTables[locTag] else { return nil }
                self.langTag = Self.sanitizeLangTag(locTag)
                self.locTable = locTableSpecified
                self.characters = try EnkaGI.JSONType.characters.bundledJSONData
                    .assertedParseAs(EnkaGI.DBModels.CharacterDict.self)
            } catch {
                print("\n\(error)\n")
                return nil
            }
        }

        // MARK: Public

        public static let allowedLangTags: [String] = [
            "en", "ru", "vi", "th", "pt", "ko",
            "ja", "id", "fr", "es", "de", "zh-tw", "zh-cn",
        ]

        public static var currentLangTag: String {
            Locale.langCodeForEnkaAPI
        }

        public var langTag: String {
            didSet {
                asyncSendObjWillChange()
            }
        }

        public var locTable: EnkaGI.DBModels.LocTable {
            didSet {
                asyncSendObjWillChange()
            }
        }

        public var characters: EnkaGI.DBModels.CharacterDict {
            didSet {
                asyncSendObjWillChange()
            }
        }

        public var isExpired: Bool = false {
            didSet {
                asyncSendObjWillChange()
            }
        }

        public static func sanitizeLangTag(_ target: some StringProtocol) -> String {
            var target = target.lowercased()
            if target.prefix(2) == "zh" {
                if target.contains("cht") || target.contains("hant") {
                    target = "zh-tw"
                } else if target.contains("chs") || target.contains("hans") {
                    target = "zh-cn"
                }
            }
            if !Self.allowedLangTags.contains(target) {
                target = "en"
            }
            return target
        }

        @MainActor
        public func update(new: EnkaGI.EnkaDB) {
            langTag = new.langTag
            locTable = new.locTable
            characters = new.characters
            isExpired = false
        }

        // MARK: Private

        private func asyncSendObjWillChange() {
            Task.detached { @MainActor in
                self.objectWillChange.send()
            }
        }
    }
}
