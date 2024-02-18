//
//  GIDictionaryModel.swift
//  HSRPizzaHelper
//
//  Created by 戴藏龙 on 2023/7/30.
//

import Foundation

// MARK: - GIDictionaryTranslationResult

struct GIDictionaryTranslationResult: Decodable {
    struct Translation: Decodable, Identifiable {
        // MARK: Lifecycle

        init(from decoder: Decoder) throws {
            let container: KeyedDecodingContainer<GIDictionaryTranslationResult.Translation.CodingKeys> = try decoder
                .container(keyedBy: GIDictionaryTranslationResult.Translation.CodingKeys.self)
            self.vocabularyId = try container.decode(
                Int.self,
                forKey: GIDictionaryTranslationResult.Translation.CodingKeys.vocabularyId
            )
            self.target = try container.decode(
                String.self,
                forKey: GIDictionaryTranslationResult.Translation.CodingKeys.target
            )
            self.targetLanguage = try container.decode(
                DictionaryLanguage.self,
                forKey: GIDictionaryTranslationResult.Translation.CodingKeys.targetLanguage
            )
            let translationDictionary = try container.decode(
                [String: String].self,
                forKey: GIDictionaryTranslationResult.Translation.CodingKeys.translationDictionary
            )
            var temp: [DictionaryLanguage: String] = .init()
            for (key, value) in translationDictionary {
                if let key = DictionaryLanguage(rawValue: key) {
                    temp[key] = value
                }
            }
            self.translationDictionary = temp
        }

        // MARK: Internal

        enum CodingKeys: String, CodingKey {
            case vocabularyId = "vocabulary_id"
            case target
            case targetLanguage = "target_lang"
            case translationDictionary = "lan_dict"
        }

        let vocabularyId: Int
        let target: String
        let targetLanguage: DictionaryLanguage
        let translationDictionary: [DictionaryLanguage: String]

        var id: Int { vocabularyId }
    }

    enum CodingKeys: String, CodingKey {
        case totalPage = "total_page"
        case translations = "results"
    }

    var totalPage: Int
    var translations: [Translation]
}

// MARK: - DictionaryLanguage

enum DictionaryLanguage: String, Decodable {
    case english = "en"
    case portuguese = "pt"
    case japanese = "jp"
    case indonesian = "id"
    case korean = "kr"
    case thai = "th"
    case french = "fr"
    case simplifiedChinese = "chs"
    case russian = "ru"
    case german = "de"
    case traditionalChinese = "cht"
    case spanish = "es"
    case vietnamese = "vi"
}

// MARK: CustomStringConvertible

extension DictionaryLanguage: CustomStringConvertible {
    var description: String {
        switch self {
        case .english:
            String(localized: "tool.dictionary.language.english")
        case .portuguese:
            String(localized: "tool.dictionary.language.portuguese")
        case .japanese:
            String(localized: "tool.dictionary.language.japanese")
        case .indonesian:
            String(localized: "tool.dictionary.language.indonesian")
        case .korean:
            String(localized: "tool.dictionary.language.korean")
        case .thai:
            String(localized: "tool.dictionary.language.thai")
        case .french:
            String(localized: "tool.dictionary.language.french")
        case .simplifiedChinese:
            String(localized: "tool.dictionary.language.simplified_chinese")
        case .russian:
            String(localized: "tool.dictionary.language.russian")
        case .german:
            String(localized: "tool.dictionary.language.german")
        case .traditionalChinese:
            String(localized: "tool.dictionary.language.traditional_chinese")
        case .spanish:
            String(localized: "tool.dictionary.language.spanish")
        case .vietnamese:
            String(localized: "tool.dictionary.language.vietnamese")
        }
    }
}
