//
//  OpenAPI.swift
//  GenshinPizzaHelper
//
//  Created by Bill Haku on 2022/9/17.
//

import Foundation
import HBMihoyoAPI

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
            let urlStr = "https://api.ambr.top/assets/data/event.json"
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
        public static func fetchPlayerDetail(
            _ uid: String,
            dateWhenNextRefreshable: Date?
        ) async throws
            -> Enka.PlayerDetailFetchModel {
            if let date = dateWhenNextRefreshable, date > Date() {
                print(
                    "PLAYER DETAIL FETCH 刷新太快了，请在\(date.timeIntervalSinceReferenceDate - Date().timeIntervalSinceReferenceDate)秒后刷新"
                )
                throw PlayerDetail.PlayerDetailError.refreshTooFast(dateWhenRefreshable: date)
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
                            Enka.PlayerDetailFetchModel.self,
                            from: data
                        )
                        return requestResult
                    } catch {
                        let (data, _) = try await URLSession.shared
                            .data(for: URLRequest(url: URL(string: enkaOfficial)!))
                        let requestResult = try JSONDecoder().decode(
                            Enka.PlayerDetailFetchModel.self,
                            from: data
                        )
                        return requestResult
                    }
                } else {
                    let (data, _) = try await URLSession.shared.data(for: URLRequest(url: url))
                    let requestResult = try JSONDecoder().decode(
                        Enka.PlayerDetailFetchModel.self,
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
        public static func fetchPlayerDetail(
            _ uid: String,
            dateWhenNextRefreshable: Date?,
            completion: @escaping (
                Result<Enka.PlayerDetailFetchModel, PlayerDetail.PlayerDetailError>
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
                PlayerDetailsFetchResult
            ) -> ()
        ) {
            let isMiyousheUID = Self.isMiyousheUID(uid: uid)
            let enkaMirror = "https://profile.microgg.cn/api/uid/" + uid
            let enkaOfficial = "https://enka.network/api/uid/" + uid
            let urlStr = isMiyousheUID ? enkaMirror : enkaOfficial
            let url = URL(string: urlStr)!

            // 请求
            HttpMethod<Enka.PlayerDetailFetchModel>
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
                            HttpMethod<Enka.PlayerDetailFetchModel>
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
            var uid = uid
            while uid.count > 9 {
              uid = uid.dropFirst().description
            }
            guard let initial = uid.first else { return false }
            return "12345".contains(initial)
        }
    }
}
