//
//  FetchAPI.swift
//  原神披萨小助手
//
//  Created by Bill Haku on 2022/8/6.
//

import Foundation

extension API {
    struct Features {
        /// 获取信息
        /// - Parameters:
        ///  - region: 服务器地区
        ///  - serverID: 服务器ID
        ///  - uid: 用户UID
        ///  - cookie: 用户Cookie
        ///  - completion: 数据
        static func fetchInfos (
            region: Region,
            serverID: String,
            uid: String,
            cookie: String,
            completion: @escaping (
                FetchResult
            ) -> ()
        ) {
            // 请求类别
            let urlStr = "game_record/app/genshin/api/dailyNote"
            
            if (uid == "") || (cookie == "") {
                completion(.failure(.noFetchInfo))
            }
            
            // 请求
            HttpMethod<RequestResult>
                .commonRequest(
                    .get,
                    urlStr,
                    region,
                    serverID,
                    uid,
                    cookie
                ) { result in
                    switch result {
                        
                    case .success(let requestResult):
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
                            completion(.failure(.cookieInvalid(retcode, message)))
                        case 10102, 10103, 10104:
                            print("fail nomatch")
                            completion(.failure(.unmachedAccountCookie(retcode, message)))
                        case 1008:
                            print("fail 1008")
                            completion(.failure(.accountInvalid(retcode, message)))
                        case -1:
                            print("fail -1")
                            completion(.failure(.dataNotFound(retcode, message)))
                        default:
                            print("unknowerror")
                            completion(.failure(.unknownError(retcode, message)))
                        }
                        
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
    }
}
