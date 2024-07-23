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

// MARK: - Account

public typealias Account = AccountConfiguration

// MARK: - AccountConfiguration

@objc(AccountConfiguration)
public class AccountConfiguration: NSManagedObject {
    public override func awakeFromInsert() {
        super.awakeFromInsert()
        setPrimitiveValue(UUID(), forKey: #keyPath(Account.uuid))
        setPrimitiveValue(Server.china.rawValue, forKey: #keyPath(Account.serverRawValue))
        setPrimitiveValue("", forKey: #keyPath(Account.name))
        setPrimitiveValue("", forKey: #keyPath(Account.cookie))
        setPrimitiveValue("", forKey: #keyPath(Account.uid))
        setPrimitiveValue("", forKey: #keyPath(Account.deviceFingerPrint))
        setPrimitiveValue(0, forKey: #keyPath(Account.priority))
        setPrimitiveValue(nil, forKey: #keyPath(Account.sTokenV2))
    }
}

extension Account {
    @nonobjc
    public class func fetchRequest() -> NSFetchRequest<Account> {
        NSFetchRequest<Account>(entityName: "AccountConfiguration")
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

    public var hasValidCookie: Bool {
        !(cookie ?? "").isEmpty
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
    var safeUuid: UUID {
        get {
            uuid ?? UUID()
        } set {
            uuid = newValue
        }
    }

    @NSManaged
    public var priority: Int

    @NSManaged
    public var sTokenV2: String?
}

// MARK: - Account + Identifiable

extension Account: Identifiable {
    public var id: UUID { uuid ?? UUID() }
}

extension Account {
    func isValid() -> Bool {
        let fingerPrintValid = if server.region == .mainlandChina {
            deviceFingerPrint != nil && deviceFingerPrint != ""
        } else { true }
        return true
            && uid != nil
            && uid != ""
            && cookie != nil
            && cookie != ""
            && uuid != nil
            && name != nil
            && fingerPrintValid
    }
}
