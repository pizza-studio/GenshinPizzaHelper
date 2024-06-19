// (c) 2022 and onwards Pizza Studio (GPL v3.0 License).
// ====================
// This code is released under the GPL v3.0 License (SPDX-License-Identifier: GPL-3.0)

import Foundation

public struct GDDictionary: Codable, Identifiable {
    public struct Variants: Codable {
        public var en: [String]?
        public var ja: [String]?
        public var zhCN: [String]?
    }

    public var en: String
    public var ja: String?
    public var zhCN: String?
    public var pronunciationJa: String?
    public var id: String
    public var tags: [String]?
    public var notes: String?
    public var variants: Variants?
}
