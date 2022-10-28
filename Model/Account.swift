//
//  Account.swift
//  GenshinPizzaHepler
//
//  Created by 戴藏龙 on 2022/8/9.
//  Account所需的所有信息

import Foundation

struct Account: Equatable, Hashable {
    var config: AccountConfiguration

    // 树脂等信息
    var result: FetchResult?
    var background: WidgetBackground = WidgetBackground.randomNamecardBackground
    var basicInfo: BasicInfos?
    var fetchComplete: Bool = false

    #if !os(watchOS)
    var playerDetailResult: Result<PlayerDetail, PlayerDetail.PlayerDetailError>?
    var fetchPlayerDetailComplete: Bool = false

    // 深渊
    var spiralAbyssDetail: AccountSpiralAbyssDetail?
    // 账簿，旅行札记
    var ledgeDataResult: LedgerDataFetchResult?
    #endif

    init(config: AccountConfiguration) {
        self.config = config
    }

    static func == (lhs: Account, rhs: Account) -> Bool {
        return lhs.config == rhs.config
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(config)
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

    func fetchBasicInfo(_ completion: @escaping (BasicInfos) -> ()) {
        API.Features.fetchBasicInfos(region: self.server.region, serverID: self.server.id, uid: self.uid ?? "", cookie: self.cookie ?? "") { result in
            switch result {
            case .success(let data) :
                completion(data)
            case .failure(_):
                print("fetching basic info error")
                break
            }
        }
    }

    #if !os(watchOS)
    func fetchPlayerDetail(dateWhenNextRefreshable: Date?, _ completion: @escaping (Result<PlayerDetailFetchModel, PlayerDetail.PlayerDetailError>) -> ()) {
        guard let uid = self.uid else { return }
        API.OpenAPIs.fetchPlayerDetail(uid, dateWhenNextRefreshable: dateWhenNextRefreshable) { result in
            completion(result)
        }
    }


    func fetchAbyssInfo(round: AbyssRound, _ completion: @escaping (SpiralAbyssDetail) -> ()) {
        // thisAbyssData
        API.Features.fetchSpiralAbyssInfos(region: self.server.region, serverID: self.server.id, uid: self.uid!, cookie: self.cookie!, scheduleType: round.rawValue) { result in
            switch result {
            case .success(let resultData):
                completion(resultData)
            case .failure(_):
                print("Fail")
            }
        }
    }

    func fetchAbyssInfo(_ completion: @escaping (AccountSpiralAbyssDetail) -> ()) {
        var this: SpiralAbyssDetail?
        var last: SpiralAbyssDetail?
        let group = DispatchGroup()
        group.enter()
        self.fetchAbyssInfo(round: .this) { data in
            this = data
            group.leave()
        }
        group.enter()
        self.fetchAbyssInfo(round: .last) { data in
            last = data
            group.leave()
        }
        group.notify(queue: .main) {
            guard let this = this, let last = last else { return }
            completion(AccountSpiralAbyssDetail(this: this, last: last))
        }
    }

    func fetchLedgerData(_ completion: @escaping (LedgerDataFetchResult) -> ()) {
        API.Features.fetchLedgerInfos(month: 0, uid: self.uid!, serverID: self.server.id, region: self.server.region, cookie: self.cookie!) { result in
            completion(result)
        }
    }

    enum AbyssRound: String {
        case this = "1", last = "2"
    }
    #endif
}

extension Account {
    #if !os(watchOS)
    func uploadHoldingData() {
        print("uploadHoldingData START")
        let userDefault = UserDefaults.standard
        var hasUploadedAvatarHoldingDataHash: [Int] = userDefault.array(forKey: "hasUploadedAvatarHoldingDataHash") as? [Int] ?? []
        if let avatarHoldingData = AvatarHoldingData(account: self, which: .this) {
            let encoder = JSONEncoder()
            encoder.outputFormatting = .sortedKeys
            let data = try! encoder.encode(avatarHoldingData)
            guard !hasUploadedAvatarHoldingDataHash.contains(data.hashValue) else { return }
            API.PSAServer.uploadUserData(path: "/user_holding/upload", data: data) { result in
                switch result {
                case .success(_):
                    print("upload avatarHoldingData succeed")
                    hasUploadedAvatarHoldingDataHash.append(data.hashValue)
                    userDefault.set(hasUploadedAvatarHoldingDataHash, forKey: "hasUploadedAvatarHoldingDataHash")
                    print(String(data: data, encoding: .utf8)!)
                    print(hasUploadedAvatarHoldingDataHash)
                case .failure(let error):
                    switch error {
                    case .uploadError(let message):
                        if message == "uid existed" || message == "Insert Failed" {
                            hasUploadedAvatarHoldingDataHash.append(data.hashValue)
                            userDefault.set(hasUploadedAvatarHoldingDataHash, forKey: "hasUploadedAvatarHoldingDataHash")
                        }
                    default:
                        break
                    }
                    print("avatarHoldingData ERROR: \(error)")
                    print(String(data: data, encoding: .utf8)!)
                    print(hasUploadedAvatarHoldingDataHash)
                }
            }
        }
    }

    func uploadAbyssData() {
        print("uploadAbyssData START")
        let userDefault = UserDefaults.standard
        var hasUploadedAbyssDataSeason: [Int] = userDefault.array(forKey: "hasUploadedAbyssDataSeason") as? [Int] ?? []
        if let abyssData = AbyssData(account: self, which: .this) {
            if hasUploadedAbyssDataSeason.contains(abyssData.getLocalAbyssSeason()) {
                return
            }
            let encoder = JSONEncoder()
            encoder.outputFormatting = .sortedKeys
            let data = try! encoder.encode(abyssData)
            guard !hasUploadedAbyssDataSeason.contains(data.hashValue) else { return }
            API.PSAServer.uploadUserData(path: "/abyss/upload", data: data) { result in
                switch result {
                case .success(_):
                    print("upload uploadAbyssData succeed")
                    hasUploadedAbyssDataSeason.append(abyssData.getLocalAbyssSeason())
                    userDefault.set(hasUploadedAbyssDataSeason, forKey: "hasUploadedAbyssDataSeason")
                    print(String(data: data, encoding: .utf8)!)
                    print(hasUploadedAbyssDataSeason)
                case .failure(let error):
                    switch error {
                    case .uploadError(let message):
                        if message == "uid existed" || message == ç"Insert Failed" {
                            hasUploadedAbyssDataSeason.append(abyssData.getLocalAbyssSeason())
                            userDefault.set(hasUploadedAbyssDataSeason, forKey: "hasUploadedAbyssDataSeason")
                            print(userDefault.array(forKey: "hasUploadedAbyssDataSeason") as? [Int] ?? [])
                        }
                    default:
                        break
                    }
                    print("uploadAbyssData ERROR: \(error)")
                    print(String(data: data, encoding: .utf8)!)
                    print(hasUploadedAbyssDataSeason)
                }
                userDefault.synchronize()
            }
        }
    }
    #endif
}
