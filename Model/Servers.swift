//
//  Servers.swift
//  原神披萨小助手
//
//  Created by Bill Haku on 2022/8/6.
//  返回识别服务器信息的工具类

import Foundation
import HBMihoyoAPI
import HoYoKit

// extention for CoreData to save Server
extension AccountConfiguration {
    var server: Server {
        get {
            Server(rawValue: serverRawValue ?? "") ?? fallbackServer
        }
        set {
            serverRawValue = newValue.rawValue
        }
    }

    var fallbackServer: Server {
        Self.getFallbackServer(from: uid) ?? .china
    }

    public static func getFallbackServer(from uid: String?) -> Server? {
        guard var theUID = uid else { return nil }
        while theUID.count > 9 {
            theUID = theUID.dropFirst().description
        }
        guard let initial = theUID.first, let initialInt = Int(initial.description) else { return nil }
        switch initialInt {
        case 1 ... 4: return .china
        case 5: return .bilibili
        case 6: return .unitedStates
        case 7: return .europe
        case 8: return .asia
        case 9: return .hongKongMacauTaiwan
        default: return nil
        }
    }
}
