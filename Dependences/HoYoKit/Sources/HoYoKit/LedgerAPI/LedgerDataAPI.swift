//
//  File.swift
//
//
//  Created by 戴藏龙 on 2023/10/17.
//

import Foundation

extension MiHoYoAPI {
    public static func ledgerData(month: Int, uid: String, server: Server, cookie: String) async throws -> LedgerData {
        let cookie = try await { () -> String in
            if server.region == .mainlandCN {
                let cookieToken = try await cookieToken(cookie: cookie)
                return "cookie_token=\(cookieToken.cookieToken); account_id=\(cookieToken.uid);"
            } else {
                return cookie
            }
        }()
        let queryItems: [URLQueryItem] = switch server.region {
        case .mainlandCN:
            [
                .init(name: "month", value: "\(month)"),
                .init(name: "bind_uid", value: "\(uid)"),
                .init(name: "bind_region", value: server.id),
                .init(
                    name: "bbs_presentation_style",
                    value: "fullscreen"
                ),
                URLQueryItem(name: "bbs_auth_required", value: "true"),
                URLQueryItem(name: "utm_source", value: "bbs"),
                URLQueryItem(name: "utm_medium", value: "mys"),
                URLQueryItem(name: "utm_compaign", value: "icon"),
            ]
        case .global:
            [
                URLQueryItem(name: "month", value: String(month)),
                URLQueryItem(name: "region", value: server.id),
                URLQueryItem(name: "uid", value: String(uid)),
                URLQueryItem(name: "lang", value: Locale.miHoYoAPILanguage.rawValue),
            ]
        }
        let request = try await generateRequest(
            region: server.region,
            host: URLRequestHelperConfiguration.hk4eAPIURLHost(region: server.region),
            path: server.region == .mainlandCN ? "/event/ys_ledger/monthInfo" : "/event/ysledgeros/month_info",
            queryItems: queryItems,
            cookie: cookie,
            additionalHeaders: nil
        )
        let (data, _) = try await URLSession.shared.data(for: request)

        return try await .decodeFromMiHoYoAPIJSONResult(data: data, with: request)
    }
}
