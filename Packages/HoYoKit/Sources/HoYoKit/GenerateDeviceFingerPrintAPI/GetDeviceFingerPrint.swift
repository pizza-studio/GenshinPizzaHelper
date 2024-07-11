//
//  File.swift
//
//
//  Created by 戴藏龙 on 2023/6/11.
//

import Foundation
import UIKit

@available(iOS 15.0, *)
extension MiHoYoAPI {
    public static func getDeviceFingerPrint(deviceId: UUID) async throws -> String {
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
        let deviceId = deviceId.uuidString
        let body: [String: String] = [
            "seed_id": generateSeed(),
            "device_id": deviceId,
            "platform": "5",
            "seed_time": "\(Int(Date().timeIntervalSince1970) * 1000)",
            // swiftlint:disable line_length
            "ext_fields": """
            {"vendor":"--","ramCapacity":"3662","cpuCores":"6","chargeStatus":"3","romCapacity":"121947","ramRemain":"76","accelerometer":"0.054596x-0.290237x-0.957809","networkType":"WIFI","screenSize":"390×844","isJailBreak":"0","gyroscope":"-0.024806x0.070681x-0.020708","IDFV":"275379E1-5FB1-42B9-86D6-F4F80A6CAC2C","proxyStatus":"1","magnetometer":"-118.163391x-247.904663x-353.548492","batteryStatus":"100","cpuType":"CPU_TYPE_ARM64","model":"iPhone13,2","osVersion":"17.1.1","romRemain":"3963","appMemory":"60"}
            """,
            // swiftlint:enable line_length
            "app_name": "bbs_cn",
            "device_fp": "38d7ebd3b45ae",
        ]
        var request = URLRequest(url: url)
        request.httpBody = try JSONEncoder().encode(body)
        request.httpMethod = "POST"
        let (data, _) = try await URLSession.shared.data(for: request)
        let fingerPrint = try DeviceFingerPrintResult.decodeFromMiHoYoAPIJSONResult(data: data)
            .device_fp
        return fingerPrint
    }
}
