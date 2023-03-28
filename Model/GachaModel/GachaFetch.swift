//
//  GachaFetch.swift
//  GenshinPizzaHepler
//
//  Created by 戴藏龙 on 2023/3/27.
//

import CoreData
import Foundation
import HBMihoyoAPI

@available(iOS 13, *)
extension MihoyoAPI {
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
            case .success(let data):
                if let authKey = data.data {

                    innerGetGachaLogAndSave(
                        account: account,
                        authkey: authKey,
                        manager: manager,
                        observer: observer) { result in
                            completion(result)
                        }
                } else {
                    completion(.failure(.genAuthKeyError(message: data.message)))
                }
            case .failure(let err):
                completion(.failure(.genAuthKeyError(message: err.localizedDescription)))
            }
        }
    }

    private static func innerGetGachaLogAndSave(
        account: AccountConfiguration,
        authkey: GenAuthKeyResult.GenAuthKeyData,
        gachaType: _GachaType = .standard,
        page: Int = 1,
        endId: String = "0",
        manager: GachaModelManager,
        observer: GachaFetchProgressObserver,
        completion: @escaping (
            (Result<Void, GetGachaError>) -> ()
        )
    ) {
        observer.fetching(page: page, gachaType: gachaType)
        let url = genGachaURL(account: account, authkey: authkey, gachaType: gachaType, page: page, endId: endId)

        let request = URLRequest(url: url)

        URLSession.shared.dataTask(with: request) { data, respond, error in
            print(error ?? "ErrorInfo nil")
            guard error == nil else { completion(.failure(.networkError(message: error?.localizedDescription ?? "Unknow Network Error"))); return }
//            print(respond!)
            print(String(data: data!, encoding: .utf8)!)
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            do {
                let result = try decoder.decode(GachaResult_FM.self, from: data!)
                let items = try result.toGachaItemArray()
                observer.got(items)
                manager.addRecordItems(items) { itemIsNewAndSavedSucceed in
                    if itemIsNewAndSavedSucceed {
                        observer.saveNewItemSucceed()
                    }
                }
                if !items.isEmpty {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        innerGetGachaLogAndSave(account: account, authkey: authkey, gachaType: gachaType, page: page+1, endId: items.last!.id, manager: manager, observer: observer) { result in
                            completion(result)
                        }
                    }
                } else if let gachaType = gachaType.next() {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        innerGetGachaLogAndSave(account: account, authkey: authkey, gachaType: gachaType, manager: manager, observer: observer) { result in
                            completion(result)
                        }
                    }
                } else {
                    completion(.success(()))
                }
            } catch is GetGachaError {
                completion(.failure(error as! GetGachaError))
            } catch {
                print(error.localizedDescription)
                completion(.failure(.decodeError))
            }
        }.resume()
    }
}
