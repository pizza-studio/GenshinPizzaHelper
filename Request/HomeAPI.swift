//
//  HomeAPI.swift
//  GenshinPizzaHelper
//
//  Created by Bill Haku on 2022/9/26.
//

import Foundation

extension API {
    struct HomeAPIs {
        /// 获取最新系统版本
        /// - Parameters:
        ///     - isBeta: 是否是Beta
        ///     - completion: 数据
        static func fetchNewestVersion (
            isBeta: Bool,
            completion: @escaping (
                NewestVersion
            ) -> ()
        ) {
            // 请求类别
            let urlStr: String
            if isBeta {
                urlStr = "api/app/newest_version_beta.json"
            } else {
                urlStr = "api/app/newest_version.json"
            }

            // 请求
            HttpMethod<NewestVersion>
                .homeRequest(
                    .get,
                    urlStr
                ) { result in
                    switch result {

                    case .success(let requestResult):
                        print("request succeed")
                        completion(requestResult)

                    case .failure(_):
                        print("request newest version fail")
                        break
                    }
                }
        }
    }
}
