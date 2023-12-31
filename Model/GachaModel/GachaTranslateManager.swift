//
//  GachaTranslateManager.swift
//  GenshinPizzaHepler
//
//  Created by 戴藏龙 on 2023/4/5.
//

import Foundation

// MARK: - GachaTranslateManager

class GachaTranslateManager {
    // MARK: Lifecycle

    private init() {
        // 获取文档目录路径
        let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let filename = documentDirectory.appendingPathComponent("gacha_lang_dictionary.json")

        // 如果文件不存在，则保存
        if !FileManager.default.fileExists(atPath: filename.path) {
            let path = Bundle.main.path(forResource: "gacha_lang_dictionary", ofType: "json")!
            let data = try! Data(contentsOf: URL(fileURLWithPath: path))
            try! data.write(to: filename)
        }

        // 读取文件内容
        let jsonData = FileManager.default.contents(atPath: filename.path)!

        // 创建JSON解码器
        let decoder = JSONDecoder()

        // 将JSON数据解码为结构体
        self.translate = try! decoder.decode(GachaTranslateDictionary.self, from: jsonData)

        updateDictionary()
    }

    // MARK: Internal

    static let shared: GachaTranslateManager = .init()

    /// 查找是哪个语言
    func getLanguageCode(for name: String) -> GachaLanguageCode? {
        for (key, value) in translate {
            if value.keys.contains(name) {
                return GachaLanguageCode(rawValue: key)
            }
        }
        return nil
    }

    /// 将某语言翻译为简体中文
    func translateToZHCN(_ name: String, from sourceLanguageCode: GachaLanguageCode?) -> String? {
        if let sourceLanguageCode = sourceLanguageCode {
            return translate(name, from: sourceLanguageCode, to: .zhCN)
        } else {
            guard let languageCode = getLanguageCode(for: name) else {
                return nil
            }
            return translate(name, from: languageCode, to: .zhCN)
        }
    }

    /// 将简体中文翻译为某语言
    func translateFromZHCN(_ name: String, to targetLanguageCode: GachaLanguageCode) -> String? {
        translate(name, from: .zhCN, to: targetLanguageCode)
    }

    func translateItemTypeToZHCN(_ itemTypeString: String) -> String? {
        if ["อาวุธ", "무기", "Arma", "武器", "武器", "Senjata", "Arma", "Waffe", "Arme", "武器", "Оружие", "Weapon", "Vũ Khí"]
            .contains(itemTypeString) {
            return "武器"
        } else {
            return "角色"
        }
    }

    func translateItemType(_ gachaTypeCNString: String, to languageCode: GachaLanguageCode) -> String? {
        switch gachaTypeCNString {
        case "武器":
            return itemTypeWeaponTranslateDictionary[languageCode.rawValue]
        case "角色":
            return itemTypeCharacterTranslateDictionary[languageCode.rawValue]
        default:
            return itemTypeWeaponTranslateDictionary[languageCode.rawValue]
        }
    }

    // MARK: Private

    private typealias GachaTranslateDictionary = [String: [String: Int]]

    private let itemTypeWeaponTranslateDictionary: [String: String] = [
        "th-th": "อาวุธ",
        "ko-kr": "무기",
        "es-es": "Arma",
        "ja-jp": "武器",
        "zh-cn": "武器",
        "id-id": "Senjata",
        "pt-pt": "Arma",
        "de-de": "Waffe",
        "fr-fr": "Arme",
        "zh-tw": "武器",
        "ru-ru": "Оружие",
        "en-us": "Weapon",
        "vi-vn": "Vũ Khí",
    ]
    private let itemTypeCharacterTranslateDictionary: [String: String] = [
        "th-th": "ตัวละคร",
        "ko-kr": "캐릭터",
        "es-es": "Personaje",
        "ja-jp": "キャラクター",
        "zh-cn": "角色",
        "id-id": "Karakter",
        "pt-pt": "Personagem",
        "de-de": "Figur",
        "fr-fr": "Personnage",
        "zh-tw": "角色",
        "ru-ru": "Персонажи",
        "en-us": "Character",
        "vi-vn": "Nhân Vật",
    ]

    private var translate: GachaTranslateDictionary

    private func updateDictionary() {
        // 从 https://gi.pizzastudio.org/api/app/gacha_lang_dictionary.json 加载数据，如果成功，保存到document目录
        let url = URL(string: "https://gi.pizzastudio.org/api/app/gacha_lang_dictionary.json")!
        let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let filename = documentDirectory.appendingPathComponent("gacha_lang_dictionary.json")
        URLSession.shared.dataTask(with: url) { data, _, error in
            do {
                guard let data = data else {
                    return
                }
                let decoder = JSONDecoder()
                let translate = try decoder.decode(GachaTranslateDictionary.self, from: data)
                try data.write(to: filename)
                self.translate = translate
            } catch {
                print(error)
            }
        }.resume()
    }

    private func getDictionary(for languageCode: GachaLanguageCode) -> [String: Int] {
        translate[languageCode.rawValue]!
    }

    private func translate(
        _ name: String,
        from sourceLanguageCode: GachaLanguageCode,
        to targetLanguageCode: GachaLanguageCode
    )
        -> String? {
        let sourceDictionary = getDictionary(for: sourceLanguageCode)
        let targetDictionary = getDictionary(for: targetLanguageCode)
        guard let sourceIndex = sourceDictionary[name] else {
            return nil
        }
        return targetDictionary.first(where: { $0.value == sourceIndex })?.key
    }
}

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
