//
//  Servers.swift
//
//
//  Created by Bill Haku on 2023/3/26.
//  返回识别服务器信息的工具类

import Foundation

// MARK: - Server

// 服务器类型
public enum Server: String, CaseIterable, Identifiable {
    case celestia = "天空岛"
    case irminsul = "世界树"
    case us = "America"
    case eu = "Europe"
    case asia = "Asia"
    case hongKongMacauTaiwan = "TW/HK/MO"

    // MARK: Public

    public var localizedKey: String {
        "server.region.name.\(String(describing: self))"
    }

    public var localized: String { localizedKey.localized }

    public var id: String {
        switch self {
        case .celestia:
            return "cn_gf01"
        case .irminsul:
            return "cn_qd01"
        case .us:
            return "os_usa"
        case .eu:
            return "os_euro"
        case .asia:
            return "os_asia"
        case .hongKongMacauTaiwan:
            return "os_cht"
        }
    }

    public var region: Region {
        switch self {
        case .celestia, .irminsul:
            return .cn
        case .asia, .eu, .hongKongMacauTaiwan, .us:
            return .global
        }
    }

    public static func id(_ id: String) -> Self {
        switch id {
        case "cn_gf01":
            return .celestia
        case "cn_qd01":
            return .irminsul
        case "os_usa":
            return .us
        case "os_euro":
            return .eu
        case "os_asia":
            return .asia
        case "os_cht":
            return .hongKongMacauTaiwan
        default:
            return .celestia
        }
    }

    public func timeZone() -> TimeZone {
        switch self {
        case .asia, .celestia, .hongKongMacauTaiwan, .irminsul:
            return .init(secondsFromGMT: 8 * 60 * 60) ?? .current
        case .us:
            return .init(secondsFromGMT: -5 * 60 * 60) ?? .current
        case .eu:
            return .init(secondsFromGMT: 1 * 60 * 60) ?? .current
        }
    }
}

// MARK: RawRepresentable

extension Server: RawRepresentable {}

// MARK: - Region

// 地区类型，用于区分请求的Host URL
public enum Region: Identifiable, CaseIterable {
    // 国服，含官服和B服
    case cn
    // 国际服
    case global

    // MARK: Public

    public var id: Int {
        hashValue
    }

    public var value: String {
        switch self {
        case .cn:
            return "中国大陆"
        case .global:
            return "国际"
        }
    }
}
