//
//  Servers.swift
//  原神披萨小助手
//
//  Created by Bill Haku on 2022/8/6.
//

import Foundation

// 服务器类型
enum Server: String, CaseIterable, Identifiable {
    case china = "官服"
    case bilibili = "B服"

    var id: String {
        switch self {
        case .china:
            return "cn_gf01"
        case .bilibili:
            return "cn_qd01"
        }
    }
}

// 地区类型，用于区分请求的Host URL
enum Region {
    // 国服，含官服和B服
    case cn
    // 国际服
    case global
}
