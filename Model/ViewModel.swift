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
    
    @Published var accounts: [Account] = []
    
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
    func fetchAccount() {
        // 从Core Data更新账号信息
        // 检查是否有更改，如果有更改则更新
        DispatchQueue.main.async {
            let accountConfigs = self.accountConfigurationModel.fetchAccountConfigs()

            if !self.accounts.isEqualTo(accountConfigs) {
                self.accounts = accountConfigs.map { Account(config: $0) }
                self.refreshData()
                print("account fetched")
            }
            if #available(iOSApplicationExtension 15.0, iOS 15.0, *) {
                self.accountConfigurationModel.donateIntent()
            }
        }
    }
    
    func forceFetchAccount() {
        // 强制从云端Core Data更新账号信息
        accounts = accountConfigurationModel.fetchAccountConfigs().map { Account(config: $0) }
        self.refreshData()
        print("force account fetched")
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
        if self.count != newAccountConfigs.count { return false }
        
        var isSame = true
        
        self.forEach { account in
            guard let uuid = account.config.uuid else { isSame = false; return }
            guard let compareAccount = (newAccountConfigs.first { $0.uuid == uuid }) else { isSame = false; return }
            if !(compareAccount.uid == account.config.uid && compareAccount.cookie == account.config.cookie && compareAccount.server == account.config.server) { isSame = false }
        }
        
        newAccountConfigs.forEach { config in
            guard let uuid = config.uuid else { isSame = false; return }
            guard let compareAccount = (self.first { $0.config.uuid == uuid }?.config) else { isSame = false; return }
            if !(compareAccount.uid == config.uid && compareAccount.cookie == config.cookie && compareAccount.server == config.server) { isSame = false }
        }
        
        return isSame
    }
}
