//
//  GachaItemManager.swift
//  GenshinPizzaHepler
//
//  Created by 戴藏龙 on 2023/3/28.
//

import Foundation
import CoreData

public class GachaModelManager {
    private init() {
        let containerURL = FileManager.default
            .containerURL(
                forSecurityApplicationGroupIdentifier: "group.GenshinPizzaHelper"
            )!
        let storeURL = containerURL
            .appendingPathComponent("PizzaGachaLog.splite")

        self
            .container =
            NSPersistentCloudKitContainer(name: "PizzaGachaLog")
        let description = container.persistentStoreDescriptions.first!
        description.url = storeURL

        description
            .cloudKitContainerOptions =
            .init(containerIdentifier: "iCloud.com.Canglong.PizzaGachaLog")
        description.setOption(
            true as NSNumber,
            forKey: "NSPersistentStoreRemoteChangeNotificationOptionKey"
        )

        container.loadPersistentStores { _, error in
            if let error = error {
                print("ERROR LOADING CORE DATA. \(error.localizedDescription)")
            }
        }

        container.viewContext.automaticallyMergesChangesFromParent = true
        container.viewContext
            .mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy

        container.viewContext.refreshAllObjects()
    }

    static let shared: GachaModelManager = .init()

    let container: NSPersistentCloudKitContainer

    func fetchAll() -> [GachaItem] {
        container.viewContext.refreshAllObjects()
        let request = GachaItemMO.fetchRequest()
        do {
            let gachaItemMOs = try container.viewContext.fetch(request)
            return gachaItemMOs.map { item in
                item.toGachaItem()
            }
        } catch {
            print("ERROR FETCHING CONFIGURATION. \(error.localizedDescription)")
            return []
        }
    }

    func checkIDAndUIDExists(uid: String, id: String) -> Bool {
        let request = GachaItemMO.fetchRequest()
        let predicate = NSPredicate(format: "(id = %@) AND (uid = %@)", id, uid)
        request.predicate = predicate

        do {
            let gachaItemMOs = try container.viewContext.fetch(request)
            return !gachaItemMOs.isEmpty
        } catch {
            print("ERROR FETCHING CONFIGURATION. \(error.localizedDescription)")
            return true
        }
    }

    func addRecordItems(_ items: [GachaItem_FM]) {
        items.forEach { item in
            addRecordItem(item)
        }
        save()
    }

    func addRecordItem(_ item: GachaItem_FM) {
        if !checkIDAndUIDExists(uid: item.uid, id: item.id) {
            let _ = item.toGachaItemMO(context: container.viewContext)
        }
    }

    func save() {
        do {
            try container.viewContext.save()
        } catch {
            print("ERROR SAVING. \(error.localizedDescription)")
        }
    }
}
