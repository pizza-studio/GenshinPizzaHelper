import Defaults
import DefaultsKeys
import Foundation
import HoYoKit
import UIKit

@available(iOS 13, watchOS 8, *)
public enum MihoyoAPI {
    /// 获取信息
    /// - Parameters:
    ///     - region: 服务器地区
    ///     - serverID: 服务器ID
    ///     - uid: 用户UID
    ///     - cookie: 用户Cookie
    ///     - completion: 数据
    public static func fetchInfos(
        region: Region,
        serverID: String,
        uid: String,
        cookie: String,
        uuid: UUID,
        deviceFingerPrint: String?,
        completion: @escaping (
            FetchResult
        ) -> ()
    ) {
        if (uid == "") || (cookie == "") {
            completion(.failure(.noFetchInfo))
        }

        func get_ds_token(uid: String, server_id: String) -> String {
            let s: String
            switch region {
            case .mainlandChina:
                s = "rtvTthKxEyreVXQCnhluFgLXPOFKPHlA"
            case .global:
                s = "599uqkwc0dlqu3h6epzjzfhgyyrd44ae"
            }
            let t = String(Int(Date().timeIntervalSince1970))
            let r = String(Int.random(in: 100000 ..< 200000))
            let q = "role_id=\(uid)&server=\(server_id)"
            let c = "salt=\(s)&t=\(t)&r=\(r)&b=&q=\(q)".md5
            return t + "," + r + "," + c
        }

        func getSystemVersion() -> String {
            let version = ProcessInfo.processInfo.operatingSystemVersion
            let formattedVersion = String(format: "%d.%d", version.majorVersion, version.minorVersion)
            return formattedVersion
        }

        func getPassChallenge() -> String? {
            guard let url = URL(string: "https://bbs-api.mihoyo.com/misc/api/createVerification?is_high=true") else {
                return nil
            }

            var request = URLRequest(url: url)
            request.allHTTPHeaderFields = [
                "DS": get_ds_token(uid: uid, server_id: serverID),
                "x-rpc-app_version": "2.71.1",
                "User-Agent": "Mozilla/5.0 (iPhone; CPU iPhone OS 13_2_3 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) miHoYoBBS/2.71.1",
                "x-rpc-client_type": "5",
                "Referer": "https://app.mihoyo.com/",
                "Cookie": cookie,
                "x-rpc-device_fp": deviceFingerPrint ?? "",
                "x-rpc-device_name": "iPhone",
                "x-rpc-device_id": uuid.uuidString,
                "x-rpc-sys_version": getSystemVersion(),
                "x-rpc-channel": "miyousheluodi",
                "Host": "bbs-api.mihoyo.com",
            ]

            let session = URLSession.shared
            let semaphore = DispatchSemaphore(value: 0)

            // var responseData: Data?
            var challenge: String?

            func bbsCaptcha(gt: String, challenge: String) -> String? {
                nil
            }

            let task = session.dataTask(with: request) { data, _, error in
                if let error = error {
                    print("Error: \(error)")
                } else if let data = data {
                    do {
                        if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                           let retcode = json["retcode"] as? Int,
                           retcode == 0,
                           let jsonData = json["data"] as? [String: Any],
                           let gt = jsonData["gt"] as? String,
                           let challengeData = jsonData["challenge"] as? String {
                            challenge = bbsCaptcha(gt: gt, challenge: challengeData)
                        }
                    } catch {
                        print("Error decoding JSON: \(error)")
                    }
                }

                semaphore.signal()
            }

            task.resume()
            semaphore.wait()

            if let validate = challenge {
                guard let url = URL(string: "https://bbs-api.mihoyo.com/misc/api/verifyVerification") else {
                    return nil
                }

                var request = URLRequest(url: url)
                request.httpMethod = "POST"
                request.allHTTPHeaderFields = [
                    "DS": get_ds_token(uid: uid, server_id: serverID),
                    "x-rpc-app_version": "2.71.1",
                    "User-Agent": "Mozilla/5.0 (iPhone; CPU iPhone OS 13_2_3 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) miHoYoBBS/2.71.1",
                    "x-rpc-client_type": "5",
                    "Referer": "https://app.mihoyo.com/",
                    "Cookie": cookie,
                    "x-rpc-device_fp": deviceFingerPrint ?? "",
                    "x-rpc-device_name": "iPhone",
                    "x-rpc-device_id": uuid.uuidString,
                    "x-rpc-sys_version": getSystemVersion(),
                    "x-rpc-channel": "miyousheluodi",
                    "Host": "bbs-api.mihoyo.com",
                ]

                let params: [String: Any] = [
                    "geetest_challenge": challenge!,
                    "geetest_seccode": validate + "|jordan",
                    "geetest_validate": validate,
                ]

                do {
                    request.httpBody = try JSONSerialization.data(withJSONObject: params, options: [])
                } catch {
                    print("Error encoding JSON: \(error)")
                    return nil
                }

                let checkSemaphore = DispatchSemaphore(value: 0)

                // var checkResponseData: Data?
                var passChallenge: String?

                let checkTask = session.dataTask(with: request) { data, _, error in
                    if let error = error {
                        print("Error: \(error)")
                    } else if let data = data {
                        do {
                            if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                               let retcode = json["retcode"] as? Int,
                               retcode == 0,
                               let jsonData = json["data"] as? [String: Any],
                               let challengeData = jsonData["challenge"] as? String {
                                passChallenge = challengeData
                            }
                        } catch {
                            print("Error decoding JSON: \(error)")
                        }
                    }

                    checkSemaphore.signal()
                }

                checkTask.resume()
                checkSemaphore.wait()

                return passChallenge
            }

            return nil
        }

        // 请求类别
        let urlStr = "game_record/app/genshin/api/dailyNote"
        // 请求
        HttpMethod<RequestResult>
            .commonRequest(
                .get,
                urlStr,
                region,
                serverID,
                uid,
                cookie,
                uuid,
                deviceFingerPrint
            ) { result in
                switch result {
                case let .success(requestResult):
                    print("request succeed")
                    let fetchData = requestResult.data
                    let retcode = requestResult.retcode
                    let message = requestResult.message

                    switch requestResult.retcode {
                    case 0:
                        print("get data succeed")
                        completion(
                            .success(UserData(fetchData: fetchData!))
                        )
                    case 10001:
                        print("fail 10001")
                        completion(.failure(.cookieInvalid(
                            retcode,
                            message
                        )))
                    case 10103, 10104:
                        print("fail nomatch")
                        completion(.failure(.unmachedAccountCookie(
                            retcode,
                            message
                        )))
                    case 1008:
                        print("fail 1008")
                        completion(.failure(.accountInvalid(
                            retcode,
                            message
                        )))
                    case -1, 10102:
                        print("fail -1")
                        completion(.failure(.dataNotFound(
                            retcode,
                            message
                        )))
                    case 1034:
                        HttpMethod<RequestResult>
                            .commonRequest(
                                .get,
                                urlStr,
                                region,
                                serverID,
                                uid,
                                cookie,
                                UUID(),
                                deviceFingerPrint,
                                useChallenge: getPassChallenge()
                            ) { result in
                                switch result {
                                case let .success(requestResult):
                                    print("request succeed")
                                    let fetchData = requestResult.data
                                    let retcode = requestResult.retcode
                                    let message = requestResult.message

                                    switch requestResult.retcode {
                                    case 0:
                                        print("get data succeed")
                                        completion(
                                            .success(UserData(fetchData: fetchData!))
                                        )
                                    case 10001:
                                        print("fail 10001")
                                        completion(.failure(.cookieInvalid(
                                            retcode,
                                            message
                                        )))
                                    case 10103, 10104:
                                        print("fail nomatch")
                                        completion(.failure(.unmachedAccountCookie(
                                            retcode,
                                            message
                                        )))
                                    case 1008:
                                        print("fail 1008")
                                        completion(.failure(.accountInvalid(
                                            retcode,
                                            message
                                        )))
                                    case -1, 10102:
                                        print("fail -1")
                                        completion(.failure(.dataNotFound(
                                            retcode,
                                            message
                                        )))
                                    case 1034:
                                        completion(.failure(.accountAbnormal(retcode)))
                                    default:
                                        print("unknownerror")
                                        completion(.failure(.unknownError(
                                            retcode,
                                            message
                                        )))
                                    }

                                case let .failure(requestError):

                                    switch requestError {
                                    case let .decodeError(message):
                                        completion(.failure(.decodeError(message)))
                                    default:
                                        completion(.failure(.requestError(requestError)))
                                    }
                                }
                            }
                    default:
                        print("unknownerror")
                        completion(.failure(.unknownError(
                            retcode,
                            message
                        )))
                    }

                case let .failure(requestError):

                    switch requestError {
                    case let .decodeError(message):
                        completion(.failure(.decodeError(message)))
                    default:
                        completion(.failure(.requestError(requestError)))
                    }
                }
            }
    }

    /// 获取信息
    /// - Parameters:
    ///     - region: 服务器地区
    ///     - serverID: 服务器ID
    ///     - uid: 用户UID
    ///     - cookie: 用户Cookie
    ///     - completion: 数据
    public static func getMultiTokenByLoginTicket(
        loginTicket: String,
        loginUid: String,
        completion: @escaping (
            Result<MultiToken, FetchError>
        ) -> ()
    ) {
        // 请求类别
        let urlStr = "auth/api/getMultiTokenByLoginTicket"
        // 请求
        HttpMethod<MultiTokenResult>
            .commonGetToken(
                .get,
                urlStr: urlStr,
                loginTicket: loginTicket,
                loginUid: loginUid
            ) { result in
                switch result {
                case let .success(requestResult):
                    print("request succeed")
                    let userData = requestResult.data
                    let retcode = requestResult.retcode
                    let message = requestResult.message

                    switch requestResult.retcode {
                    case 0:
                        print("get data succeed")
                        completion(.success(userData!))
                    case 10001:
                        print("fail 10001")
                        completion(.failure(.cookieInvalid(
                            retcode,
                            message
                        )))
                    case 10103, 10104:
                        print("fail nomatch")
                        completion(.failure(.unmachedAccountCookie(
                            retcode,
                            message
                        )))
                    case 1008:
                        print("fail 1008")
                        completion(.failure(.accountInvalid(
                            retcode,
                            message
                        )))
                    case -1, 10102:
                        print("fail -1")
                        completion(.failure(.dataNotFound(
                            retcode,
                            message
                        )))
                    case 1034:
                        completion(.failure(.accountAbnormal(retcode)))
                    default:
                        print("unknownerror")
                        completion(.failure(.unknownError(
                            retcode,
                            message
                        )))
                    }

                case let .failure(requestError):

                    switch requestError {
                    case let .decodeError(message):
                        completion(.failure(.decodeError(message)))
                    default:
                        completion(.failure(.requestError(requestError)))
                    }
                }
            }
    }

    /// 获取游戏内账号信息
    /// - Parameters:
    ///     - region: 服务器地区
    ///     - cookie: 用户Cookie
    ///     - completion: 数据
    ///
    /// 只需要Cookie和服务器地区即可返回游戏内的账号信息等。使用时不知为何需要先随便发送一个请求。
    public static func getUserGameRolesByCookie(
        _ cookie: String,
        _ region: Region,
        _ deviceId: UUID,
        completion: @escaping (
            Result<[FetchedAccount], FetchError>
        ) -> ()
    ) {
        let urlStr = "binding/api/getUserGameRolesByCookie"

        guard cookie != ""
        else {
            completion(.failure(.noFetchInfo)); print("no cookie got"); return
        }

        switch region {
        case .mainlandChina:
            // 先随便发送一个请求
            MihoyoAPI.fetchInfos(
                region: region,
                serverID: "cn_gf01",
                uid: "12345678",
                cookie: cookie,
                uuid: deviceId,
                deviceFingerPrint: nil
            ) { _ in
                HttpMethod<RequestAccountListResult>
                    .gameAccountRequest(
                        .get,
                        urlStr,
                        region,
                        cookie,
                        nil
                    ) { result in
                        switch result {
                        case let .failure(requestError):
                            switch requestError {
                            case let .decodeError(message):
                                completion(.failure(.decodeError(message)))
                            default:
                                completion(
                                    .failure(.requestError(requestError))
                                )
                            }
                        case let .success(requestAccountResult):
                            print("request succeed")
                            let accountListData = requestAccountResult.data
                            let retcode = requestAccountResult.retcode
                            let message = requestAccountResult.message

                            switch retcode {
                            case 0:
                                print("get accountListData succeed")
                                if accountListData!.list.isEmpty {
                                    completion(.failure(.accountUnbound))
                                } else {
                                    completion(.success(
                                        accountListData!
                                            .list
                                    ))
                                }
                            case 10001:
                                print("fail 10001")
                                completion(.failure(.cookieInvalid(
                                    retcode,
                                    message
                                )))
                            case -100:
                                print("fail -100")
                                completion(.failure(.notLoginError(
                                    retcode,
                                    message
                                )))
                            case 1034:
                                completion(
                                    .failure(.accountAbnormal(retcode))
                                )
                            default:
                                print("unknownerror")
                                completion(.failure(.unknownError(
                                    retcode,
                                    message
                                )))
                            }
                        }
                    }
            }
        case .global:
            var accounts: [FetchedAccount] = []
            let group = DispatchGroup()
            let globalServers: [Server] = [.asia, .europe, .unitedStates, .hongKongMacauTaiwan]
            globalServers.forEach { server in
                group.enter()
                // 先随便发送一个请求
                MihoyoAPI.fetchInfos(
                    region: region,
                    serverID: server.id,
                    uid: "12345678",
                    cookie: cookie,
                    uuid: deviceId,
                    deviceFingerPrint: nil
                ) { _ in
                    HttpMethod<RequestAccountListResult>
                        .gameAccountRequest(
                            .get,
                            urlStr,
                            region,
                            cookie,
                            server.id
                        ) { result in
                            group.enter()
                            switch result {
                            case let .failure(requestError):
                                completion(
                                    .failure(.requestError(requestError))
                                )
                            case let .success(requestAccountResult):
                                print("request succeed")
                                let accountListData = requestAccountResult
                                    .data
                                let retcode = requestAccountResult.retcode
                                let message = requestAccountResult.message

                                switch retcode {
                                case 0:
                                    accounts
                                        .append(
                                            contentsOf: accountListData!
                                                .list
                                        )
                                    group.leave()
                                case 10001:
                                    print("fail 10001")
                                    completion(
                                        .failure(.cookieInvalid(
                                            retcode,
                                            message
                                        ))
                                    )
                                case -100:
                                    print("fail -100")
                                    completion(
                                        .failure(.notLoginError(
                                            retcode,
                                            message
                                        ))
                                    )
                                case 1034:
                                    completion(
                                        .failure(.accountAbnormal(retcode))
                                    )
                                default:
                                    print("unknownerror")
                                    completion(
                                        .failure(.unknownError(
                                            retcode,
                                            message
                                        ))
                                    )
                                }
                            }
                            group.leave()
                        }
                }
            }
            group.notify(queue: DispatchQueue.main) {
                if accounts
                    .isEmpty { completion(.failure(.accountUnbound)) } else { completion(.success(accounts)) }
            }
        }
    }
}
