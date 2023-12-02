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
            if let serverRawValue {
                Server(rawValue: serverRawValue) ?? .china
            } else {
                Server.china
            }
        }
        set {
            serverRawValue = newValue.rawValue
        }
    }
}
