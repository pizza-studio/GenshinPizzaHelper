//
//  GachaModel.swift
//  GenshinPizzaHepler
//
//  Created by 戴藏龙 on 2023/3/28.
//

import Foundation
import CoreData

extension GachaItemMO {
    public func toGachaItem() -> GachaItem {
        return .init(uid: self.uid!, gachaType: .init(rawValue: Int(self.gachaType))!, itemId: self.itemId!, count: Int(self.count), time: self.time!, name: self.name!, lang: self.lang!, itemType: self.itemType!, rankType: .init(rawValue: Int(self.rankType))!, id: self.id!)
    }
}

extension GachaItem_FM {
    public func toGachaItemMO(context: NSManagedObjectContext) -> GachaItemMO {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let model = GachaItemMO(context: context)
        model.uid = self.uid
        model.gachaType = Int16(self.gachaType)!
        model.itemId = self.itemId
        model.count = Int16(self.count)!
        model.time = dateFormatter.date(from: self.time)!
        model.name = self.name
        model.lang = self.lang
        model.itemType = self.itemType
        model.rankType = Int16(self.rankType)!
        model.id = self.id
        return model
    }
}
