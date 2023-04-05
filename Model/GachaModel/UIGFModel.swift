//
//  UIGFModel.swift
//  GenshinPizzaHepler
//
//  Created by 戴藏龙 on 2023/4/2.
//

import CoreData
import Foundation

// MARK: - UIGFJson

struct UIGFJson: Codable {
    struct Info: Codable {
        // MARK: Lifecycle

        init(uid: String, lang: String) {
            self.uid = uid
            self.lang = lang
            let now = Date()
            self.exportTime = now
            self.exportTimestamp = Int(now.timeIntervalSince1970)
            self.exportApp = "Pizza Helper"
            self.exportAppVersion = (
                Bundle.main
                    .infoDictionary!["CFBundleShortVersionString"] as! String
            )
            self.uigfVersion = "2.3"
        }

        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            self.uid = try container.decode(String.self, forKey: .uid)
            self.lang = try container.decode(String.self, forKey: .lang)

            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
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
        let lang: String
        let exportTime: Date?
        let exportTimestamp: Int?
        let exportApp: String?
        let exportAppVersion: String?
        let uigfVersion: String?
    }

    let info: Info
    let list: [UIGFGahcaItem]
}

// MARK: - UIGFGahcaItem

struct UIGFGahcaItem: Codable {
    // MARK: Lifecycle

    init(
        gachaType: _GachaType,
        itemId: String,
        count: String,
        time: Date,
        name: String,
        itemType: GachaItemType,
        rankType: GachaItem.RankType,
        id: String
    ) {
        self.gachaType = gachaType
        self.itemId = itemId
        self.count = count
        self.time = time
        self.name = name
        self.itemType = itemType
        self.rankType = rankType
        self.id = id
        self.uigfGachaType = GachaType.from(gachaType)
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        if let gcTypeInt = Int(
            try container
                .decode(String.self, forKey: .gachaType)
        ),
            let gcTypeEnum = _GachaType(rawValue: gcTypeInt) {
            self.gachaType = gcTypeEnum
        } else {
            throw DecodingError.dataCorrupted(.init(
                codingPath: [CodingKeys.gachaType],
                debugDescription: "invalid gacha_type format: \(try container.decode(String.self, forKey: .gachaType))"
            ))
        }

        self.itemId = try container.decodeIfPresent(
            String.self,
            forKey: .itemId
        ) ?? ""
        self.count = try container
            .decodeIfPresent(String.self, forKey: .count) ?? "1"

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        if let date = dateFormatter
            .date(from: try container.decode(String.self, forKey: .time)) {
            self.time = date
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
        ),
            let type = GachaItemType.fromCNRaw(raw) {
            self.itemType = type
        } else {
            self.itemType = .findByName(name)
        }
        if let raw = try container.decodeIfPresent(
            String.self,
            forKey: .rankType
        ),
            let intRaw = Int(raw),
            let type = GachaItem.RankType(rawValue: intRaw) {
            self.rankType = type
        } else {
            self.rankType = .findByName(name)
        }

        self.id = (try? container.decodeIfPresent(String.self, forKey: .id)) ?? ""
        if let uigfGachaInt = Int(
            try container
                .decode(String.self, forKey: .uigfGachaType)
        ),
            let gcTypeEnum = GachaType(rawValue: uigfGachaInt) {
            self.uigfGachaType = gcTypeEnum
        } else {
            throw DecodingError.dataCorrupted(.init(
                codingPath: [CodingKeys.gachaType],
                debugDescription: "invalid gacha_type format: \(try container.decode(String.self, forKey: .uigfGachaType))"
            ))
        }
    }

    // MARK: Internal

    enum CodingKeys: String, CodingKey {
        case gachaType, itemId, count, time, name, itemType, rankType, id,
             uigfGachaType
    }

    var gachaType: _GachaType
    var itemId: String
    var count: String
    var time: Date
    var name: String
    var itemType: GachaItemType
    var rankType: GachaItem.RankType
    var id: String
    var uigfGachaType: GachaType

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(String(gachaType.rawValue), forKey: .gachaType)
        try container.encode(itemId, forKey: .itemId)
        try container.encode(count, forKey: .count)

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        try container.encode(dateFormatter.string(from: time), forKey: .time)

        try container.encode(name, forKey: .name)
        try container.encode(itemType.cnRaw, forKey: .itemType)
        try container.encode(String(rankType.rawValue), forKey: .rankType)
        try container.encode(id, forKey: .id)
        try container.encode(
            String(uigfGachaType.rawValue),
            forKey: .uigfGachaType
        )
    }
}

extension UIGFGahcaItem {
    public mutating func editId(_ newId: String) {
        id = newId
    }

    public func toGachaItemMO(
        context: NSManagedObjectContext,
        uid: String,
        lang: String
    )
        -> GachaItemMO {
        let model = GachaItemMO(context: context)
        model.uid = uid
        model.gachaType = Int16(exactly: gachaType.rawValue)!
        model.itemId = itemId
        model.count = Int16(count)!
        model.time = time
        model.name = name
        model.lang = lang
        model.itemType = itemType.cnRaw
        model.rankType = Int16(exactly: rankType.rawValue)!
        model.id = id
        return model
    }
}

extension GachaItemMO {
    func toUIGFGahcaItem() -> UIGFGahcaItem {
        .init(
            gachaType: .init(rawValue: Int(gachaType))!,
            itemId: itemId!,
            count: String(count),
            time: time!,
            name: name!,
            itemType: .fromCNRaw(itemType!)!,
            rankType: .init(rawValue: Int(rankType))!,
            id: id!
        )
    }
}
