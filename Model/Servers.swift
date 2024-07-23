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
extension Account {
    var server: Server {
        get {
            Server(rawValue: serverRawValue ?? "") ?? fallbackServer
        }
        set {
            serverRawValue = newValue.rawValue
        }
    }

    var fallbackServer: Server {
        Server(uid: uid) ?? .china
    }
}
