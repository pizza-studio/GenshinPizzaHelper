import Foundation

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
        self.nameL10nMap = try? container.decode([String: String]?.self, forKey: .nameL10nMap)
    }

    // MARK: Public

    public let id: Int
    public let rankLevel: Int
    public var qualityType: QualityType?
    public let nameTextMapHash: Int
    public var nameL10nMap: [String: String]?

    public var isCharacter: Bool {
        id > 114_514
    }

    // MARK: Internal

    enum CodingKeys: String, CodingKey {
        case id, rankLevel, qualityType, nameTextMapHash
        case nameL10nMap = "name_localization_map"
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

let neededIDs = items.map(\.nameTextMapHash.description)

var dict: [String: RawItem] = [:]

items.forEach { item in
    let key = item.id.description
    item.qualityType = nil
    dict[key] = item
}

let encoder = JSONEncoder()
encoder.outputFormatting = [.sortedKeys, .prettyPrinted]

var encoded = String(data: try encoder.encode(dict), encoding: .utf8)
encoded?.replace("rankLevel", with: "rank")

print(encoded ?? "Error happened.")
NSLog("All Tasks Done.")
