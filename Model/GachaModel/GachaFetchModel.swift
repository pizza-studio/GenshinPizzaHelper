//
//  GachaFetchModel.swift
//  GenshinPizzaHepler
//
//  Created by 戴藏龙 on 2023/3/27.
//

import CoreData
import Foundation
import GIPizzaKit

// MARK: - GachaResult_FM

public struct GachaResult_FM: Codable {
    let retcode: Int
    let message: String
    let data: GachaPage_FM?
}

// MARK: - GachaPage_FM

struct GachaPage_FM: Codable {
    let page: String
    let size: String
    let total: String
    let region: String
    let list: [GachaItem_FM]
}

// MARK: - GachaItem_FM

struct GachaItem_FM: Codable, Identifiable {
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

extension GachaResult_FM {
    func toGachaItemArray() throws -> [GachaItem_FM] {
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

extension GachaItem_FM {
    mutating func editId(_ newId: String) {
        id = newId
    }
}
