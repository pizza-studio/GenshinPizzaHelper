//
//  Model.swift
//  Genshin Resin Checker
//
//  Created by 戴藏龙 on 2022/7/12.
//  View中用于加载信息的工具类

import CoreData
import Defaults
import DefaultsKeys
import Foundation
import HBMihoyoAPI
import HBPizzaHelperAPI
import StoreKit
import SwiftUI
import WatchConnectivity

// MARK: - ViewModel

@MainActor
class ViewModel: NSObject, ObservableObject {
    // MARK: Lifecycle

//    var session: WCSession

    init(session: WCSession = .default) {
//        self.session = session
        super.init()
//        self.session.delegate = self
//        session.activate()
        fetchAccountSansAsync()
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(fetchAccount),
            name: .NSPersistentStoreRemoteChange,
            object: accountConfigurationModel
                .container
                .persistentStoreCoordinator
        )
        #if !os(watchOS)
        attemptToFixLocalEnkaStorage()
        #endif
        #if canImport(ActivityKit)
        if #available(iOS 16.1, *) {
            // App 启动时也检查并清理可能的错误资料值。
            ResinRecoveryActivityController.backgroundSettingsSanityCheck()
        }
        #endif
    }

    // MARK: Internal

    static let shared = ViewModel()

    @Published
    var accounts: [Account] = []

    @Published
    var showDetailOfAccount: Account?
    @Published
    var showCharacterDetailOfAccount: Account?
    @Published
    var showingCharacterName: String?
    @Default(.detailPortalViewShowingAccountUUIDString)
    var showingAccountUUID: String?

    @Published
    var costumeMap: [CharacterAsset: CostumeAsset] = [:] {
        willSet {
            CharacterAsset.costumeMap = newValue
        }
    }

    var account: Account? {
        accounts.first { account in
            (account.config.uuid?.uuidString ?? "123") == showingAccountUUID
        }
    }

    #if !os(watchOS)
    @Published
    var charLoc: [String: String]? = try? JSONDecoder().decode(ENCharacterLoc.self, from: Defaults[.enkaMapLoc])
        .getLocalizedDictionary() {
        didSet {
            Defaults[.lastEnkaDataCheckDate] = .init()
        }
    }

    @Published
    var charMap: [String: ENCharacterMap.Character]? = try? JSONDecoder()
        .decode(ENCharacterMap.self, from: Defaults[.enkaMapCharacters]).characterDetails {
        didSet {
            Defaults[.lastEnkaDataCheckDate] = .init()
        }
    }
    #endif

    let accountConfigurationModel: AccountConfigurationModel = .shared

    func fetchAccountSansAsync() {
        let accountConfigs = accountConfigurationModel.fetchAccountConfigs()
        if Server(rawValue: Defaults[.defaultServer]) == nil {
            Defaults[.defaultServer] = (accountConfigs.first?.server ?? .asia).rawValue
        }

        if !accounts.isEqualTo(accountConfigs) {
            accounts = accountConfigs.map { Account(config: $0) }
            refreshData()
            print("account fetched")
            #if !os(watchOS)
            accountConfigs.forEach { config in
                if config.server.region == .cn {
                    if (config.deviceFingerPrint == nil) || (config.deviceFingerPrint == "") {
                        Task {
                            config
                                .deviceFingerPrint = (try? await MihoyoAPI.getDeviceFingerPrint(region: .cn)) ?? ""
                            try? self.accountConfigurationModel.container.viewContext.save()
                        }
                    }
                } else {
                    if config.deviceFingerPrint == nil {
                        config.deviceFingerPrint = ""
                        try? self.accountConfigurationModel.container.viewContext.save()
                    }
                }
            }
            let showingPlayerDetailOfAccountUUID = Defaults[.detailPortalViewShowingAccountUUIDString]
            if let showingPlayerDetailOfAccount = accounts
                .first(where: { account in
                    account.config.uuid?.uuidString == showingPlayerDetailOfAccountUUID
                }) {
                refreshPlayerDetail(
                    for: showingPlayerDetailOfAccount
                )
            }
            refreshLedgerData()
            #endif
        }
    }

    @objc
    func fetchAccount() {
        // 从Core Data更新账号信息
        // 检查是否有更改，如果有更改则更新
        DispatchQueue.main.async {
            self.fetchAccountSansAsync()
        }
    }

    func forceFetchAccount() {
        // 强制从云端Core Data更新账号信息
        accounts = accountConfigurationModel.fetchAccountConfigs()
            .map { Account(config: $0) }
        refreshData()
        print("force account fetched")
    }

    func addAccount(name: String, uid: String, cookie: String, server: Server) {
        // 添加的第一个账号作为材料刷新的时区
        if accounts.isEmpty {
            Defaults[.defaultServer] = server.rawValue
        }
        // 新增账号至Core Data
        accountConfigurationModel.addAccount(
            name: name,
            uid: uid,
            cookie: cookie,
            server: server
        )
        fetchAccount()
    }

    func deleteAccount(account: Account) {
        accounts.removeAll {
            account == $0
        }
        accountConfigurationModel.deleteAccount(account: account)
        fetchAccount()
    }

    func saveAccount() {
        accountConfigurationModel.saveAccountConfigs()
        fetchAccount()
    }

    func refreshData() {
        let accountsCount = accounts.count
        accounts.indices.forEach { index in
            accounts[index].fetchComplete = false
            accounts[index].config.fetchResult { result in
                guard accountsCount == self.accounts.count else { return }
                self.accounts[index].result = result
                self.accounts[index].background = .randomNamecardBackground
                self.accounts[index].fetchComplete = true
            }
        }
        refreshAbyssAndBasicInfo()
    }

    func refreshAbyssAndBasicInfo() {
        let accountsCount = accounts.count
        accounts.indices.forEach { index in
            #if !os(watchOS)
            let group = DispatchGroup()
            group.enter()
            accounts[index].config.fetchBasicInfo { basicInfo in
                guard accountsCount == self.accounts.count else { return }
                self.accounts[index].basicInfo = basicInfo
                self.accounts[index].uploadHoldingData()
                group.leave()
            }
            group.enter()
            self.accounts[index].config.fetchAbyssInfo { data in
                guard accountsCount == self.accounts.count else { return }
                self.accounts[index].spiralAbyssDetail = data
                group.leave()
            }
            group.notify(queue: .main) {
                guard accountsCount == self.accounts.count else { return }
                self.accounts[index].uploadAbyssData()
                Task {
                    guard accountsCount == self.accounts.count else { return }
                    await self.accounts[index].uploadHuTaoDBAbyssData()
                }
            }
            #endif
        }
    }

    #if !os(watchOS)
    func refreshPlayerDetail(for account: Account) {
        guard let index = accounts.firstIndex(of: account) else { return }
        let accountsCount = accounts.count
        // 如果之前返回了错误，则删除fail的result
        if let result = accounts[index].playerDetailResult,
           (try? result.get()) == nil {
            accounts[index].playerDetailResult = nil
        }
        accounts[index].fetchPlayerDetailComplete = false
        if let charLoc = charLoc, let charMap = charMap, charLoc.count * charMap.count != 0 {
            accounts[index].config
                .fetchPlayerDetail(
                    dateWhenNextRefreshable: try? accounts[index]
                        .playerDetailResult?.get().nextRefreshableDate
                ) { result in
                    switch result {
                    case let .success(model):
                        self.accounts[index]
                            .playerDetailResult = .success(.init(
                                playerDetailFetchModel: model,
                                localizedDictionary: charLoc,
                                characterMap: charMap
                            ))
                    case let .failure(error):
                        // 有崩溃报告指出此处的 self.accounts 不包含该 index 的内容，故增设限制条件。
                        // 如果在上文执行过程当中 accounts 的内容数量出现变动，则不执行这段内容。
                        if self.accounts.count == accountsCount, self.accounts[index].playerDetailResult == nil {
                            self.accounts[index]
                                .playerDetailResult = .failure(error)
                        }
                    }
                    self.refreshCostumeMap(for: self.accounts[index])
                    self.accounts[index].fetchPlayerDetailComplete = true
                }
        } else {
            let group = DispatchGroup()
            group.enter()
            PizzaHelperAPI.fetchENCharacterLocData(from: .mainlandCN) {
                Defaults[.enkaMapLoc] = try! JSONEncoder().encode($0)
                self.charLoc = $0.getLocalizedDictionary()
                group.leave()
            } onFailure: {
                PizzaHelperAPI.fetchENCharacterLocData(from: .global) {
                    self.charLoc = $0.getLocalizedDictionary()
                    group.leave()
                }
            }
            group.enter()
            PizzaHelperAPI.fetchENCharacterDetailData(from: .mainlandCN) {
                Defaults[.enkaMapCharacters] = try! JSONEncoder().encode($0)
                self.charMap = $0.characterDetails
                group.leave()
            } onFailure: {
                PizzaHelperAPI.fetchENCharacterDetailData(from: .global) {
                    Defaults[.enkaMapCharacters] = try! JSONEncoder().encode($0)
                    self.charMap = $0.characterDetails
                    group.leave()
                }
            }
            group.notify(queue: .main) {
                guard let charLoc = self.charLoc else {
                    self.accounts[index]
                        .playerDetailResult =
                        .failure(.failToGetLocalizedDictionary)
                    self.accounts[index].fetchPlayerDetailComplete = true
                    return
                }
                guard let charMap = self.charMap else {
                    self.accounts[index]
                        .playerDetailResult =
                        .failure(.failToGetCharacterDictionary)
                    self.accounts[index].fetchPlayerDetailComplete = true
                    return
                }
                self.accounts[index].config
                    .fetchPlayerDetail(
                        dateWhenNextRefreshable: try? self
                            .accounts[index].playerDetailResult?.get()
                            .nextRefreshableDate
                    ) { result in
                        switch result {
                        case let .success(model):
                            self.accounts[index]
                                .playerDetailResult = .success(.init(
                                    playerDetailFetchModel: model,
                                    localizedDictionary: charLoc,
                                    characterMap: charMap
                                ))
                        case let .failure(error):
                            if self.accounts[index]
                                .playerDetailResult == nil {
                                self.accounts[index]
                                    .playerDetailResult = .failure(error)
                            }
                        }
                        self.accounts[index]
                            .fetchPlayerDetailComplete = true
                    }
            }
        }
    }

    /// 同步时装设定至全局预设值。
    func refreshCostumeMap(for specifiedAccount: Account? = nil) {
        guard let playerDetail = try? (specifiedAccount ?? account)?.playerDetailResult?.get() else { return }
        guard !playerDetail.avatars.isEmpty else { return }
        CharacterAsset.costumeMap.removeAll()
        let assetPairs = playerDetail.avatars.compactMap { ($0.characterAsset, $0.costumeAsset) }
        var intDictionary: [Int: Int] = [:]
        assetPairs.forEach { characterAsset, costumeAsset in
            CharacterAsset.costumeMap[characterAsset] = costumeAsset
            intDictionary[characterAsset.rawValue] = costumeAsset?.rawValue ?? nil
        }
        costumeMap = CharacterAsset.costumeMap
        Defaults[.cachedCostumeMap] = intDictionary
        objectWillChange.send()
    }

    func refreshLedgerData() {
        accounts.indices.forEach { index in
            self.accounts[index].config.fetchLedgerData { result in
                self.accounts[index].ledgeDataResult = result
            }
        }
    }

    // 检查本地 Enka 暂存资料是否损毁。如有损毁，则用 Bundle 内建的 JSON 重建之。
    public func attemptToFixLocalEnkaStorage() {
        guard enkaDataWrecked else { return }
        Defaults.reset(.enkaMapLoc)
        Defaults.reset(.enkaMapCharacters)
        charLoc = try? JSONDecoder()
            .decode(ENCharacterLoc.self, from: Defaults[.enkaMapLoc]).getLocalizedDictionary()
        charMap = try? JSONDecoder()
            .decode(ENCharacterMap.self, from: Defaults[.enkaMapCharacters]).characterDetails
        guard enkaDataWrecked else { return }
        // 本地 JSON 资料恢复了也没用。一般情况下不该出现这种情况。
        refreshCharLocAndCharMapSansAsync()
    }

    public var enkaDataWrecked: Bool {
        charLoc == nil || charMap == nil || (charLoc?.count ?? 0) * (charMap?.count ?? 0) == 0
    }

    public var enkaDataNeedsUpdate: Bool {
        var performCheck = enkaDataWrecked
        if !performCheck, let expired = Calendar.current.date(byAdding: .hour, value: -2, to: Date()),
           Defaults[.lastEnkaDataCheckDate] < expired {
            print("Enka data expired, triggering update.")
            performCheck = true
        } else if performCheck {
            print("Enka data (in local storage) corrupted, triggering update.")
        }
        return performCheck
    }

    func refreshCharLocAndCharMapSansAsync() {
        guard enkaDataNeedsUpdate else { return }
        PizzaHelperAPI.fetchENCharacterLocData(from: .mainlandCN) {
            Defaults[.enkaMapLoc] = try! JSONEncoder().encode($0)
            self.charLoc = $0.getLocalizedDictionary()
        } onFailure: {
            PizzaHelperAPI.fetchENCharacterLocData(from: .global) {
                Defaults[.enkaMapLoc] = try! JSONEncoder().encode($0)
                self.charLoc = $0.getLocalizedDictionary()
            }
        }
        PizzaHelperAPI.fetchENCharacterDetailData(from: .mainlandCN) {
            Defaults[.enkaMapCharacters] = try! JSONEncoder().encode($0)
            self.charMap = $0.characterDetails
        } onFailure: {
            PizzaHelperAPI.fetchENCharacterDetailData(from: .global) {
                Defaults[.enkaMapCharacters] = try! JSONEncoder().encode($0)
                self.charMap = $0.characterDetails
            }
        }
    }
    #endif
}

// MARK: WCSessionDelegate

extension ViewModel: WCSessionDelegate {
    #if !os(watchOS)
    func sessionDidBecomeInactive(_ session: WCSession) {}

    func sessionDidDeactivate(_ session: WCSession) {}
    #endif

    func session(
        _ session: WCSession,
        activationDidCompleteWith activationState: WCSessionActivationState,
        error: Error?
    ) {
        if let error = error {
            print(error.localizedDescription)
        } else {
            print("The session has completed activation.")
        }
    }

    func session(
        _ session: WCSession,
        didReceiveMessage message: [String: Any]
    ) {
        DispatchQueue.main.async {
            let accounts = message["accounts"] as? [Account]
            print(accounts == nil ? "data nil" : "data received")
            self.accounts = accounts ?? []
        }
    }
}

extension Array where Element == Account {
    func isEqualTo(_ newAccountConfigs: [AccountConfiguration]) -> Bool {
        if isEmpty, newAccountConfigs.isEmpty { return true }
        if count != newAccountConfigs.count { return false }

        var isSame = true

        forEach { account in
            guard let uuid = account.config.uuid else { isSame = false; return }
            guard let compareAccount = (
                newAccountConfigs
                    .first { $0.uuid == uuid }
            ) else { isSame = false; return }
            if !(
                compareAccount.uid == account.config.uid && compareAccount
                    .cookie == account.config.cookie && compareAccount
                    .server == account.config.server
            ) { isSame = false }
        }

        newAccountConfigs.forEach { config in
            guard let uuid = config.uuid else { isSame = false; return }
            guard let compareAccount = (
                self.first { $0.config.uuid == uuid }?
                    .config
            ) else { isSame = false; return }
            if !(
                compareAccount.uid == config.uid && compareAccount
                    .cookie == config.cookie && compareAccount.server == config
                    .server
            ) { isSame = false }
        }

        return isSame
    }
}
