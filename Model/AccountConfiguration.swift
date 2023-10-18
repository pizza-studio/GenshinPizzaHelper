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
    var safeCookie: String {
        get {
            cookie ?? ""
        } set {
            cookie = newValue
        }
    }

    @NSManaged
    public var deviceFingerPrint: String?
    var safeDeviceFingerPrint: String {
        get {
            deviceFingerPrint ?? ""
        } set {
            deviceFingerPrint = newValue
        }
    }

    @NSManaged
    public var name: String?
    var safeName: String {
        get {
            name ?? ""
        } set {
            name = newValue
        }
    }

    @NSManaged
    public var serverRawValue: String?
    @NSManaged
    public var uid: String?
    var safeUid: String {
        get {
            uid ?? ""
        } set {
            uid = newValue
        }
    }
    @NSManaged
    public var uuid: UUID?
    var safeUuid: String {
        get {
            uuid ?? UUID()
        } set {
            uuid = newValue
        }
    }
    @NSManaged
    public var priority: Int
}

// MARK: Identifiable

extension AccountConfiguration: Identifiable {
    public var id: UUID { uuid ?? UUID() }
}
