//
//  Servers.swift
//
//
//  Created by Bill Haku on 2023/3/26.
//  返回识别服务器信息的工具类

import Foundation

// MARK: - Server

/// The server of an StarRail account.
public enum Server: String, CaseIterable {
    case china = "cn_gf01"
    case bilibili = "cn_qd01"
    case unitedStates = "os_usa"
    case europe = "os_euro"
    case asia = "os_asia"
    case hongKongMacauTaiwan = "os_cht"
}

extension Server {
    /// The region of the server.
    public var region: Region {
        switch self {
        case .bilibili, .china:
            return .china
        case .asia, .europe, .hongKongMacauTaiwan, .unitedStates:
            return .global
        }
    }

    /// The timezone of the server.
    public var timeZone: TimeZone {
        switch self {
        case .asia, .bilibili, .china, .hongKongMacauTaiwan:
            return .init(secondsFromGMT: 8 * 60 * 60) ?? .current
        case .unitedStates:
            return .init(secondsFromGMT: -5 * 60 * 60) ?? .current
        case .europe:
            return .init(secondsFromGMT: 1 * 60 * 60) ?? .current
        }
    }
}

// MARK: Identifiable

extension Server: Identifiable {
    public var id: String {
        rawValue
    }
}

// MARK: Codable

extension Server: Codable {}

// MARK: CustomStringConvertible

// extension Server: CustomStringConvertible {
//    public var description: String {
//        switch self {
//        case .china:
//            return "星穹列车"
//        case .bilibili:
//            return "无名客"
//        case .unitedStates:
//            return "America"
//        case .europe:
//            return "Europe"
//        case .asia:
//            return "Asia"
//        case .hongKongMacauTaiwan:
//            return "TW/HK/MO"
//        }
//    }
// }
