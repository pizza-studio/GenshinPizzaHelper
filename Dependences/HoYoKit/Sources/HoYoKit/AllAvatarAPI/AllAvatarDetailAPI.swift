//
//  File.swift
//
//
//  Created by 戴藏龙 on 2023/10/17.
//

import Foundation

extension MiHoYoAPI {
    public static func allAvatarDetail(
        server: Server,
        uid: String,
        cookie: String,
        deviceFingerPrint: String?,
        deviceId: UUID?
    ) async throws
        -> AllAvatarDetailModel {
        struct RequestBody: Codable {
            let role_id: String
            let server: String
        }

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

        let encoder = JSONEncoder()
        let body = try encoder.encode(RequestBody(role_id: uid, server: server.id))

        let request = try await Self.generateRecordAPIRequest(
            httpMethod: .post,
            region: server.region,
            path: "/game_record/app/genshin/api/character",
            queryItems: [],
            body: body,
            cookie: cookie,
            additionalHeaders: additionalHeaders
        )

        let (data, _) = try await URLSession.shared.data(for: request)

        return try await .decodeFromMiHoYoAPIJSONResult(data: data, with: request)
    }
}
