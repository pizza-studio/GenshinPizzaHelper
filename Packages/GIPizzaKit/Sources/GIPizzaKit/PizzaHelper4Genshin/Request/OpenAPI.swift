// (c) 2022 and onwards Pizza Studio (GPL v3.0 License).
// ====================
// This code is released under the GPL v3.0 License (SPDX-License-Identifier: GPL-3.0)

import Foundation
import HBMihoyoAPI
import HoYoKit

extension API {
    public enum OpenAPIs {
        // MARK: Public

        /// 获取当前活动信息
        /// - Parameters:
        ///     - completion: 数据
        public static func fetchCurrentEvents(
            completion: @escaping (
                CurrentEventsFetchResult
            ) -> ()
        ) {
            // 请求类别
            let urlStr = "https://gi.yatta.moe/assets/data/event.json"
            let url = URL(string: urlStr)!

            // 请求
            HttpMethod<CurrentEvent>
                .openRequest(
                    .get,
                    url,
                    cachedPolicy: .reloadIgnoringLocalCacheData
                ) { result in
                    switch result {
                    case let .success(requestResult):
                        print("request succeed")
                        completion(.success(requestResult))

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

        /// 获取游戏内玩家详细信息
        /// - Parameters:
        ///     - uid: 用户UID
        ///     - completion: 数据
        public static func fetchQueriableEnkaProfile(
            _ uid: String,
            dateWhenNextRefreshable: Date?
        ) async throws
            -> EnkaGI.QueryRelated.ProfileRAW {
            if let date = dateWhenNextRefreshable, date > Date() {
                print(
                    "PLAYER DETAIL FETCH 刷新太快了，请在\(date.timeIntervalSinceReferenceDate - Date().timeIntervalSinceReferenceDate)秒后刷新"
                )
                throw EnkaGI.QueryRelated.Exception.refreshTooFast(dateWhenRefreshable: date)
            } else {
                let isMiyousheUID = Self.isMiyousheUID(uid: uid)
                let enkaMirror = "https://profile.microgg.cn/api/uid/" + uid
                let enkaOfficial = "https://enka.network/api/uid/" + uid
                let urlStr = isMiyousheUID ? enkaMirror : enkaOfficial
                let url = URL(string: urlStr)!

                if isMiyousheUID {
                    do {
                        let (data, _) = try await URLSession.shared.data(for: URLRequest(url: url))
                        let requestResult = try JSONDecoder().decode(
                            EnkaGI.QueryRelated.ProfileRAW.self,
                            from: data
                        )
                        return requestResult
                    } catch {
                        let (data, _) = try await URLSession.shared
                            .data(for: URLRequest(url: URL(string: enkaOfficial)!))
                        let requestResult = try JSONDecoder().decode(
                            EnkaGI.QueryRelated.ProfileRAW.self,
                            from: data
                        )
                        return requestResult
                    }
                } else {
                    let (data, _) = try await URLSession.shared.data(for: URLRequest(url: url))
                    let requestResult = try JSONDecoder().decode(
                        EnkaGI.QueryRelated.ProfileRAW.self,
                        from: data
                    )
                    return requestResult
                }
            }
        }

        /// 获取游戏内玩家详细信息
        /// - Parameters:
        ///     - uid: 用户UID
        ///     - completion: 数据
        public static func fetchQueriableEnkaProfile(
            _ uid: String,
            dateWhenNextRefreshable: Date?,
            completion: @escaping (
                Result<EnkaGI.QueryRelated.ProfileRAW, EnkaGI.QueryRelated.Exception>
            ) -> ()
        ) {
            if let date = dateWhenNextRefreshable, date > Date() {
                completion(.failure(.refreshTooFast(dateWhenRefreshable: date)))
                print(
                    "PLAYER DETAIL FETCH 刷新太快了，请在\(date.timeIntervalSinceReferenceDate - Date().timeIntervalSinceReferenceDate)秒后刷新"
                )
            } else {
                fetchPlayerDatas(uid) { result in
                    switch result {
                    case let .success(model):
                        completion(.success(model))
                    case let .failure(error):
                        switch error {
                        case let .dataTaskError(message):
                            completion(
                                .failure(
                                    .failToGetCharacterData(message: message)
                                )
                            )
                        case let .decodeError(message):
                            completion(
                                .failure(
                                    .failToGetCharacterData(message: message)
                                )
                            )
                        case let .errorWithCode(code):
                            completion(
                                .failure(
                                    .failToGetCharacterData(
                                        message: "ERROR CODE \(code)"
                                    )
                                )
                            )
                        case .noResponseData:
                            completion(
                                .failure(
                                    .failToGetCharacterData(message: "未找到数据")
                                )
                            )
                        case .responseError:
                            completion(
                                .failure(
                                    .failToGetCharacterData(message: "请求error.noResponse")
                                )
                            )
                        }
                    }
                }
            }
        }

        /// 获取原神辞典数据
        /// - Parameters:
        ///     - completion: 数据
        public static func fetchGenshinDictionaryData(
            completion: @escaping (
                [GDDictionary]
            ) -> ()
        ) {
            // 请求类别
            let urlStr = "https://dataset.genshin-dictionary.com/words.json"
            let url = URL(string: urlStr)!

            // 请求
            HttpMethod<[GDDictionary]>
                .openRequest(
                    .get,
                    url
                ) { result in
                    switch result {
                    case let .success(requestResult):
                        print("request succeed")
                        completion(requestResult)

                    case .failure:
                        print("request Genshin Dictionary Data Fail")
                    }
                }
        }

        // MARK: Private

        /// 获取游戏内玩家详细信息
        /// - Parameters:
        ///     - uid: 用户UID
        ///     - completion: 数据
        private static func fetchPlayerDatas(
            _ uid: String,
            completion: @escaping (
                EnkaGI.QueryRelated.FetchResult
            ) -> ()
        ) {
            let isMiyousheUID = Self.isMiyousheUID(uid: uid)
            let enkaMirror = "https://profile.microgg.cn/api/uid/" + uid
            let enkaOfficial = "https://enka.network/api/uid/" + uid
            let urlStr = isMiyousheUID ? enkaMirror : enkaOfficial
            let url = URL(string: urlStr)!

            // 请求
            HttpMethod<EnkaGI.QueryRelated.ProfileRAW>
                .openRequest(
                    .get,
                    url
                ) { result in
                    switch result {
                    case let .success(requestResult):
                        print("request succeed")
                        completion(.success(requestResult))
                    case let .failure(requestError):
                        if !isMiyousheUID {
                            completion(.failure(requestError))
                        } else {
                            // microgg 的 enka 服务使用出错的时候，会尝试从 enka 官网存取国服 uid 的资料。
                            HttpMethod<EnkaGI.QueryRelated.ProfileRAW>
                                .openRequest(
                                    .get,
                                    URL(string: enkaOfficial)!
                                ) { result in
                                    switch result {
                                    case let .success(requestResult):
                                        print("request succeed")
                                        completion(.success(requestResult))
                                    case let .failure(requestError):
                                        completion(.failure(requestError))
                                    }
                                }
                        }
                    }
                }
        }

        private static func isMiyousheUID(uid: String) -> Bool {
            [.china, .bilibili].contains(Server(uid: uid))
        }
    }
}
