//
//  AccountConfiguration+CoreDataClass.swift
//  GenshinPizzaHelper
//
//  Created by 戴藏龙 on 2023/10/17.
//
//

import CoreData
import Foundation
import HBMihoyoAPI
import HoYoKit

// MARK: - AccountConfiguration

@objc(AccountConfiguration)
public class AccountConfiguration: NSManagedObject {
    public override func awakeFromInsert() {
        super.awakeFromInsert()
        setPrimitiveValue(UUID(), forKey: #keyPath(AccountConfiguration.uuid))
        setPrimitiveValue(Server.china.rawValue, forKey: #keyPath(AccountConfiguration.serverRawValue))
        setPrimitiveValue("", forKey: #keyPath(AccountConfiguration.name))
        setPrimitiveValue("", forKey: #keyPath(AccountConfiguration.cookie))
        setPrimitiveValue("", forKey: #keyPath(AccountConfiguration.uid))
        setPrimitiveValue("", forKey: #keyPath(AccountConfiguration.deviceFingerPrint))
        setPrimitiveValue(0, forKey: #keyPath(AccountConfiguration.priority))
    }
}

extension AccountConfiguration {
    @nonobjc
    public class func fetchRequest() -> NSFetchRequest<AccountConfiguration> {
        NSFetchRequest<AccountConfiguration>(entityName: "AccountConfiguration")
    }

    @NSManaged
    public var cookie: String?
    @NSManaged
    public var deviceFingerPrint: String?
    @NSManaged
    public var name: String?
    @NSManaged
    public var serverRawValue: String?
    @NSManaged
    public var uid: String?
    @NSManaged
    public var uuid: UUID?
    @NSManaged
    public var priority: Int
}

// MARK: Identifiable

extension AccountConfiguration: Identifiable {
    public var id: UUID { uuid ?? UUID() }
}
