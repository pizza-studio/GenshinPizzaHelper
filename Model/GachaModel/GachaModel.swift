//
//  GachaModel.swift
//  GenshinPizzaHepler
//
//  Created by 戴藏龙 on 2023/3/28.
//

import CoreData
import Foundation

extension GachaItemMO {
    public func toGachaItem() -> GachaItem {
        .init(
            uid: uid!,
            gachaType: .init(rawValue: Int(gachaType))!,
            itemId: itemId!,
            count: Int(count),
            time: time!,
            name: name!,
            lang: lang!,
            itemType: itemType!,
            rankType: .init(rawValue: Int(rankType))!,
            id: id!
        )
    }
}

extension GachaItem_FM {
    public func toGachaItemMO(context: NSManagedObjectContext) -> GachaItemMO {
        let model = GachaItemMO(context: context)
        model.uid = uid
        model.gachaType = Int16(gachaType)!
        model.itemId = itemId
        model.count = Int16(count)!
        model.time = time
        model.name = name
        model.lang = lang
        model.itemType = itemType
        model.rankType = Int16(rankType)!
        model.id = id
        return model
    }
}
