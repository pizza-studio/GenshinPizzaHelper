//
//  Account.swift
//  GenshinPizzaHepler
//
//  Created by 戴藏龙 on 2022/8/9.
//  Account所需的所有信息

import Defaults
import Foundation
import GIPizzaKit
import HoYoKit
import UIKit

// MARK: - Account

// MARK: - Account

// struct Account: Equatable, Hashable {
//    // MARK: Lifecycle
//
//    init(config: AccountConfiguration) {
//        self.config = config
//    }
//
//    // MARK: Internal
//
//    var config: AccountConfiguration
//
//    // 树脂等信息
//    var result: FetchResult?
//    var background: WidgetBackground = .randomNamecardBackground
//    var basicInfo: BasicInfos?
//    var fetchComplete: Bool = false
//
//    #if !os(watchOS)
//    var playerDetailResult: Result<
//        PlayerDetail,
//        PlayerDetail.PlayerDetailError
//    >?
//    var fetchPlayerDetailComplete: Bool = false
//
//    // 深境螺旋
//    var spiralAbyssDetail: AccountSpiralAbyssDetail?
//    // 账簿，旅行札记
//    var ledgeDataResult: LedgerDataFetchResult?
//    #endif
//
//    static func == (lhs: Account, rhs: Account) -> Bool {
//        lhs.config == rhs.config
//    }
//
//    func hash(into hasher: inout Hasher) {
//        hasher.combine(config)
//    }
// }
//
// extension AccountConfiguration {
//    func fetchResult(_ completion: @escaping (FetchResult) -> ()) {
//        guard (uid != nil) || (cookie != nil)
//        else { completion(.failure(.noFetchInfo)); return }
//
//        #if !os(watchOS)
//        let uuid = UIDevice.current.identifierForVendor ?? UUID()
//        #else
//        let uuid = UUID()
//        #endif
//
//        MihoyoAPI.fetchInfos(
//            region: server.region,
//            serverID: server.id,
//            uid: uid!,
//            cookie: cookie!,
//            uuid: uuid,
//            deviceFingerPrint: deviceFingerPrint
//        ) { result in
//            completion(result)
//            #if !os(watchOS)
//            switch result {
//            case let .success(data):
//                UserNotificationCenter.shared.createAllNotification(
//                    for: self.name!,
//                    with: data,
//                    uid: self.uid!
//                )
//            // TODO: activity kit refactor
////                #if canImport(ActivityKit)
////                if #available(iOS 16.1, *) {
////                    ResinRecoveryActivityController.shared
////                        .updateResinRecoveryTimerActivity(
////                            for: self,
////                            using: result
////                        )
////                }
////                #endif
//            case .failure:
//                break
//            }
//            #endif
//        }
//    }
//
//    func fetchSimplifiedResult(
//        _ completion: @escaping (SimplifiedUserDataResult)
//            -> ()
//    ) {
//        guard let cookie = cookie
//        else { completion(.failure(.noFetchInfo)); return }
//        guard cookie.contains("stoken")
//        else { completion(.failure(.noStoken)); return }
//
//        #if !os(watchOS)
//        let uuid = UIDevice.current.identifierForVendor ?? UUID()
//        #else
//        let uuid = UUID()
//        #endif
//
//        MihoyoAPI.fetchSimplifiedInfos(cookie: cookie, deviceId: uuid) { result in
//            completion(result)
//            #if !os(watchOS)
//            switch result {
//            case let .success(data):
//                UserNotificationCenter.shared.createAllNotification(
//                    for: self.name!,
//                    with: data,
//                    uid: self.uid!
//                )
//            case .failure:
//                break
//            }
//            #endif
//        }
//    }
//
//    func fetchBasicInfo(_ completion: @escaping (BasicInfos) -> ()) {
//        #if !os(watchOS)
//        let uuid = UIDevice.current.identifierForVendor ?? UUID()
//        #else
//        let uuid = UUID()
//        #endif
//
//        MihoyoAPI.fetchBasicInfos(
//            region: server.region,
//            serverID: server.id,
//            uid: uid ?? "",
//            cookie: cookie ?? "",
//            deviceFingerPrint: deviceFingerPrint ?? "",
//            deviceId: uuid
//        ) { result in
//            switch result {
//            case let .success(data):
//                completion(data)
//            case .failure:
//                print("fetching basic info error")
//            }
//        }
//    }
//
//    #if !os(watchOS)
//    func fetchPlayerDetail(
//        dateWhenNextRefreshable: Date?,
//        _ completion: @escaping (Result<
//            Enka.PlayerDetailFetchModel,
//            PlayerDetail.PlayerDetailError
//        >) -> ()
//    ) {
//        guard let uid = uid else { return }
//        API.OpenAPIs.fetchPlayerDetail(
//            uid,
//            dateWhenNextRefreshable: dateWhenNextRefreshable
//        ) { result in
//            completion(result)
//        }
//    }
//
//    func fetchAbyssInfo(
//        round: AbyssRound,
//        _ completion: @escaping (SpiralAbyssDetail) -> ()
//    ) {
//        // thisAbyssData
//
//        #if !os(watchOS)
//        let uuid = UIDevice.current.identifierForVendor ?? UUID()
//        #else
//        let uuid = UUID()
//        #endif
//
//        MihoyoAPI.fetchSpiralAbyssInfos(
//            region: server.region,
//            serverID: server.id,
//            uid: uid!,
//            cookie: cookie!,
//            deviceFingerPrint: deviceFingerPrint ?? "",
//            deviceId: uuid,
//            scheduleType: round.rawValue
//        ) { result in
//            switch result {
//            case let .success(resultData):
//                completion(resultData)
//            case .failure:
//                print("Fail")
//            }
//        }
//    }
//
//    func fetchAbyssInfo(
//        _ completion: @escaping (AccountSpiralAbyssDetail)
//            -> ()
//    ) {
//        var this: SpiralAbyssDetail?
//        var last: SpiralAbyssDetail?
//        let group = DispatchGroup()
//        group.enter()
//        fetchAbyssInfo(round: .this) { data in
//            this = data
//            group.leave()
//        }
//        group.enter()
//        fetchAbyssInfo(round: .last) { data in
//            last = data
//            group.leave()
//        }
//        group.notify(queue: .main) {
//            guard let this = this, let last = last else { return }
//            completion(AccountSpiralAbyssDetail(this: this, last: last))
//        }
//    }
//
//    func fetchLedgerData(
//        _ completion: @escaping (LedgerDataFetchResult)
//            -> ()
//    ) {
//        #if !os(watchOS)
//        let uuid = UIDevice.current.identifierForVendor ?? UUID()
//        #else
//        let uuid = UUID()
//        #endif
//
//        MihoyoAPI.fetchLedgerInfos(
//            month: 0,
//            uid: uid!,
//            serverID: server.id,
//            region: server.region,
//            cookie: cookie!,
//            deviceFingerPrint: deviceFingerPrint ?? "",
//            deviceId: uuid
//        ) { result in
//            completion(result)
//        }
//    }
//
//    enum AbyssRound: String {
//        case this = "1", last = "2"
//    }
//    #endif
// }

// extension Account {
//    #if !os(watchOS)
//    func uploadHoldingData() {
//        print("uploadHoldingData START")
//        guard Defaults[.allowAbyssDataCollection]
//        else { print("not allowed"); return }
//        if let avatarHoldingData = AvatarHoldingData(
//            account: self,
//            which: .this
//        ) {
//            let encoder = JSONEncoder()
//            encoder.outputFormatting = .sortedKeys
//            let data = try! encoder.encode(avatarHoldingData)
//            let md5 = String(data: data, encoding: .utf8)!.md5
//            guard !Defaults[.hasUploadedAvatarHoldingDataMD5].contains(md5) else {
//                print(
//                    "uploadHoldingData ERROR: This holding data has uploaded. "
//                ); return
//            }
//            guard !UPLOAD_HOLDING_DATA_LOCKED
//            else { print("uploadHoldingDataLocked is locked"); return }
//            lock()
//            API.PSAServer.uploadUserData(
//                path: "/user_holding/upload",
//                data: data
//            ) { result in
//                switch result {
//                case .success:
//                    print("uploadHoldingData SUCCEED")
//                    saveMD5()
//                    print(md5)
//                    print(Defaults[.hasUploadedAvatarHoldingDataMD5])
//                case let .failure(error):
//                    switch error {
//                    case let .uploadError(message):
//                        if message == "uid existed" || message ==
//                            "Insert Failed" {
//                            saveMD5()
//                        }
//                    default:
//                        break
//                    }
//                }
//                unlock()
//            }
//            func saveMD5() {
//                Defaults[.hasUploadedAvatarHoldingDataMD5].append(md5)
//                UserDefaults.opSuite.synchronize()
//            }
//
//        } else {
//            print(
//                "uploadAbyssData ERROR: generate data fail. Maybe because not full star."
//            )
//        }
//        func unlock() {
//            UPLOAD_HOLDING_DATA_LOCKED = false
//        }
//        func lock() {
//            UPLOAD_HOLDING_DATA_LOCKED = true
//        }
//    }
//
//    func uploadAbyssData() {
//        print("uploadAbyssData START")
//        guard Defaults[.allowAbyssDataCollection]
//        else { print("not allowed"); return }
//        if let abyssData = AbyssData(account: self, which: .this) {
//            print(
//                "MD5 calculated by \(abyssData.uid)\(abyssData.getLocalAbyssSeason())"
//            )
//            let md5 = "\(abyssData.uid)\(abyssData.getLocalAbyssSeason())"
//                .md5
//            guard !Defaults[.hasUploadedAbyssDataAccountAndSeasonMD5].contains(md5)
//            else {
//                print(
//                    "uploadAbyssData ERROR: This abyss data has uploaded.  "
//                ); return
//            }
//            let encoder = JSONEncoder()
//            encoder.outputFormatting = .sortedKeys
//            let data = try! encoder.encode(abyssData)
//            print(String(data: data, encoding: .utf8)!)
//            guard !UPLOAD_ABYSS_DATA_LOCKED
//            else { print("uploadAbyssDataLocked is locked"); return }
//            lock()
//            API.PSAServer
//                .uploadUserData(
//                    path: "/abyss/upload",
//                    data: data
//                ) { result in
//                    switch result {
//                    case .success:
//                        print("uploadAbyssData SUCCEED")
//                        saveMD5()
//                    case let .failure(error):
//                        switch error {
//                        case let .uploadError(message):
//                            if message == "uid existed" {
//                                saveMD5()
//                            }
//                        default:
//                            break
//                        }
//                        print("uploadAbyssData ERROR: \(error)")
//                        print(md5)
//                        print(Defaults[.hasUploadedAbyssDataAccountAndSeasonMD5])
//                    }
//                    unlock()
//                }
//            func saveMD5() {
//                Defaults[.hasUploadedAbyssDataAccountAndSeasonMD5].append(md5)
//                print(
//                    "uploadAbyssData MD5: \(Defaults[.hasUploadedAbyssDataAccountAndSeasonMD5])"
//                )
//                UserDefaults.opSuite.synchronize()
//            }
//        } else {
//            print(
//                "uploadAbyssData ERROR: generate data fail. Maybe because not full star."
//            )
//        }
//        func unlock() {
//            UPLOAD_ABYSS_DATA_LOCKED = false
//        }
//        func lock() {
//            UPLOAD_ABYSS_DATA_LOCKED = true
//        }
//    }
//
//    func uploadHuTaoDBAbyssData() async {
//        print("uploadHuTaoDBAbyssData START")
//        guard Defaults[.allowAbyssDataCollection]
//        else { print("not allowed"); return }
//        if let abyssData = await HuTaoDBAbyssData(account: self, which: .this) {
//            let encoder = JSONEncoder()
//            encoder.outputFormatting = .sortedKeys
//            let data = try! encoder.encode(abyssData)
//            print(String(data: data, encoding: .utf8)!)
//            API.PSAServer
//                .uploadHuTaoDBUserData(
//                    path: "/Record/Upload",
//                    data: data
//                ) { result in
//                    switch result {
//                    case .success:
//                        print("uploadHuTaoDBAbyssData SUCCEED")
//                    case let .failure(error):
//                        print("uploadHuTaoDBAbyssData ERROR: \(error)")
//                    }
//                }
//        } else {
//            print(
//                "uploadHuTaoDBAbyssData ERROR: generate data fail. Maybe because not full star."
//            )
//        }
//    }
//    #endif
// }
