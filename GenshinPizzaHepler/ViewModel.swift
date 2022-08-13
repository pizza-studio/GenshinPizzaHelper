//
//  Model.swift
//  Genshin Resin Checker
//
//  Created by 戴藏龙 on 2022/7/12.
//

import Foundation
import SwiftUI
import CoreData
import StoreKit

@MainActor
class ViewModel: ObservableObject {
    
    static let shared = ViewModel()
    
    @Published var accounts: [Account] = [] {
        didSet {
            configs = accounts.map { $0.config }
        }
    }
    
    var configs: [AccountConfiguration] = []
    // CoreData
    
    let accountConfigurationModel: AccountConfigurationModel = .shared
    
    
    init() {
        self.fetchAccount()
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(fetchAccount),
                                               name: .NSPersistentStoreRemoteChange,
                                               object: accountConfigurationModel.container.persistentStoreCoordinator)
//        NotificationCenter.default.addObserver(self,
//                                               selector: #selector(fetchAccount),
//                                               name: NSNotification.Name.NSPersistentStoreCoordinatorStoresDidChange,
//                                               object: accountConfigurationModel.container.persistentStoreCoordinator)
    }
    
    @objc
    private func fetchAccount() {
        // 从Core Data更新账号信息
        DispatchQueue.main.async {
            let accountConfigs = self.accountConfigurationModel.fetchAccountConfigs()
            if !self.accounts.isEqualTo(accountConfigs) {
                self.accounts = accountConfigs.map { Account(config: $0) }
                self.refreshData()
                print("account fetched")
            }
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


extension Array where Element == Account {
    func isEqualTo(_ newAccountConfigs: [AccountConfiguration]) -> Bool {
        if (self.count == 0) && (newAccountConfigs.count == 0) { return true }
        if self.count < newAccountConfigs.count { return false }
        let accountUUIDs = self.map { $0.config.uuid ?? UUID() }
        let newAccountsUUIDs = newAccountConfigs.map { $0.uuid! }
        return (accountUUIDs.allSatisfy { newAccountsUUIDs.contains($0) } && newAccountsUUIDs.allSatisfy { accountUUIDs.contains($0) })
    }
}
