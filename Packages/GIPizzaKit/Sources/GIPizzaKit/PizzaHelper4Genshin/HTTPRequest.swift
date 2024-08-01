// (c) 2022 and onwards Pizza Studio (GPL v3.0 License).
// ====================
// This code is released under the GPL v3.0 License (SPDX-License-Identifier: GPL-3.0)

import Foundation
import HBMihoyoAPI

// MARK: - Method

enum Method {
    case post
    case get
    case put
}

// MARK: - HttpMethod

extension HttpMethod {
    /// 返回自己的后台的结果接口
    /// - Parameters:
    ///   - method:Method, http方法的类型
    ///   - url:String，请求的路径
    ///   - completion:异步返回处理好的data以及报错的类型
    ///
    ///  需要自己传URL类型的url过来
    public static func homeRequest(
        _ method: Method,
        _ urlStr: String,
        cachedPolicy: URLRequest.CachePolicy = .useProtocolCachePolicy,
        hostType: HostType = .generalHost,
        keyDecodingStrategy: JSONDecoder.KeyDecodingStrategy = .useDefaultKeys,
        completion: @escaping (
            (Result<T, RequestError>) -> ()
        )
    ) {
        homeRequest(
            method,
            urlStr + hostType.hostSuffix,
            cachedPolicy: cachedPolicy,
            baseStr: hostType.hostBase,
            keyDecodingStrategy: .useDefaultKeys
        ) { neta in
            completion(neta)
        }
    }
}
