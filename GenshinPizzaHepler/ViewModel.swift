//
//  Model.swift
//  Genshin Resin Checker
//
//  Created by 戴藏龙 on 2022/7/12.
//

import Foundation
import SwiftUI
import CoreData

struct Account {
    var config: AccountConfiguration
    var result: FetchResult
    
    init(config: AccountConfiguration) {
        self.config = config
        self.result = .failure(.defaultStatus)
    }
    
    init(config: AccountConfiguration, result: FetchResult) {
        self.config = config
        self.result = result
    }
    
}

class ViewModel: ObservableObject {
    
    static let shared = ViewModel()
    
    @Published var accounts: [Account] = []

    // CoreData
    
    let container: NSPersistentContainer
    
    init() {
        container = NSPersistentContainer(name: "AccountConfiguration")
        container.loadPersistentStores { _, error in
            if let error = error {
                print("ERROR LOADING CORE DATA. \(error.localizedDescription)")
            }
        }
        fetchAccount()
    }
    
    func fetchAccount() {
        // 从Core Data更新账号信息
        let request = NSFetchRequest<AccountConfiguration>(entityName: "AccountConfiguration")
        
        do {
            let accountConfigs = try container.viewContext.fetch(request)
            if (accountConfigs != accounts.map { $0.config }) {
                accounts = accountConfigs.map { Account(config: $0) }
                refreshData()
            }
        } catch {
            print("ERROR FETCHING CONFIGURATION. \(error.localizedDescription)")
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
        saveAccount()
    }
    
    func deleteAccount(account: Account) {
        container.viewContext.delete(account.config)
        saveAccount()
    }
    
    func saveAccount() {
        do {
            try container.viewContext.save()
            fetchAccount()
        } catch {
            print("ERROR SAVING. \(error.localizedDescription)")
        }
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

extension AccountConfiguration {
    func fetchResult(_ completion: @escaping (FetchResult) -> ()) {
        guard (uid != nil) || (cookie != nil) else { return }
        
        API.Features.fetchInfos(region: self.server.region,
                                serverID: self.server.id,
                                uid: self.uid!,
                                cookie: self.cookie!)
        { completion($0) }
    }
}

