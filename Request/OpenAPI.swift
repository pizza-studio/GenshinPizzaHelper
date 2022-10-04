//
//  OpenAPI.swift
//  GenshinPizzaHelper
//
//  Created by Bill Haku on 2022/9/17.
//

import Foundation

extension API {
    struct OpenAPIs {
        /// 获取当前活动信息
        /// - Parameters:
        ///     - completion: 数据
        static func fetchCurrentEvents (
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
                    url
                ) { result in
                    switch result {

                    case .success(let requestResult):
                        print("request succeed")
                        completion(.success(requestResult))

                    case .failure(let requestError):
                        switch requestError {
                        case .decodeError(let message):
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
        private static func fetchPlayerDatas (
            _ uid: String,
            completion: @escaping (
                PlayerDetailsFetchResult
            ) -> ()
        ) {
            // 请求类别
            let urlStr = "https://enka.network/u/\(uid)/__data.json"
            let url = URL(string: urlStr)!

            // 请求
            HttpMethod<PlayerDetailFetchModel>
                .openRequest(
                    .get,
                    url
                ) { result in
                    switch result {

                    case .success(let requestResult):
                        print("request succeed")
                        completion(.success(requestResult))

                    case .failure(let requestError):
                        switch requestError {
                        case .decodeError(let message):
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
        static func fetchPlayerDetail (
            _ uid: String,
            completion: @escaping (
                Result<PlayerDetail, PlayerDetail.PlayerDetailError>
            ) -> ()
        ) {
            var playerDetailModel: PlayerDetailFetchModel?
            var charLoc: ENCharacterLoc?
            var charMap: ENCharacterMap?
            let group = DispatchGroup()
            group.enter()
            API.HomeAPIs.fetchENCharacterLocDatas {
                charLoc = $0
                group.leave()
            }
            group.enter()
            API.HomeAPIs.fetchENCharacterDetailDatas {
                charMap = $0
                group.leave()
            }
            group.enter()
            fetchPlayerDatas(uid) { result in
                switch result {
                case .success(let model):
                    playerDetailModel = model
                case .failure(_):
                    break
                }
                group.leave()
            }
            group.notify(queue: .main) {
                guard let playerDetailModel = playerDetailModel else {
                    completion(.failure(.failToGetCharacterData)); return
                }
                guard let charLoc = charLoc else {
                    completion(.failure(.failToGetLocalizedDictionary)); return
                }
                guard let charMap = charMap else {
                    completion(.failure(.failToGetCharacterDictionary)); return
                }
                completion(.success(.init(playerDetailFetchModel: playerDetailModel, localizedDictionary: charLoc.getLocalizedDictionary(), characterMap: charMap)))
            }

        /// 获取原神辞典数据
        /// - Parameters:
        ///     - completion: 数据
        static func fetchGenshinDictionaryData (
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

                    case .success(let requestResult):
                        print("request succeed")
                        completion(requestResult)

                    case .failure(_):
                        print("request Genshin Dictionary Data Fail")
                        break
                    }
                }
        }
    }
}
