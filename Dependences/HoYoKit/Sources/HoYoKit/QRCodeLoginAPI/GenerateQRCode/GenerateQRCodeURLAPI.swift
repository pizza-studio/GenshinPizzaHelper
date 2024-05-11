//
//  File.swift
//
//
//  Created by 戴藏龙 on 2024/5/10.
//

import CoreImage
import Foundation
import UIKit

extension MiHoYoAPI {
    public static func generateQRCodeURL(deviceId: UUID) async throws -> (url: URL, ticket: String) {
        var request = URLRequest(url: URL(string: "https://hk4e-sdk.mihoyo.com/hk4e_cn/combo/panda/qrcode/fetch")!)
        request.httpMethod = "POST"

        struct Body: Encodable {
            let appId: String
            let device: String
        }

        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase

        request.httpBody = try encoder.encode(Body(appId: "4", device: deviceId.uuidString))

        let (data, _) = try await URLSession.shared.data(for: request)

        let resultData = try await GenerateQRCodeURLData.decodeFromMiHoYoAPIJSONResult(data: data, with: request)

        let resultURL = resultData.url
        let urlComponents = URLComponents(url: resultURL, resolvingAgainstBaseURL: false)
        let ticket = urlComponents?.queryItems?.first(where: { item in
            item.name == "ticket"
        })?.value

        guard let ticket else { throw MiHoYoAPIError.other(retcode: -999, message: "Invalid URL \(resultURL)") }

        return (url: resultURL, ticket: ticket)
    }

    public static func generateLoginQRCode(deviceId: UUID) async throws -> (qrCode: UIImage, ticket: String) {
        let result = try await generateQRCodeURL(deviceId: deviceId)
        if let qrCode = generateQRCode(from: result.url.absoluteString) {
            return (qrCode, result.ticket)
        } else {
            throw MiHoYoAPIError.other(retcode: -999, message: "Invalid URL \(result.url)")
        }
    }
}

private func generateQRCode(from string: String) -> UIImage? {
    let data = string.data(using: String.Encoding.ascii)

    if let filter = CIFilter(name: "CIQRCodeGenerator") {
        filter.setValue(data, forKey: "inputMessage")
        let transform = CGAffineTransform(scaleX: 3, y: 3)

        if let output = filter.outputImage?.transformed(by: transform) {
            return UIImage(ciImage: output)
        }
    }

    return nil
}

func generate64RandomString() -> String {
    let lettersAndNumbers = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
    let randomString = String((0..<64).map { _ in lettersAndNumbers.randomElement()! })
    return randomString
}
