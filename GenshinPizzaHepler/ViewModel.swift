//
//  Model.swift
//  Genshin Resin Checker
//
//  Created by 戴藏龙 on 2022/7/12.
//

import Foundation
import SwiftUI
import CoreData

@MainActor class ViewModel: ObservableObject {
    
    static let shared = ViewModel()
    
    @Published var accounts: [Account] = [] 

    // CoreData
    
    let accountConfigurationModel: AccountConfigurationModel = .shared
    
    
    init() {
        fetchAccount()
        NotificationCenter.default.addObserver(self, selector: #selector(fetchAccount),
                                               name: .NSPersistentStoreRemoteChange, object: accountConfigurationModel.container.persistentStoreCoordinator)
    }

    @objc
    func fetchAccount() {
        // 从Core Data更新账号信息
        let accountConfigs = accountConfigurationModel.fetchAccountConfigs()
        if (accountConfigs != self.accounts.map { $0.config }) {
            DispatchQueue.main.async {
                self.accounts = accountConfigs.map { Account(config: $0) }
            }
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
    
}


