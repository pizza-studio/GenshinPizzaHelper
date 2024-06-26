//
//  File.swift
//
//
//  Created by 戴藏龙 on 2024/5/11.
//

import Foundation

extension MiHoYoAPI {
    static public func queryQRCodeStatus(deviceId: UUID, ticket: String) async throws -> QueryQRCodeStatus {
        let appId = "4"
        var request = URLRequest(url: URL(string: "https://hk4e-sdk.mihoyo.com/hk4e_cn/combo/panda/qrcode/query")!)
        request.httpMethod = "POST"

        struct Body: Encodable {
            let appId: String
            let device: String
            let ticket: String
        }

        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        let body = Body(appId: appId, device: deviceId.uuidString, ticket: ticket)
        let bodyData = try encoder.encode(body)
        request.httpBody = bodyData

        let (resultData, _) = try await URLSession.shared.data(for: request)
        return try .decodeFromMiHoYoAPIJSONResult(data: resultData)
    }
}
