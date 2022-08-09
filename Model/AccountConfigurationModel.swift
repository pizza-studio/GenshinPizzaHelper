//
//  CoreDataModel.swift
//  GenshinPizzaHepler
//
//  Created by 戴藏龙 on 2022/8/9.
//

import Foundation
import CoreData

class AccountConfigurationModel {

    // CoreData
    
    static let shared: AccountConfigurationModel = AccountConfigurationModel()
    
    let container: NSPersistentContainer
    
    init() {
        container = NSPersistentContainer(name: "AccountConfiguration")
        container.loadPersistentStores { _, error in
            if let error = error {
                print("ERROR LOADING CORE DATA. \(error.localizedDescription)")
            }
        }
    }
    
    func fetchAccountConfigs() -> [AccountConfiguration] {
        // 从Core Data更新账号信息
        let request = NSFetchRequest<AccountConfiguration>(entityName: "AccountConfiguration")
        
        do {
            let accountConfigs = try container.viewContext.fetch(request)
            return accountConfigs
            
        } catch {
            print("ERROR FETCHING CONFIGURATION. \(error.localizedDescription)")
            return []
        }
    }
    
    func addAccount(name: String, uid: String, cookie: String, server: Server) {
        // 新增账号至Core Data
        let newAccount = AccountConfiguration(context: container.viewContext)
        newAccount.name = name
        newAccount.uid = uid
        newAccount.cookie = cookie
        newAccount.server = server
        newAccount.uuid = UUID()
        saveAccountConfigs()
    }
    
    func deleteAccount(account: Account) {
        container.viewContext.delete(account.config)
        saveAccountConfigs()
    }
    
    func saveAccountConfigs() {
        do {
            try container.viewContext.save()
        } catch {
            print("ERROR SAVING. \(error.localizedDescription)")
        }
    }
    
}
