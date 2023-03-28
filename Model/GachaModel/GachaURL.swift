//
//  GachaURL.swift
//  GenshinPizzaHepler
//
//  Created by 戴藏龙 on 2023/3/28.
//

import Foundation

func genGachaURL(
    account: AccountConfiguration,
    authkey: GenAuthKeyResult.GenAuthKeyData,
    gachaType: GachaType,
    page: Int,
    endId: String
) -> URL {
    let gameBiz: String
    switch account.server.region {
    case .cn: gameBiz = "hk4e_cn"
    case .global: gameBiz = "hk4e_global"
    }

    let lang = "zh-cn"

    var urlComponents = URLComponents()
    urlComponents.scheme = "https"
    switch account.server.region {
    case .cn: urlComponents.host = "hk4e-api.mihoyo.com"
    case .global: urlComponents.host = "sg-hk4e-api.hoyolab.com/"
    }
    urlComponents.path = "/event/gacha_info/api/getGachaLog"

    urlComponents.queryItems = [
        .init(name: "win_mode", value: "fullscreen"),
        .init(name: "authkey_ver", value: String(authkey.authkeyVer)),
        .init(name: "sign_type", value: String(authkey.signType)),
        .init(name: "auth_appid", value: "webview_gacha"),
        .init(name: "init_type", value: "301"),
        .init(name: "gacha_id", value: "9e72b521e716d347e3027a4f71efc08f1455d4b2"),
        .init(name: "timestamp", value: String(Int(Date().timeIntervalSince1970))),
        .init(name: "lang", value: lang),
        .init(name: "device_type", value: "mobile"),
        .init(name: "game_version", value: "CNRELiOS3.5.0_R13695448_S13586568_D13718257"),
        .init(name: "plat_type", value: "ios"),
        .init(name: "region", value: account.server.id),
        .init(name: "game_biz", value: gameBiz),
        .init(name: "gacha_type", value: String(GachaType.character.rawValue)),
        .init(name: "page", value: String(page)),
        .init(name: "size", value: "20"),
        .init(name: "end_id", value: endId),
    ]

    urlComponents.percentEncodedQueryItems!.append(.init(name: "authkey", value: authkey.authkey.addingPercentEncoding(withAllowedCharacters: .alphanumerics)!))

    return urlComponents.url!
}
