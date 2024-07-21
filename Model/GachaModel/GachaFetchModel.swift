//
//  GachaFetchModel.swift
//  GenshinPizzaHepler
//
//  Created by 戴藏龙 on 2023/3/27.
//

import CoreData
import Foundation
import GIPizzaKit

// MARK: - GachaResultFetched

public struct GachaResultFetched: Codable {
    let retcode: Int
    let message: String
    let data: GachaPageFetched?
}

// MARK: - GachaPageFetched

struct GachaPageFetched: Codable {
    let page: String
    let size: String
    let total: String
    let region: String
    let list: [GachaItemFetched]
}

// MARK: - GachaItemFetched

struct GachaItemFetched: Codable, Identifiable {
    let uid: String
    let gachaType: String
    let itemId: String
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
        case 0: return data!.list
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
