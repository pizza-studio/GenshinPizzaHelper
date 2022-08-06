//
//  Servers.swift
//  原神披萨小助手
//
//  Created by Bill Haku on 2022/8/6.
//

import Foundation

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
