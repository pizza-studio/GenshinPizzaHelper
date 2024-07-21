//
//  GachaLanguageCode.swift
//  GenshinPizzaHepler
//
//  Created by 戴藏龙 on 2023/4/5.
//

import Foundation

// MARK: - GachaLanguageCode

public enum GachaLanguageCode: String, CaseIterable {
    case th = "th-th" // 泰语（泰国）
    case ko = "ko-kr" // 朝鲜语（韩国）
    case es = "es-es" // 西班牙语（西班牙）
    case ja = "ja-jp" // 日语（日本）
    case zhCN = "zh-cn" // 中文（中国大陆）
    case id = "id-id" // 印度尼西亚语（印度尼西亚）
    case pt = "pt-pt" // 葡萄牙语（葡萄牙）
    case de = "de-de" // 德语（德国）
    case fr = "fr-fr" // 法语（法国）
    case zhTW = "zh-tw" // 中文（台湾）
    case ru = "ru-ru" // 俄语（俄罗斯）
    case enUS = "en-us" // 英语（美国）
    case vi = "vi-vn" // 越南语（越南）
}

// MARK: Codable

extension GachaLanguageCode: Codable {
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let rawValue = try container.decode(String.self)
        guard let languageCode = GachaLanguageCode(rawValue: rawValue) else {
            throw DecodingError.dataCorruptedError(
                in: container,
                debugDescription: "Invalid GachaLanguageCode raw value: \(rawValue)"
            )
        }
        self = languageCode
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(rawValue)
    }
}

// MARK: CustomStringConvertible

extension GachaLanguageCode {
    public var localizedKey: String {
        "gacha.languageCode.\(String(describing: self))"
    }

    public var localized: String {
        localizedKey.localized
    }
}
