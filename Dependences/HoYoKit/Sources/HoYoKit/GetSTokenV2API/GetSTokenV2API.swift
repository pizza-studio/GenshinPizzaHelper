//
//  File.swift
//
//
//  Created by 戴藏龙 on 2023/10/17.
//

import Foundation

extension MiHoYoAPI {
    /// 返回STokenV2，需要验证SToken。
    /// 见 [UIGF的文档](https://github.com/UIGF-org/mihoyo-api-collect/blob/main/hoyolab/user/token.md#%E9%80%9A%E8%BF%87stokenv1%E8%8E%B7%E5%8F%96stokenv2)
    public static func sTokenV2(cookie: String) async throws -> String {
        let request = try await generateRequest(
            httpMethod: .post,
            region: .china,
            host: "passport-api.mihoyo.com",
            path: "/account/ma-cn-session/app/getTokenBySToken",
            queryItems: [],
            cookie: cookie,
            additionalHeaders: ["x-rpc-app_id": "bll8iq97cem8"]
        )
        let (data, _) = try await URLSession.shared.data(for: request)

        let result = try GetSTokenV2Result.decodeFromMiHoYoAPIJSONResult(data: data)

        return result.token.token
    }
}

// MARK: - GetSTokenV2Result

private struct GetSTokenV2Result: Decodable, DecodableFromMiHoYoAPIJSONResult {
    struct Token: Decodable {
        let token: String
    }

    let token: Token
}
