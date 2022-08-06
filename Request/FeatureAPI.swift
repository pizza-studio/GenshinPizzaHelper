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
                _ retCode: Int,
                _ userLoginData: RequestResult?,
                _ errorInfo: String?
            ) -> ()
        ) {
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
                    cookie
                ) { returnData in
                    // 根据结果返回相应数据
                    if returnData == nil {
                        completion(-1, returnData, "Return Data found nil")
                        return
                    }
                    if returnData!.retcode != 0 {
                        completion(returnData!.retcode, returnData, returnData!.message)
                    } else {
                        completion(0, returnData, nil)
                    }
                }
        }
    }
}
