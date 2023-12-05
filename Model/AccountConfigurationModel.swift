//
//  CoreDataModel.swift
//  GenshinPizzaHepler
//
//  Created by 戴藏龙 on 2022/8/9.
//  基于CoreData配置账号所需核心信息

import CoreData
import Foundation
import HBMihoyoAPI
import HoYoKit
import Intents
import UIKit

class AccountConfigurationModel {
    // MARK: Lifecycle

    private init() {
        let containerURL = FileManager.default
            .containerURL(
                forSecurityApplicationGroupIdentifier: "group.GenshinPizzaHelper"
            )!
        let storeURL = containerURL
            .appendingPathComponent("AccountConfiguration.splite")

        self
            .container =
            NSPersistentCloudKitContainer(name: "AccountConfiguration")
        let description = container.persistentStoreDescriptions.first!
        description.url = storeURL

        description
            .cloudKitContainerOptions =
            .init(containerIdentifier: "iCloud.com.Canglong.GenshinPizzaHepler")
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

    // MARK: Internal

    // CoreData

    static let shared: AccountConfigurationModel = .init()

    let container: NSPersistentCloudKitContainer

    func fetchAccountConfigs() -> [AccountConfiguration] {
        // 从Core Data更新账号信息
        container.viewContext.refreshAllObjects()
        let request =
            NSFetchRequest<AccountConfiguration>(entityName: "AccountConfiguration")
        request.sortDescriptors = [.init(keyPath: \AccountConfiguration.priority, ascending: true)]
        do {
            let accountConfigs = try container.viewContext.fetch(request)
            return accountConfigs

        } catch {
            print("ERROR FETCHING CONFIGURATION. \(error.localizedDescription)")
            return []
        }
    }
}
