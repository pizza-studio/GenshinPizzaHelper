//
//  Error.swift
//  原神披萨小助手
//
//  Created by Bill Haku on 2022/8/6.
//

import Foundation

struct ErrorCode: Codable {
    var code: Int
    var message: String?
}
