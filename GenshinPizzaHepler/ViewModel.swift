//
//  Model.swift
//  Genshin Resin Checker
//
//  Created by 戴藏龙 on 2022/7/12.
//

import Foundation
import SwiftUI
import CoreData

class ViewModel: ObservableObject {
    
    static let shared = ViewModel()
    
    @Published var accounts: [Account] = []

    // CoreData
    
    let accountConfigurationModel: AccountConfigurationModel = .shared
    
    
    init() {
        fetchAccount()
        // 尝试从UserDefault迁移数据
        if accounts.isEmpty {
            migrateDataFromUserDefault()
        }
    }
    
    func fetchAccount() {
        // 从Core Data更新账号信息
        let accountConfigs = accountConfigurationModel.fetchAccountConfigs()
        if (accountConfigs != self.accounts.map { $0.config }) {
            accounts = accountConfigs.map { Account(config: $0) }
            print("account fetched")
            refreshData()
        }
    }
    
    func addAccount(name: String, uid: String, cookie: String, server: Server) {
        // 新增账号至Core Data
        accountConfigurationModel.addAccount(name: name, uid: uid, cookie: cookie, server: server)
        fetchAccount()
    }
    
    func deleteAccount(account: Account) {
        accountConfigurationModel.deleteAccount(account: account)
        fetchAccount()
    }
    
    func saveAccount() {
        accountConfigurationModel.saveAccountConfigs()
        fetchAccount()
    }
    
    func refreshData() {
        accounts.forEach { account in
            let idx = accounts.firstIndex { account.config.uuid == $0.config.uuid }!
            account.config.fetchResult { result in
                self.accounts[idx] = Account(config: account.config, result: result)
                print("account refreshed")
            }
        }
    }
    
    
    
    
    
    fileprivate func migrateDataFromUserDefault() {
        // 迁移数据UserDefault
        if let userDefaults = UserDefaults(suiteName: "group.GenshinPizzaHelper") {
            if let name = userDefaults.string(forKey: "accountName"),
               let uid = userDefaults.string(forKey: "uid"),
               let cookie = userDefaults.string(forKey: "cookie"),
               var serverName = userDefaults.string(forKey: "server") {
                
                if serverName == "国服" { serverName = "天空岛"}
                if serverName == "B服" { serverName = "世界树" }
                
                accountConfigurationModel.addAccount(name: name, uid: uid, cookie: cookie, server: Server(rawValue: serverName)!)
                fetchAccount()
                
                userDefaults.removeObject(forKey: "accountName")
                userDefaults.removeObject(forKey: "uid")
                userDefaults.removeObject(forKey: "cookie")
                userDefaults.removeObject(forKey: "server")
            }
        }
    }
    
}


