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
    
    var refreshedAccount: Account {
        Account(config: config, result: config.fetchResult())
    }
    
    init(config: AccountConfiguration) {
        self.config = config
        self.result = .failure(.defaultStatus)
    }
    
    private init(config: AccountConfiguration, result: FetchResult) {
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
    }
    
    func fetchAccount() {
        let request = NSFetchRequest<AccountConfiguration>(entityName: "AccountConfiguration")
        
        do {
            accounts = []
            let accountConfigs = try container.viewContext.fetch(request)
            accountConfigs.forEach { accountConfig in
                accounts.append(Account(config: accountConfig))
            }
            refreshData()
        } catch {
            print("ERROR FETCHING CONFIGURATION. \(error.localizedDescription)")
        }
    }
    
    func addAccount(name: String, uid: String, cookie: String, server: Server) {
        let newAccount = AccountConfiguration(context: container.viewContext)
        newAccount.name = name
        newAccount.uid = uid
        newAccount.cookie = cookie
        newAccount.server = server
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
        accounts = accounts.map { $0.refreshedAccount }
    }
}

extension AccountConfiguration {
    func fetchResult() -> FetchResult {
        var result: FetchResult = .failure(.defaultStatus)
        guard (uid != nil) || (cookie != nil) else { return .failure(.noFetchInfo) }
        
        API.Features.fetchInfos(region: self.server.region,
                                serverID: self.server.id,
                                uid: self.uid!,
                                cookie: self.cookie!)
        { result = $0 }
        
        return result
    }
}


