//
//  File.swift
//  
//
//  Created by 戴藏龙 on 2023/3/28.
//

import Foundation

//public func getGacha(url: String) throws -> GetGachaResult {
//    let decoder = JSONDecoder()
//    decoder.keyDecodingStrategy = .convertFromSnakeCase
//    if let data = try? decoder.decode(ConvertToGetGacha.self, from: get_gacha(url).toString().data(using: .utf8)!) {
//        return GetGachaResult.from(data)
//    } else {
//        return .failure(.decodeError)
//    }
//}

public typealias GetGachaResult = Result<[GachaItem], GetGachaError>

public struct GachaItem: Identifiable {
    public let uid: String
    public let gachaType: GachaType
    public let itemId: String
    public let count: Int
    public let time: Date
    public let name: String
    public let lang: String
    public let itemType: String
    public let rankType: RankType
    public let id: String

    public enum RankType: Int {
        case three = 3
        case four = 4
        case five = 5
    }

    public init(uid: String, gachaType: GachaType, itemId: String, count: Int, time: Date, name: String, lang: String, itemType: String, rankType: RankType, id: String) {
        self.uid = uid
        self.gachaType = gachaType
        self.itemId = itemId
        self.count = count
        self.time = time
        self.name = name
        self.lang = lang
        self.itemType = itemType
        self.rankType = rankType
        self.id = id
    }
}

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

extension GetGachaError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .incorrectAuthkey:
            return "GetGachaError: incorrectAuthkey"
        case .authkeyTimeout:
            return "GetGachaError: authkeyTimeout"
        case .visitTooFrequently:
            return "GetGachaError: visitTooFrequently"
        case .networkError(let message):
            return "GetGachaError: networkError (\(message))"
        case .incorrectUrl:
            return "GetGachaError: incorrectUrl"
        case .decodeError:
            return "GetGachaError: decodeError"
        case .unknowError(let retcode, let message):
            return "GetGachaError: unknowError (\(retcode), \(message))"
        case .genAuthKeyError(let message):
            return "GetGachaError: genAuthKeyError (\(message))"
        }
    }
}

public enum GachaType: Int, CaseIterable {
    case newPlayer = 100
    case standard = 200
    case character = 301
    case weapon = 302
    case character2 = 400
}

public extension GachaType {
    func first() -> Self {
        .standard
    }
    func next() -> Self? {
        switch self {
        case .standard: return .character
        case .character: return .weapon
        case .character2: return nil
        default: return nil
        }
    }
}

//extension GachaItemMO {
//    static func from(_ data: GachaItem_FM) -> Self {
//        let dateFormatter = DateFormatter()
//        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
//        return .init(uid: data.uid, gachaType: Int(data.gachaType)!, itemId: data.itemId, count: Int(data.count)!, time: dateFormatter.date(from: data.time)!, name: data.name, lang: data.lang, itemType: data.itemType, rankType: Int(data.rankType)!, id: data.id)
//    }
//}
