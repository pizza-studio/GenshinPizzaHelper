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
