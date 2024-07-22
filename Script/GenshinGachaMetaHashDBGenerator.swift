// (c) 2022 and onwards Pizza Studio (GPL v3.0 License).
// ====================
// This code is released under the GPL v3.0 License (SPDX-License-Identifier: GPL-3.0)

import Foundation

// MARK: - GachaDictLang

public enum GachaDictLang: String, CaseIterable, Sendable, Identifiable {
    case langCHS
    case langCHT
    case langDE
    case langEN
    case langES
    case langFR
    case langID
    case langIT
    case langJP
    case langKR
    case langPT
    case langRU
    case langTH
    case langTR
    case langVI

    // MARK: Public

    public static let tableSora = [
        "de-de": "Aether",
        "en-us": "Aether",
        "es-es": "Éter",
        "fr-fr": "Aether",
        "id-id": "Aether",
        "it-it": "Aether",
        "ja-jp": "空",
        "ko-kr": "아이테르",
        "pt-pt": "Aether",
        "ru-ru": "Итэр",
        "th-th": "Aether",
        "tr-tr": "Aether",
        "vi-vn": "Aether",
        "zh-cn": "空",
        "zh-tw": "空",
    ]

    public static let tableHotaru = [
        "de-de": "Lumine",
        "en-us": "Lumine",
        "es-es": "Lumina",
        "fr-fr": "Lumine",
        "id-id": "Lumine",
        "it-it": "Lumine",
        "ja-jp": "蛍",
        "ko-kr": "루미네",
        "pt-pt": "Lumine",
        "ru-ru": "Люмин",
        "th-th": "Lumine",
        "tr-tr": "Lumine",
        "vi-vn": "Lumine",
        "zh-cn": "荧",
        "zh-tw": "熒",
    ]

    public var id: String { langID }

    public var langID: String {
        switch self {
        case .langCHS: "zh-cn"
        case .langCHT: "zh-tw"
        case .langDE: "de-de"
        case .langEN: "en-us"
        case .langES: "es-es"
        case .langFR: "fr-fr"
        case .langID: "id-id"
        case .langIT: "it-it"
        case .langJP: "ja-jp"
        case .langKR: "ko-kr"
        case .langPT: "pt-pt"
        case .langRU: "ru-ru"
        case .langTH: "th-th"
        case .langTR: "tr-tr"
        case .langVI: "vi-vn"
        }
    }

    public var filename: String {
        rawValue.replacingOccurrences(of: "lang", with: "TextMap").appending(".json")
    }

    public var url: URL! {
        URL(string: """
        https://raw.githubusercontent.com/DimbreathBot/AnimeGameData/master/TextMap/\(filename)
        """)
    }
}

// MARK: - QualityType

public enum QualityType: String, Codable {
    case v5sp = "QUALITY_ORANGE_SP"
    case v5 = "QUALITY_ORANGE"
    case v4 = "QUALITY_PURPLE"
    case v3 = "QUALITY_BLUE"
    case v2 = "QUALITY_GREEN"
    case v1 = "QUALITY_GRAY"

    // MARK: Internal

    var asRankLevel: Int {
        switch self {
        case .v5, .v5sp: return 5
        case .v4: return 4
        case .v3: return 3
        case .v2: return 2
        case .v1: return 1
        }
    }
}

// MARK: - RawItem

public class RawItem: Codable {
    // MARK: Lifecycle

    required public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(Int.self, forKey: .id)
        let maybeRankLevel: Int? = try? container.decode(Int.self, forKey: .rankLevel)
        let maybeQualityType = try? container.decodeIfPresent(QualityType.self, forKey: .qualityType)
        if let maybeQualityType {
            self.rankLevel = maybeQualityType.asRankLevel
        } else {
            self.rankLevel = maybeRankLevel ?? 0
        }
        self.qualityType = try container.decodeIfPresent(QualityType.self, forKey: .qualityType)
        self.nameTextMapHash = try container.decode(Int.self, forKey: .nameTextMapHash)
        self.l10nMap = (try? container.decode([String: String].self, forKey: .l10nMap))
    }

    // MARK: Public

    public let id: Int
    public let rankLevel: Int
    public var qualityType: QualityType?
    public let nameTextMapHash: Int
    public var l10nMap: [String: String]?

    public var isCharacter: Bool {
        id > 114_514
    }
}

let urlHeader = """
https://raw.githubusercontent.com/DimbreathBot/AnimeGameData/master/ExcelBinOutput/
"""

let urlAvatarJSON = URL(string: urlHeader + "AvatarExcelConfigData.json")!
let urlWeaponJSON = URL(string: urlHeader + "WeaponExcelConfigData.json")!

func fetchAvatars() async throws -> [RawItem] {
    let (data, _) = try await URLSession.shared.data(from: urlAvatarJSON)
    let response = try JSONDecoder().decode([RawItem].self, from: data)
    return response
}

func fetchWeapons() async throws -> [RawItem] {
    let (data, _) = try await URLSession.shared.data(from: urlWeaponJSON)
    let response = try JSONDecoder().decode([RawItem].self, from: data)
    return response
}

let items = try await withThrowingTaskGroup(of: [RawItem].self, returning: [RawItem].self) { taskGroup in
    taskGroup.addTask { try await fetchAvatars() }
    taskGroup.addTask { try await fetchWeapons() }
    var images = [RawItem]()
    for try await result in taskGroup {
        images.append(contentsOf: result)
    }
    return images
}

let neededHashIDs = Set<String>(items.map(\.nameTextMapHash.description))

// MARK: - Get translations from AnimeGameData

let dictAll = try await withThrowingTaskGroup(
    of: (subDict: [String: String], lang: GachaDictLang).self,
    returning: [String: [String: String]].self
) { taskGroup in
    GachaDictLang.allCases.forEach { locale in
        taskGroup.addTask {
            let (data, _) = try await URLSession.shared.data(from: locale.url)
            var dict = try JSONDecoder().decode([String: String].self, from: data)
            let keysToRemove = Set<String>(dict.keys).subtracting(neededHashIDs)
            keysToRemove.forEach { dict.removeValue(forKey: $0) }
            return (subDict: dict, lang: locale)
        }
    }
    var results = [String: [String: String]]()
    for try await result in taskGroup {
        results[result.lang.langID] = result.subDict
    }
    return results
}

// MARK: - Apply translations

items.forEach { currentItem in
    GachaDictLang.allCases.forEach { localeID in
        let hashKey = currentItem.nameTextMapHash.description
        guard let dict = dictAll[localeID.langID]?[hashKey] else { return }
        if currentItem.l10nMap == nil { currentItem.l10nMap = [:] }
        currentItem.l10nMap?[localeID.langID] = dict
    }
}

// MARK: - Prepare Dictionary.

var dict: [String: RawItem] = [:]

items.forEach { item in
    guard item.id < 11_000_000,
          let desc = item.l10nMap?.description,
          !desc.contains("测试")
    else { return }
    let key = item.id.description
    protagonistName: switch item.id {
    case 10000005:
        item.l10nMap = GachaDictLang.tableSora
    case 10000007:
        item.l10nMap = GachaDictLang.tableHotaru
    default: break protagonistName
    }
    item.qualityType = nil
    dict[key] = item
}

let encoder = JSONEncoder()
encoder.outputFormatting = [.sortedKeys, .prettyPrinted]

var encoded = String(data: try encoder.encode(dict), encoding: .utf8)
encoded?.replace("rankLevel", with: "rank")

print(encoded ?? "Error happened.")
NSLog("All Tasks Done.")
