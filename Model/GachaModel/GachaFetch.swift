//
//  GachaFetch.swift
//  GenshinPizzaHepler
//
//  Created by 戴藏龙 on 2023/3/27.
//

import Foundation
import HBMihoyoAPI
import CoreData

@available(iOS 13, *)
public extension MihoyoAPI {
    static func getGachaLogAndSave(
        account: AccountConfiguration,
        manager: GachaModelManager,
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
                        manager: manager) { result in
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
        gachaType: GachaType = .character,
        page: Int = 1,
        endId: String = "0",
        manager: GachaModelManager,
        completion: @escaping (
            (Result<Void, GetGachaError>) -> ()
        )
    ) {
        let url = genGachaURL(account: account, authkey: authkey, gachaType: .character, page: page, endId: endId)

        let request = URLRequest(url: url)

        URLSession.shared.dataTask(with: request) { data, respond, error in
            print(error ?? "ErrorInfo nil")
            guard error == nil else { completion(.failure(.networkError(message: error?.localizedDescription ?? "Unknow Network Error"))); return }
            print(respond!)
            print(String(data: data!, encoding: .utf8)!)
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            do {
                let result = try decoder.decode(GachaResult_FM.self, from: data!)
                let items = try result.toGachaItemArray()
                manager.addRecordItems(items)
                if !items.isEmpty {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        innerGetGachaLogAndSave(account: account, authkey: authkey, gachaType: gachaType, page: page+1, endId: items.last!.id, manager: manager) { result in
                            completion(result)
                        }
                    }
                } else if let gachaType = gachaType.next() {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        innerGetGachaLogAndSave(account: account, authkey: authkey, gachaType: gachaType, manager: manager) { result in
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
