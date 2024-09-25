//
//  GachaKe.swift
//  GenshinPizzaHepler
//
//  Created by 戴藏龙 on 2023/3/28.
//

import CommonCrypto
import CryptoKit
import Foundation
import HBMihoyoAPI
import UIKit

@available(iOS 13, *)
extension MihoyoAPI {
    public static func genAuthKey(
        account: Account,
        completion: @escaping (
            (Result<GenAuthKeyResult, GetGachaError>) -> ()
        )
    ) {
        let gameBiz: String
        switch account.server.region {
        case .mainlandChina: gameBiz = "hk4e_cn"
        case .global: gameBiz = "hk4e_global"
        }
        let genAuthKeyParam = GenAuthKeyParam(
            gameUid: account.uid!,
            region: account.server.id,
            gameBiz: gameBiz
        )

        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        let requestBody = try! encoder.encode(genAuthKeyParam)

        var urlComponents = URLComponents()
        urlComponents.scheme = "https"
        urlComponents.host = "api-takumi.mihoyo.com"
//        switch account.server.region {
//        case .cn: urlComponents.host = "api-takumi.mihoyo.com"
//        case .global: urlComponents.host = "???"
//        }
        urlComponents.path = "/binding/api/genAuthKey"

        let url = urlComponents.url!

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = requestBody

        print(request)

        request.allHTTPHeaderFields = [
            "Content-Type": "application/json; charset=utf-8",
            "Host": "api-takumi.mihoyo.com",
            "Accept": "application/json, text/plain, */*",
            "Referer": "https://webstatic.mihoyo.com",
            "x-rpc-app_version": "2.71.1",
            "x-rpc-client_type": "5",
            "x-rpc-device_id": (UIDevice.current.identifierForVendor ?? UUID()).uuidString,
            "x-requested-with": "com.mihoyo.hyperion",
            "Cookie": account.cookie!,
            "DS": get_ds_token(),
        ]

        print(request.allHTTPHeaderFields!)
        print(String(data: requestBody, encoding: .utf8)!)
        URLSession.shared.dataTask(with: request) { data, _, error in
            print(error ?? "ErrorInfo nil")
            guard error == nil
            else {
                completion(.failure(.genAuthKeyError(
                    message: error!
                        .localizedDescription
                ))); return
            }
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            do {
                let result = try decoder.decode(
                    GenAuthKeyResult.self,
                    from: data!
                )
                completion(.success(result))
            } catch {
                completion(.failure(.genAuthKeyError(
                    message: error
                        .localizedDescription
                )))
            }
        }.resume()
        func get_ds_token() -> String {
            let s: String
            switch account.server.region {
            case .mainlandChina:
                s = "EJncUPGnOHajenjLhBOsdpwEMZmiCmQX"
            case .global:
                s = "rk4xg2hakoi26nljpr099fv9fck1ah10"
                // TODO: Manually wanted crash.
                assert(false, "CanglongCI wants a crash here.")
            }
            let t = String(Int(Date().timeIntervalSince1970))
            let lettersAndNumbers = "abcdefghijklmnopqrstuvwxyz1234567890"
            let r = String((0 ..< 6).map { _ in
                lettersAndNumbers.randomElement()!
            })
            let c = "salt=\(s)&t=\(t)&r=\(r)".md5
            print(t + "," + r + "," + c)
            print("salt=\(s)&t=\(t)&r=\(r)")
            return t + "," + r + "," + c
        }
    }
}

// MARK: - GetCookieTokenResult

private struct GetCookieTokenResult: Codable {
    struct GetCookieTokenData: Codable {
        let uid: String
        let cookieToken: String
    }

    let retcode: Int
    let message: String
    let data: GetCookieTokenData?
}

// MARK: - GenAuthKeyParam

private struct GenAuthKeyParam: Encodable {
    let authAppid: String = "webview_gacha"
    let gameUid: String
    let region: String
    let gameBiz: String
}

// MARK: - GenAuthKeyResult

public struct GenAuthKeyResult: Codable {
    // MARK: Public

    public struct GenAuthKeyData: Codable {
        let authkeyVer: Int
        let signType: Int
        let authkey: String
    }

    // MARK: Internal

    let retcode: Int
    let message: String
    let data: GenAuthKeyData?
}
