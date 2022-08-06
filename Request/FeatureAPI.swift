//
//  FetchAPI.swift
//  原神披萨小助手
//
//  Created by Bill Haku on 2022/8/6.
//

import Foundation

extension API {
    struct Features {
        /// 获取活动列表
        /// - Parameters:
        ///  - completion: 数据
        static func fetchInfos (
            region: Region,
            serverID: String,
            uid: String,
            cookie: String,
            completion: @escaping (
                _ userLoginData: RequestResult?,
                _ errorType: String?
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
                ) { returnData, errorInfo in
                    // 异步返回相应数据
                    completion(returnData, errorInfo)
                }
        }
    }
}
