//
//  GachaItemManager.swift
//  GenshinPizzaHepler
//
//  Created by 戴藏龙 on 2023/3/28.
//

import CoreData
import Defaults
import Foundation
import GIPizzaKit

public class GachaModelManager {
    // MARK: Lifecycle

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

        Task.detached { @MainActor in
            self.fixEmptyItemIDs()
        }
    }

    // MARK: Internal

    static let shared: GachaModelManager = .init()

    weak var viewModel: GachaViewModel?

    var persistentStoreCoordinator: NSPersistentStoreCoordinator {
        container.persistentStoreCoordinator
    }

    func fetchAll(uid: String, gachaType: GachaType? = nil) -> [GachaItem] {
        fetchAllMO(uid: uid, gachaType: gachaType).map { $0.toGachaItem() }
    }

    func fetchAllMO(uid: String, gachaType: GachaType? = nil) -> [GachaItemMO] {
        container.viewContext.performAndWait {
            container.viewContext.refreshAllObjects()
        }
        let request = GachaItemMO.fetchRequest()
        let predicate: NSPredicate
        if let gachaType = gachaType {
            if gachaType == .character {
                predicate = NSPredicate(
                    format: "(uid = %@) AND ((gachaType = %i) OR (gachaType = 400))",
                    uid,
                    gachaType.rawValue
                )
            } else {
                predicate = NSPredicate(format: "(uid = %@) AND (gachaType = %i)", uid, gachaType.rawValue)
            }
        } else {
            predicate = NSPredicate(format: "(uid = %@)", uid)
        }

        request.predicate = predicate
        let dateSortId = NSSortDescriptor(
            keyPath: \GachaItemMO.id,
            ascending: false
        )
        let dateSortTime = NSSortDescriptor(
            keyPath: \GachaItemMO.time, ascending: false
        )
        request.sortDescriptors = [dateSortTime, dateSortId]
        do {
            let gachaItemMOs = try container.viewContext.fetch(request)
            return gachaItemMOs
        } catch {
            print("ERROR FETCHING CONFIGURATION. \(error.localizedDescription)")
            return []
        }
    }

    func findExistingDuplicatedEntry(uid: String, id: String) -> [GachaItemMO] {
        let request = GachaItemMO.fetchRequest()
        let predicate = NSPredicate(format: "(id = %@) AND (uid = %@)", id, uid)
        request.predicate = predicate

        do {
            return try container.viewContext.fetch(request)
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

    @MainActor
    func fixEmptyItemIDs(refreshAll: Bool = false) {
        if refreshAll {
            container.viewContext.performAndWait {
                container.viewContext.refreshAllObjects()
            }
        }
        let request = GachaItemMO.fetchRequest()
        request.predicate = NSPredicate(format: #"(itemId = "") OR (itemId = NULL)"#)
        var errorHappened = false
        let fetched: [GachaItemMO]
        do {
            fetched = try container.viewContext.fetch(request)
        } catch {
            let errTxt = error.localizedDescription
            print(errTxt)
            fetched = []
        }
        fetched.forEach { target in
            if let targetName = target.name,
               let queriedID = GachaMetaDBExposed.shared.reverseQuery(for: targetName) {
                target.itemId = queriedID.description
            } else {
                errorHappened = true
            }
        }
        save()
        if errorHappened {
            Task.detached { @MainActor in
                try? await GachaMetaDBExposed.Sputnik.updateLocalGachaMetaDB()
                self.fixEmptyItemIDs()
            }
        }
    }

    func addRecordItems(
        _ items: [GachaItemFetched],
        isNew: @escaping ((Bool) -> ())
    ) {
        container.viewContext.perform { [self] in
            var needsIDFix = false
            items.forEach { item in
                if item.itemId.isEmpty {
                    needsIDFix = true
                }
                self.addRecordItem(item, isNew: isNew)
            }
            if needsIDFix {
                Task.detached { @MainActor in
                    self.fixEmptyItemIDs()
                }
            }
            save()
        }
    }

    /// 返回已保存的新数据数量
    func addRecordItems(
        _ items: [UIGFGachaItem],
        uid: String,
        profile: UIGFGachaProfile
    )
        -> Int {
        var count = 0
        container.viewContext.performAndWait {
            items.enumerated().forEach { index, item in
                var item = item
                if item.id == "" {
                    item.editId(String(index))
                }
                if !checkIDAndUIDExists(uid: uid, id: item.id) {
                    _ = item.toGachaItemMO(
                        context: container.viewContext,
                        uid: uid,
                        profile: profile
                    )
                    count += 1
                }
            }
        }
        save()
        return count
    }

    func addRecordItems(
        _ items: [GachaItemFetched]
    )
        -> Int {
        let newCount = items.enumerated().map { index, item in
            var item = item
            if item.id == "" {
                item.editId(String(index))
            }
            return self.addRecordItem(item)
        }.map { $0 ? 1 : 0 }.reduce(0, +)
        save()
        return newCount
    }

    func save() {
        do {
            try container.viewContext.save()
            if let viewModel = viewModel {
                viewModel.objectWillChange.send()
                viewModel.filterGachaItem()
            }
        } catch {
            print("ERROR SAVING. \(error.localizedDescription)")
        }
    }

    func deleteAllRecord() {
        let fetchRequest = GachaItemMO.fetchRequest()
        do {
            let models = try container.viewContext.fetch(fetchRequest)
            models.forEach { item in
                container.viewContext.delete(item)
            }
            save()
        } catch {
            print(error)
        }
    }

    func cleanDuplicatedItems() -> Int {
        var deletedItemCount = 0
        container.viewContext.refreshAllObjects()
        let request = GachaItemMO.fetchRequest()
        do {
            let items = try container.viewContext.fetch(request)
            Dictionary(grouping: items) { item in
                item.id! + item.uid!
            }.forEach { _, items in
                if items.count > 1 {
                    items[1...].forEach { item in
                        container.viewContext.delete(item)
                        deletedItemCount += 1
                    }
                }
            }
            save()
            return deletedItemCount
        } catch {
            print(error.localizedDescription)
            return deletedItemCount
        }
    }

    /// 删除数据，并返回删除的数据条数
    func deleteData(
        for uid: String,
        startDate: Date,
        endData: Date,
        removeAll: Bool
    )
        -> Int {
        container.viewContext.refreshAllObjects()
        let request = GachaItemMO.fetchRequest()
        var predicate = NSPredicate(
            format: "(uid = %@) AND (time >= %@) AND (time <= %@)",
            uid,
            startDate as NSDate,
            endData as NSDate
        )
        if removeAll {
            predicate = NSPredicate(format: "(uid = %@)", uid)
        }
        request.predicate = predicate
        do {
            let items = try container.viewContext.fetch(request)
            items.forEach { item in
                container.viewContext.delete(item)
            }
            save()
            return items.count
        } catch {
            print(error.localizedDescription)
            return 0
        }
    }

    func allAvaliableUID() -> [String] {
        let request =
            NSFetchRequest<NSFetchRequestResult>(entityName: "GachaItemMO")
        request.resultType = .dictionaryResultType
        request.returnsDistinctResults = true
        request.propertiesToFetch = ["uid"]
        if let res = try? container.viewContext
            .fetch(request) as? [[String: String]] {
            return res.compactMap { $0["uid"] }
        } else {
            return []
        }
    }

    // MARK: Private

    @MainActor
    private let container: NSPersistentCloudKitContainer
    private let queue = DispatchQueue(
        label: "com.GenshinPizzaHepler.SaveGacha",
        qos: .background
    )

    @discardableResult
    private func addRecordItem(
        _ item: GachaItemFetched,
        isNew: ((Bool) -> ())? = nil
    )
        -> Bool {
        var foundExistingRecords = findExistingDuplicatedEntry(uid: item.uid, id: item.id)
        /// 删掉既有重复记录。
        while foundExistingRecords.count > 1, let firstEntry = foundExistingRecords.first {
            container.viewContext.delete(firstEntry)
            foundExistingRecords.removeFirst()
        }
        if let existingRecord = foundExistingRecords.first {
            // 修复错误的时区资讯。
            existingRecord.time = item.time
            isNew?(false)
            return false
        } else {
            _ = item.toGachaItemMO(context: container.viewContext)
            isNew?(true)
            return true
        }
    }
}
