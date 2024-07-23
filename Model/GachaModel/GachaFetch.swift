//
//  GachaFetch.swift
//  GenshinPizzaHepler
//
//  Created by 戴藏龙 on 2023/3/27.
//

import CoreData
import Foundation
import GIPizzaKit
import HBMihoyoAPI
import HoYoKit

// MARK: - GenGachaURLError

public enum GenGachaURLError: Error {
    case genURLError(message: String)
}

@available(iOS 13, *)
extension MihoyoAPI {
    static let GET_GACHA_DELAY_RANDOM_RANGE: Range<Double> = 0.8 ..< 1.5

    public static func getGachaLogAndSave(
        server: Server,
        authKey: GenAuthKeyResult.GenAuthKeyData,
        manager: GachaModelManager,
        observer: GachaFetchProgressObserver,
        completion: @escaping (
            (Result<(), GetGachaError>) -> ()
        )
    ) {
        innerGetGachaLogAndSave(
            server: server,
            authkey: authKey,
            manager: manager,
            observer: observer
        ) { result in
            completion(result)
        }
    }

    public static func getGachaLogAndSave(
        account: AccountConfiguration,
        manager: GachaModelManager,
        observer: GachaFetchProgressObserver,
        completion: @escaping (
            (Result<(), GetGachaError>) -> ()
        )
    ) {
        genAuthKey(account: account) { result in
            switch result {
            case let .success(data):
                if let authKey = data.data {
                    innerGetGachaLogAndSave(
                        server: account.server,
                        authkey: authKey,
                        manager: manager,
                        observer: observer
                    ) { result in
                        completion(result)
                    }
                } else {
                    completion(.failure(.genAuthKeyError(
                        message: data
                            .message
                    )))
                }
            case let .failure(err):
                completion(.failure(.genAuthKeyError(
                    message: err
                        .localizedDescription
                )))
            }
        }
    }

    private static func innerGetGachaLogAndSave(
        server: Server,
        authkey: GenAuthKeyResult.GenAuthKeyData,
        gachaType: MihoyoGachaType = .standard,
        page: Int = 1,
        endId: String = "0",
        manager: GachaModelManager,
        observer: GachaFetchProgressObserver,
        completion: @escaping (
            (Result<(), GetGachaError>) -> ()
        )
    ) {
        observer.fetching(page: page, gachaType: gachaType)
        let url = genGachaURL(
            server: server,
            authkey: authkey,
            gachaType: gachaType,
            page: page,
            endId: endId
        )

        let request = URLRequest(url: url)

        func handleRetrievedData(data: Data?, error: (any Error)?) {
            print(error ?? "ErrorInfo nil")
            guard error == nil else {
                completion(.failure(.networkError(
                    message: error?
                        .localizedDescription ?? "Unknow Network Error"
                ))); return
            }
//            print(respond!)
            print(String(data: data!, encoding: .utf8)!)
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            let dateFormatter = DateFormatter.Gregorian()
            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            dateFormatter.locale = Locale(identifier: "en_US_POSIX")
            decoder.dateDecodingStrategy = .formatted(dateFormatter)
            let randomTime = TimeInterval.random(in: GET_GACHA_DELAY_RANDOM_RANGE)
            let deadline: DispatchTime = .now() + randomTime
            do {
                let result = try decoder.decode(
                    GachaResultFetched.self,
                    from: data!
                )
                let items = try result.toGachaItemArray()

                /// Check whether GachaItemDB is expired.
                if GachaMetaDBExposed.shared.mainDB.checkIfExpired(against: Set<String>(items.map(\.itemId))) {
                    defer {
                        Task.detached { @MainActor in
                            try? await GachaMetaDBExposed.Sputnik.updateLocalGachaMetaDB()
                        }
                    }
                    throw GachaMetaDBExposed.GMDBError.databaseExpired
                }

                Task.detached { @MainActor in
                    observer.got(items)
                }
                manager.addRecordItems(items) { itemIsNewAndSavedSucceed in
                    if itemIsNewAndSavedSucceed {
                        Task.detached { @MainActor in
                            observer.saveNewItemSucceed()
                        }
                    }
                }
                if observer.shouldCancel {
                    completion(.success(()))
                } else if !items.isEmpty {
                    DispatchQueue.global(qos: .userInteractive).asyncAfter(deadline: deadline) {
                        innerGetGachaLogAndSave(
                            server: server,
                            authkey: authkey,
                            gachaType: gachaType,
                            page: page + 1,
                            endId: items.last!.id,
                            manager: manager,
                            observer: observer
                        ) { result in
                            completion(result)
                        }
                    }
                } else if let gachaType = gachaType.next() {
                    DispatchQueue.global(qos: .userInteractive).asyncAfter(deadline: deadline) {
                        innerGetGachaLogAndSave(
                            server: server,
                            authkey: authkey,
                            gachaType: gachaType,
                            manager: manager,
                            observer: observer
                        ) { result in
                            completion(result)
                        }
                    }
                } else {
                    completion(.success(()))
                }
            } catch let error as GetGachaError {
                completion(.failure(error))
            } catch {
                checkDBExpiry: switch error {
                case GachaMetaDBExposed.GMDBError.databaseExpired:
                    Task.detached { @MainActor in
                        try? await GachaMetaDBExposed.Sputnik.updateLocalGachaMetaDB()
                    }
                default: break checkDBExpiry
                }
                print(error.localizedDescription)
                completion(
                    .failure(
                        .decodeError(
                            message: "DECODE ITEM: \(String(data: data!, encoding: .utf8)!)"
                        )
                    )
                )
            }
        }

        URLSession.shared.dataTask(with: request) { data, _, error in
            handleRetrievedData(data: data, error: error)
        }.resume()
    }
}
