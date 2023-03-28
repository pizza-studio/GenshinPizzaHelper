//
//  File.swift
//
//
//  Created by 戴藏龙 on 2023/3/28.
//

import Foundation

// public func getGacha(url: String) throws -> GetGachaResult {
//    let decoder = JSONDecoder()
//    decoder.keyDecodingStrategy = .convertFromSnakeCase
//    if let data = try? decoder.decode(ConvertToGetGacha.self, from: get_gacha(url).toString().data(using: .utf8)!) {
//        return GetGachaResult.from(data)
//    } else {
//        return .failure(.decodeError)
//    }
// }

public typealias GetGachaResult = Result<[GachaItem], GetGachaError>

// MARK: - GachaItem

public struct GachaItem: Identifiable {
    // MARK: Lifecycle

    public init(
        uid: String,
        gachaType: _GachaType,
        itemId: String,
        count: Int,
        time: Date,
        name: String,
        lang: String,
        itemType: String,
        rankType: RankType,
        id: String
    ) {
        self.uid = uid
        self._gachaType = gachaType
        self.itemId = itemId
        self.count = count
        self.time = time
        self.name = name
        self.lang = lang
        self.itemType = itemType
        self.rankType = rankType
        self.id = id
    }

    // MARK: Public

    public enum RankType: Int {
        case three = 3
        case four = 4
        case five = 5
    }

    public let uid: String
    /// 祈愿类型。显示时因为两个角色祈愿混合现实，因此应当使用gachaType
    public let _gachaType: _GachaType
    public let itemId: String
    public let count: Int
    public let time: Date
    public let name: String
    public let lang: String
    public let itemType: String
    public let rankType: RankType
    public let id: String

    public var gachaType: GachaType {
        .from(_gachaType)
    }
}

// MARK: - GetGachaError

public enum GetGachaError: Error, Equatable {
    case incorrectAuthkey
    case authkeyTimeout
    case visitTooFrequently
    case networkError(message: String)
    case incorrectUrl
    case decodeError
    case unknowError(retcode: Int, message: String)
    case genAuthKeyError(message: String)
}

// MARK: LocalizedError

extension GetGachaError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .incorrectAuthkey:
            return "GetGachaError: incorrectAuthkey"
        case .authkeyTimeout:
            return "GetGachaError: authkeyTimeout"
        case .visitTooFrequently:
            return "GetGachaError: visitTooFrequently"
        case let .networkError(message):
            return "GetGachaError: networkError (\(message))"
        case .incorrectUrl:
            return "GetGachaError: incorrectUrl"
        case .decodeError:
            return "GetGachaError: decodeError"
        case let .unknowError(retcode, message):
            return "GetGachaError: unknowError (\(retcode), \(message))"
        case let .genAuthKeyError(message):
            return "GetGachaError: genAuthKeyError (\(message))"
        }
    }
}

// MARK: - GachaType
/// 祈愿池记录。区分两个不同角色池，仅用于储存
public enum _GachaType: Int, CaseIterable {
    case newPlayer = 100
    case standard = 200
    case character = 301
    case weapon = 302
    case character2 = 400
}

extension _GachaType {
    func localizedDescription() -> String {
        switch self {
        case .newPlayer:
            return "初行者推荐祈愿"
        case .standard:
            return "常驻祈愿"
        case .character:
            return "角色活动祈愿"
        case .weapon:
            return "武器活动祈愿"
        case .character2:
            return "角色活动祈愿-2"
        }
    }
}

/// 祈愿池记录，不区分两个角色池，用于UI
public enum GachaType {
    case newPlayer
    case standard
    case character
    case weapon
}

extension GachaType {
    static func from(_ innerGachaType: _GachaType) -> Self {
        switch innerGachaType {
        case .character, .character2: return .character
        case .standard: return .standard
        case .newPlayer: return .newPlayer
        case .weapon: return .weapon
        }
    }

    func localizedDescription() -> String {
        switch self {
        case .newPlayer:
            return "初行者推荐祈愿"
        case .standard:
            return "常驻祈愿"
        case .character:
            return "角色活动祈愿"
        case .weapon:
            return "武器活动祈愿"
        }
    }
}

extension _GachaType {
    public func first() -> Self {
        .standard
    }

    public func next() -> Self? {
        switch self {
        case .standard: return .character
        case .character: return .weapon
        case .character2: return nil
        default: return nil
        }
    }
}

extension GachaItem.RankType: Comparable {
    public static func < (lhs: GachaItem.RankType, rhs: GachaItem.RankType) -> Bool {
        lhs.rawValue < rhs.rawValue
    }
}
