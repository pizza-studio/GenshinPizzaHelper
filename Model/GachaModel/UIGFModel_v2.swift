// (c) 2022 and onwards Pizza Studio (GPL v3.0 License).
// ====================
// This code is released under the GPL v3.0 License (SPDX-License-Identifier: GPL-3.0)

import CoreData
import Defaults
import Foundation
import GIPizzaKit
import SwiftUI
import UniformTypeIdentifiers

// MARK: - UIGFv2

// 原披助手不再提供 UIGFv2~v3 格式（也就是 GIGF 格式）的导出支援，而是仅保留导入的功能。
// 没写明 lang 的一律按照简体中文来处理；有写明 lang 的则将 name 转译成简体中文。

struct UIGFv2: Decodable {
    struct Info: Decodable {
        // MARK: Lifecycle

        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            self.uid = try container.decode(String.self, forKey: .uid)
            self.lang = try container.decodeIfPresent(GachaLanguageCode.self, forKey: .lang) ?? .zhHans

            let dateFormatter = DateFormatter.Gregorian()
            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            dateFormatter.locale = Locale(identifier: "en_US_POSIX")
            if let dateString = try container.decodeIfPresent(
                String.self,
                forKey: .exportTime
            ),
                let date = dateFormatter.date(from: dateString) {
                self.exportTime = date
            } else {
                self.exportTime = nil
            }

            self.exportTimestamp = nil
            self.exportApp = try container.decodeIfPresent(
                String.self,
                forKey: .exportApp
            )
            self.exportAppVersion = try container.decodeIfPresent(
                String.self,
                forKey: .exportAppVersion
            )
            self.uigfVersion = try container.decodeIfPresent(
                String.self,
                forKey: .uigfVersion
            )
        }

        // MARK: Internal

        enum CodingKeys: String, CodingKey {
            case uid, lang, exportTime, exportApp, exportAppVersion, uigfVersion
        }

        let uid: String
        let lang: GachaLanguageCode
        let exportTime: Date?
        let exportTimestamp: Int?
        let exportApp: String?
        let exportAppVersion: String?
        let uigfVersion: String?
    }

    let info: Info
    let list: [GIGFGachaItem]
}

// MARK: - GIGFGachaItem

/// UIGFv2~v3 格式（也就是 GIGF 格式）的 GachaItem。
struct GIGFGachaItem: Decodable {
    // MARK: Lifecycle

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        if let gcTypeStr = try container.decodeIfPresent(String.self, forKey: .gachaType),
           let gcTypeEnum = UIGFv4.ProfileGI.GachaItemGI.GachaTypeGI(rawValue: gcTypeStr) {
            self.gachaType = gcTypeEnum
        } else {
            throw DecodingError.dataCorrupted(.init(
                codingPath: [CodingKeys.gachaType],
                debugDescription: "invalid gacha_type format."
            ))
        }

        self.itemId = try container.decodeIfPresent(
            String.self,
            forKey: .itemId
        ) ?? ""
        self.count = try container
            .decodeIfPresent(String.self, forKey: .count) ?? "1"

        let dateFormatter = DateFormatter.Gregorian()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        if let timeStr = try? container.decode(String.self, forKey: .time),
           dateFormatter.date(from: try container.decode(String.self, forKey: .time)) != nil {
            self.time = timeStr
        } else {
            throw DecodingError.dataCorrupted(.init(
                codingPath: [CodingKeys.time],
                debugDescription: "invalid date format: \(try container.decode(String.self, forKey: .time))"
            ))
        }

        self.name = try container.decode(String.self, forKey: .name)
        if let raw = try container.decodeIfPresent(
            String.self,
            forKey: .itemType
        ) {
            self.itemType = GachaItemType(rawString: raw).cnRaw
        } else {
            self.itemType = GachaItemType.weapon.cnRaw
        }
        if let raw = try container.decodeIfPresent(
            String.self,
            forKey: .rankType
        ),
            let intRaw = Int(raw),
            let type = GachaItem.RankType(rawValue: intRaw) {
            self.rankType = type
        } else {
            self.rankType = nil
        }

        self.id = (try? container.decodeIfPresent(String.self, forKey: .id)) ?? ""
        self.uigfGachaType = gachaType.uigfGachaType
    }

    // MARK: Internal

    enum CodingKeys: String, CodingKey {
        case gachaType, itemId, count, time, name, itemType, rankType, id,
             uigfGachaType
    }

    var gachaType: UIGFv4.ProfileGI.GachaItemGI.GachaTypeGI
    var itemId: String
    var count: String
    var time: String
    var name: String
    var itemType: String
    var rankType: GachaItem.RankType?
    var id: String
    var uigfGachaType: UIGFv4.ProfileGI.GachaItemGI.UIGFGachaTypeGI
}

// MARK: - Translator to UIGFv4 Gacha Item

extension UIGFv2 {
    func upgradeTo4thGenerationProfile() -> UIGFv4.ProfileGI {
        // MARK: Info

        var newInfo = UIGFv4.ProfileGI(
            lang: info.lang,
            list: [],
            timezone: GachaItem.getServerTimeZoneDelta(info.uid),
            uid: info.uid
        )

        let mainDB = GachaMetaDBExposed.shared.mainDB
        let revDB = mainDB.generateHotReverseQueryDict(for: info.lang.rawValue) ?? [:]

        list.forEach { v2Item in
            var newItemID = v2Item.itemId
            var newName = v2Item.name
            if newItemID.isEmpty {
                if let newItemIDInt = revDB[v2Item.name] {
                    newItemID = newItemIDInt.description
                }
            }
            if !newItemID.isEmpty {
                newName = GachaMetaDBExposed.shared.mainDB.plainQueryForNames(
                    itemID: newItemID, langID: self.info.lang.rawValue
                ) ?? v2Item.name
            }

            var maybeRankType: String? = v2Item.rankType?.rawValue.description ?? nil
            if maybeRankType == nil, !newItemID.isEmpty,
               let intMaybeRankType = mainDB.plainQueryForRarity(itemID: newItemID) {
                maybeRankType = intMaybeRankType.description
            }

            let v4Item = UIGFv4.ProfileGI.GachaItemGI(
                count: v2Item.count,
                gachaType: v2Item.gachaType,
                id: v2Item.id,
                itemID: newItemID,
                itemType: v2Item.itemType,
                name: newName,
                rankType: maybeRankType,
                time: v2Item.time,
                uigfGachaType: v2Item.gachaType.uigfGachaType
            )
            newInfo.list.append(v4Item)
        }

        return newInfo
    }
}
