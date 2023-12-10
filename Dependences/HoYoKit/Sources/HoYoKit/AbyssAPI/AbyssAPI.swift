//
//  File.swift
//
//
//  Created by 戴藏龙 on 2023/10/17.
//

import Foundation

extension MiHoYoAPI {
    public static func abyssData(
        round: SpiralAbyssDetail.AbyssRound,
        server: Server,
        uid: String,
        cookie: String,
        deviceFingerPrint: String?,
        deviceId: UUID?
    ) async throws
        -> SpiralAbyssDetail {
        let queryItems: [URLQueryItem] = [
            .init(name: "role_id", value: uid),
            .init(name: "schedule_type", value: round.rawValue),
            .init(name: "server", value: server.id),
        ]

        let additionalHeaders: [String: String]? = {
            if let deviceFingerPrint, !deviceFingerPrint.isEmpty, let deviceId {
                return [
                    "x-rpc-device_fp": deviceFingerPrint,
                    "x-rpc-device_id": deviceId.uuidString,
                ]
            } else {
                return nil
            }
        }()

        let request = try await Self.generateRecordAPIRequest(
            region: server.region,
            path: "/game_record/app/genshin/api/spiralAbyss",
            queryItems: queryItems,
            cookie: cookie,
            additionalHeaders: additionalHeaders
        )

        let (data, _) = try await URLSession.shared.data(for: request)

        return try await .decodeFromMiHoYoAPIJSONResult(data: data, with: request)
    }
}
