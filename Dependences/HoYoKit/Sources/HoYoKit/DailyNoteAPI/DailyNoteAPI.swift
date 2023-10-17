//
//  File.swift
//
//
//  Created by 戴藏龙 on 2023/10/17.
//

import Foundation

@available(iOS 15.0, *)
extension MiHoYoAPI {
    public static func dailyNote(
        server: Server,
        uid: String,
        cookie: String,
        deviceFingerPrint: String?
    ) async throws
        -> DailyNote {
        let queryItems: [URLQueryItem] = [
            .init(name: "role_id", value: uid),
            .init(name: "server", value: server.rawValue),
        ]

        let additionalHeaders: [String: String]? = {
            if let deviceFingerPrint, !deviceFingerPrint.isEmpty {
                return ["x-rpc-device_fp": deviceFingerPrint]
            } else {
                return nil
            }
        }()

        let request = try await Self.generateRecordAPIRequest(
            region: server.region,
            path: "/game_record/app/genshin/api/dailyNote",
            queryItems: queryItems,
            cookie: cookie,
            additionalHeaders: additionalHeaders
        )

        let (data, _) = try await URLSession.shared.data(for: request)

        return try await .decodeFromMiHoYoAPIJSONResult(data: data, with: request)
    }

    static func widgetDailyNote(
        cookie: String,
        deviceFingerPrint: String?
    ) async throws
        -> WidgetDailyNote {
        let sTokenV2 = try await sTokenV2(cookie: cookie)
        let cookie = cookie + "stoken: \(sTokenV2)"
        let additionalHeaders: [String: String]? = {
            if let deviceFingerPrint, !deviceFingerPrint.isEmpty {
                return ["x-rpc-device_fp": deviceFingerPrint]
            } else {
                return nil
            }
        }()

        let request = try await Self.generateRecordAPIRequest(
            region: .china,
            path: "/game_record/app/genshin/aapi/widget/v2",
            queryItems: [],
            cookie: cookie,
            additionalHeaders: additionalHeaders
        )

        let (data, _) = try await URLSession.shared.data(for: request)
        return try await .decodeFromMiHoYoAPIJSONResult(data: data, with: request)
    }
}
