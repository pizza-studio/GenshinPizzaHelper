//
//  Verification.swift
//  GenshinPizzaHepler
//
//  Created by 戴藏龙 on 2023/6/12.
//

import Defaults
import Foundation
import HBMihoyoAPI
import HoYoKit
#if !os(watchOS)
import UIKit

extension MihoyoAPI {
    public static func getDeviceFingerPrint(region: Region) async throws -> String {
        let existingFingerPrint = Defaults[.deviceFingerPrint]
        if !existingFingerPrint.isEmpty {
            return existingFingerPrint
        }
        func generateSeed() -> String {
            let characters = "0123456789abcdef"
            var result = ""
            for _ in 0 ..< 16 {
                let randomIndex = Int.random(in: 0 ..< characters.count)
                let character = characters[characters.index(characters.startIndex, offsetBy: randomIndex)]
                result.append(character)
            }
            return result
        }

        struct DeviceFingerPrintResult: DecodableFromMiHoYoAPIJSONResult {
            let msg: String
            // swiftlint:disable:next identifier_name
            let device_fp: String
            let code: Int
        }

        let url = URL(string: "https://public-data-api.mihoyo.com/device-fp/api/getFp")!
        let body: [String: String] = await [
            "seed_id": generateSeed(),
            "device_id": (UIDevice.current.identifierForVendor ?? UUID()).uuidString,
            "platform": "5",
            "seed_time": "\(Int(Date().timeIntervalSince1970) * 1000)",
            // swiftlint:disable line_length
            "ext_fields": """
            {"userAgent":"Mozilla/5.0 (iPhone; CPU iPhone OS 16_2 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) miHoYoBBS/2.50.1","browserScreenSize":281520,"maxTouchPoints":5,"isTouchSupported":true,"browserLanguage":"zh-CN","browserPlat":"iPhone","browserTimeZone":"Asia/Shanghai","webGlRender":"Apple GPU","webGlVendor":"Apple Inc.","numOfPlugins":0,"listOfPlugins":"unknown","screenRatio":3,"deviceMemory":"unknown","hardwareConcurrency":"4","cpuClass":"unknown","ifNotTrack":"unknown","ifAdBlock":0,"hasLiedResolution":1,"hasLiedOs":0,"hasLiedBrowser":0}
            """,
            // swiftlint:enable line_length
            "app_name": "account_cn",
            "device_fp": "38d7ee834d1e9",
        ]
        var request = URLRequest(url: url)
        request.httpBody = try JSONEncoder().encode(body)
        request.httpMethod = "POST"
        let (data, _) = try await URLSession.shared.data(for: request)
        let fingerPrint = try DeviceFingerPrintResult.decodeFromMiHoYoAPIJSONResult(data: data)
            .device_fp
        return fingerPrint
    }

    public static func createVerification(cookie: String, deviceFingerPrint: String?) async throws -> Verification {
        let queryItems: [URLQueryItem] = [
            .init(name: "is_high", value: "true"),
        ]

        var additionalHeaders: [String: String] = [:]
        if let deviceFingerPrint, !deviceFingerPrint.isEmpty {
            additionalHeaders["x-rpc-device_fp"] = deviceFingerPrint
        }
        additionalHeaders["x-rpc-challenge_path"] =
            "https://api-takumi-record.mihoyo.com/game_record/app/hkrpg/api/note"
        additionalHeaders["x-rpc-challenge_game"] = "6"

        var urlComponents =
            URLComponents(string: "https://api-takumi-record.mihoyo.com/game_record/app/card/wapi/createVerification")!
        urlComponents.queryItems = queryItems
        let url = urlComponents.url!

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.allHTTPHeaderFields = await [
            "User-Agent": """
            Mozilla/5.0 (iPhone; CPU iPhone OS 16_3_1 like Mac OS X) \
            AppleWebKit/605.1.15 (KHTML, like Gecko) miHoYoBBS/2.51.1
            """,
            "Referer": "https://webstatic.mihoyo.com",
            "Origin": "https://webstatic.mihoyo.com",
            "Accept-Encoding": "gzip, deflate, br",
            "Accept-Language": "zh-CN,zh-Hans;q=0.9",
            "Accept": "application/json, text/plain, */*",
            "Connection": "keep-alive",

            "x-rpc-app_version": "2.51.1",
            "x-rpc-client_type": "5",
            "x-rpc-page": "v3.7.1-ys_#/ys",
            "x-rpc-device_id": (UIDevice.current.identifierForVendor ?? UUID()).uuidString,
            "x-rpc-language": Locale.langCodeForAPI,
            "x-rpc-challenge_path": "https://api-takumi-record.mihoyo.com/game_record/app/genshin/api/dailyNote",
            "x-rpc-challenge_game": "2",

            "Sec-Fetch-Dest": "empty",
            "Sec-Fetch-Site": "same-site",
            "Sec-Fetch-Mode": "cors",

            "DS": getDS(query: url.query ?? ""),

            "Cookie": cookie,
        ]
        if let deviceFingerPrint, !deviceFingerPrint.isEmpty {
            request.allHTTPHeaderFields?["x-rpc-device_fp"] = deviceFingerPrint
        }

        let (data, _) = try await URLSession.shared.data(for: request)

        return try .decodeFromMiHoYoAPIJSONResult(data: data)
    }

    public static func verifyVerification(
        challenge: String,
        validate: String,
        cookie: String,
        deviceFingerPrint: String?
    ) async throws
        -> VerifyVerification {
        struct VerifyVerificationBody: Encodable {
            let geetestChallenge: String
            let geetestValidate: String
            let geetestSeccode: String
            init(challenge: String, validate: String) {
                self.geetestChallenge = challenge
                self.geetestValidate = validate
                self.geetestSeccode = "\(validate)|jordan"
            }
        }
        let body = VerifyVerificationBody(challenge: challenge, validate: validate)
        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        let bodyData = try encoder.encode(body)

        let urlComponents =
            URLComponents(string: "https://api-takumi-record.mihoyo.com/game_record/app/card/wapi/verifyVerification")!
        let url = urlComponents.url!

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.allHTTPHeaderFields = await [
            "User-Agent": """
            Mozilla/5.0 (iPhone; CPU iPhone OS 16_3_1 like Mac OS X) \
            AppleWebKit/605.1.15 (KHTML, like Gecko) miHoYoBBS/2.51.1
            """,
            "Referer": "https://webstatic.mihoyo.com",
            "Origin": "https://webstatic.mihoyo.com",
            "Accept-Encoding": "gzip, deflate, br",
            "Accept-Language": "zh-CN,zh-Hans;q=0.9",
            "Accept": "application/json, text/plain, */*",
            "Connection": "keep-alive",

            "x-rpc-app_version": "2.51.1",
            "x-rpc-client_type": "5",
            "x-rpc-page": "v3.7.1-ys_#/ys",
            "x-rpc-device_id": (UIDevice.current.identifierForVendor ?? UUID()).uuidString,
            "x-rpc-language": Locale.langCodeForAPI,
            "x-rpc-challenge_path": "https://api-takumi-record.mihoyo.com/game_record/app/genshin/api/dailyNote",
            "x-rpc-challenge_game": "2",

            "Sec-Fetch-Dest": "empty",
            "Sec-Fetch-Site": "same-site",
            "Sec-Fetch-Mode": "cors",

            "DS": getDS(query: url.query ?? "", body: bodyData),

            "Cookie": cookie,
        ]
        if let deviceFingerPrint, !deviceFingerPrint.isEmpty {
            request.allHTTPHeaderFields?["x-rpc-device_fp"] = deviceFingerPrint
        }

        request.httpBody = bodyData

        let (data, _) = try await URLSession.shared.data(for: request)

        return try .decodeFromMiHoYoAPIJSONResult(data: data)
    }
}

private func getDS(query: String, body: Data? = nil) -> String {
    let salt = "xV8v4Qu54lUKrEYFZkJhB8cuOh9Asafs"

    let time = String(Int(Date().timeIntervalSince1970))
    let randomNumber = String(Int.random(in: 100_000 ..< 200_000))

    let bodyString: String
    if let body = body {
        bodyString = String(data: body, encoding: .utf8) ?? ""
    } else {
        bodyString = ""
    }

    let verification = "salt=\(salt)&t=\(time)&r=\(randomNumber)&b=\(bodyString)&q=\(query)".md5

    return time + "," + randomNumber + "," + verification
}

// MARK: - Verification

public struct Verification: Decodable, DecodableFromMiHoYoAPIJSONResult {
    // MARK: Lifecycle

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.challenge = try container.decode(String.self, forKey: .challenge)
        self.gt = try container.decode(String.self, forKey: .gt)
        self.newCaptcha = try container.decode(Int.self, forKey: .newCaptcha)
        self.success = try container.decode(Int.self, forKey: .success)
    }

    // MARK: Public

    public let challenge: String
    // swiftlint:disable:next identifier_name
    public let gt: String
    public let newCaptcha: Int
    public let success: Int

    // MARK: Internal

    enum CodingKeys: String, CodingKey {
        case challenge
        // swiftlint:disable:next identifier_name
        case gt
        case newCaptcha = "new_captcha"
        case success
    }
}

// MARK: - VerifyVerification

public struct VerifyVerification: Decodable, DecodableFromMiHoYoAPIJSONResult {
    let challenge: String
}

// MARK: - DecodableFromMiHoYoAPIJSONResult

protocol DecodableFromMiHoYoAPIJSONResult: Decodable {}

extension DecodableFromMiHoYoAPIJSONResult {
    /// Decodes data from MiHoYoAPI JSON results
    static func decodeFromMiHoYoAPIJSONResult(data: Data, with request: URLRequest) async throws -> Self {
        let decoder = JSONDecoder()
        let result = try decoder.decode(MiHoYoAPIJSONResult<Self>.self, from: data)
        if result.retcode == 0 {
            // swiftlint:disable:next force_unwrapping
            return result.data!
        } else {
            throw MiHoYoAPIError(retcode: result.retcode, message: result.message)
        }
    }

    static func decodeFromMiHoYoAPIJSONResult(data: Data) throws -> Self {
        let decoder = JSONDecoder()
        let result = try decoder.decode(MiHoYoAPIJSONResult<Self>.self, from: data)
        if result.retcode == 0 {
            // swiftlint:disable:next force_unwrapping
            return result.data!
        } else {
            throw MiHoYoAPIError(retcode: result.retcode, message: result.message)
        }
    }
}

// MARK: - MiHoYoAPIJSONResult

private struct MiHoYoAPIJSONResult<T: DecodableFromMiHoYoAPIJSONResult>: Decodable {
    // MARK: Lifecycle

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.retcode = try container.decode(Int.self, forKey: .retcode)
        self.message = try container.decode(String.self, forKey: .message)
        self.data = try container.decodeIfPresent(T.self, forKey: .data)
    }

    // MARK: Internal

    enum CodingKeys: String, CodingKey {
        case retcode
        case message
        case data
    }

    let retcode: Int
    let message: String
    let data: T?
}

// MARK: - Array + DecodableFromMiHoYoAPIJSONResult

extension Array: DecodableFromMiHoYoAPIJSONResult where Element: Decodable {}

// MARK: - MiHoYoAPIError

public enum MiHoYoAPIError: Error {
    case verificationNeeded
    case other(retcode: Int, message: String)

    // MARK: Lifecycle

    public init(retcode: Int, message: String) {
        if retcode == 1034 {
            self = .verificationNeeded
        } else {
            self = .other(retcode: retcode, message: message)
        }
    }
}
#endif
