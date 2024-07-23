//
//  GachaFetchModel.swift
//  GenshinPizzaHepler
//
//  Created by 戴藏龙 on 2023/3/27.
//

import CoreData
import Defaults
import Foundation
import GIPizzaKit

// MARK: - GachaResultFetched

/// 拿到的每一页的原始资料结构。
public struct GachaResultFetched: Codable {
    let retcode: Int
    let message: String
    var data: GachaPageFetched?
}

// MARK: - GachaPageFetched

struct GachaPageFetched: Codable {
    let page: String
    let size: String
    let total: String
    let region: String
    var list: [GachaItemFetched]
}

// MARK: - GachaItemFetched

struct GachaItemFetched: Codable, Identifiable {
    // MARK: Lifecycle

    init(
        uid: String,
        gachaType: String,
        itemId: String,
        count: String,
        time: Date,
        name: String,
        lang: GachaLanguageCode,
        itemType: String,
        rankType: String,
        id: String
    ) {
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

    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.uid = try container.decode(String.self, forKey: .uid)
        self.gachaType = try container.decode(String.self, forKey: .gachaType)
        self.count = try container.decode(String.self, forKey: .count)
        self.time = try container.decode(Date.self, forKey: .time)
        self.name = try container.decode(String.self, forKey: .name)
        self.lang = try container.decode(GachaLanguageCode.self, forKey: .lang)
        self.itemType = try container.decode(String.self, forKey: .itemType)
        self.rankType = try container.decode(String.self, forKey: .rankType)
        self.id = try container.decode(String.self, forKey: .id)
        var theItemID = (try? container.decode(String?.self, forKey: .itemId)) ?? ""
        if theItemID.isEmpty,
           let newItemID = GachaMetaDBExposed.shared.reverseQuery(for: name) {
            theItemID = newItemID.description
        }
        self.itemId = theItemID
    }

    // MARK: Internal

    let uid: String
    let gachaType: String
    var itemId: String
    let count: String
    let time: Date
    var name: String
    var lang: GachaLanguageCode
    var itemType: String
    let rankType: String
    var id: String
}

extension GachaResultFetched {
    func toGachaItemArray() throws -> [GachaItemFetched] {
        switch retcode {
        case 0:
            guard let data = data else {
                throw GetGachaError
                    .unknowError(retcode: 114_514, message: "Data is Nil.")
            }
            return data.list
        case -100: throw GetGachaError.incorrectAuthkey
        case -101: throw GetGachaError.authkeyTimeout
        case -110: throw GetGachaError.visitTooFrequently
        default: throw GetGachaError
            .unknowError(retcode: retcode, message: message)
        }
    }
}

extension GachaItemFetched {
    mutating func editId(_ newId: String) {
        id = newId
    }
}
