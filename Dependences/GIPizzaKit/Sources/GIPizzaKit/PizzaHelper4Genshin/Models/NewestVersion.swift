// (c) 2022 and onwards Pizza Studio (GPL v3.0 License).
// ====================
// This code is released under the GPL v3.0 License (SPDX-License-Identifier: GPL-3.0)

import Foundation

public struct NewestVersion: Codable {
    public struct MultiLanguageContents: Codable {
        public var en: [String]
        public var zhcn: [String]
        public var ja: [String]
        public var fr: [String]
        public var zhtw: [String]?
        public var ru: [String]?
    }

    public struct VersionHistory: Codable {
        public struct MultiLanguageContents: Codable {
            public var en: [String]
            public var zhcn: [String]
            public var ja: [String]
            public var fr: [String]
            public var zhtw: [String]?
            public var ru: [String]?
        }

        public var shortVersion: String
        public var buildVersion: Int
        public var updates: MultiLanguageContents
    }

    public var shortVersion: String
    public var buildVersion: Int
    public var updates: MultiLanguageContents
    public var notice: MultiLanguageContents
    public var updateHistory: [VersionHistory]
}
