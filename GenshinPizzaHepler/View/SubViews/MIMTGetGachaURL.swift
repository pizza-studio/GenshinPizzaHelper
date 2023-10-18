//
//  MIMTGetGachaView.swift
//  GenshinPizzaHepler
//
//  Created by 戴藏龙 on 2023/4/1.
//

import HBMihoyoAPI
import HoYoKit
import SwiftUI

func parseURLToAuthkeyAndOtherParams(urlString: String)
    -> Result<
        (authKey: GenAuthKeyResult.GenAuthKeyData, server: Server),
        GetGachaError
    > {
    guard let decodedUrlString = urlString.removingPercentEncoding else {
        return .failure(.genAuthKeyError(message: "URL Error: \(urlString)"))
    }
    guard let url = URL(string: decodedUrlString)
    else {
        return .failure(.genAuthKeyError(message: "URL Error: \(urlString)"))
    }
    let queryItems = URLComponents(url: url, resolvingAgainstBaseURL: false)?
        .queryItems
    guard let items = queryItems
    else {
        return .failure(.genAuthKeyError(message: "URL Error: \(urlString)"))
    }
    guard let authkey = items.first(where: { $0.name == "authkey" })?.value
    else {
        return .failure(
            .genAuthKeyError(message: "URL ERROR (no authkey): \(urlString)")
        )
    }
    guard let signTypeString = items.first(where: { $0.name == "sign_type" })?
        .value
    else {
        return .failure(
            .genAuthKeyError(message: "URL ERROR (no sign_type): \(urlString)")
        )
    }
    guard let signType = Int(signTypeString)
    else {
        return .failure(
            .genAuthKeyError(message: "URL ERROR (no sign_type): \(urlString)")
        )
    }
    guard let authkeyVerString = items
        .first(where: { $0.name == "authkey_ver" })?.value
    else {
        return .failure(
            .genAuthKeyError(message: "URL ERROR (no sign_type): \(urlString)")
        )
    }
    guard let authkeyVer = Int(authkeyVerString)
    else {
        return .failure(
            .genAuthKeyError(message: "URL ERROR (no sign_type): \(urlString)")
        )
    }
    guard let serverId = items.first(where: { $0.name == "region" })?.value
    else {
        return .failure(
            .genAuthKeyError(message: "URL ERROR (no sign_type): \(urlString)")
        )
    }

    return .success(
        (
            GenAuthKeyResult
                .GenAuthKeyData(
                    authkeyVer: authkeyVer,
                    signType: signType,
                    authkey: authkey
                ),
            Server.id(serverId)
        )
    )
}
