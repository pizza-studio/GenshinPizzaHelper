//
//  GDDictionaryDataModel.swift
//  GenshinPizzaHelper
//
//  Created by Bill Haku on 2022/10/3.
//

import Foundation

public struct GDDictionary: Codable {
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
