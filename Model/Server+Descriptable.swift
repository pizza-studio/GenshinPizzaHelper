//
//  Server+Descriptable.swift
//  GenshinPizzaHelper
//
//  Created by 戴藏龙 on 2023/11/30.
//

import Foundation
import HoYoKit

extension Server: CustomStringConvertible {
    public var description: String {
        switch self {
        case .china:
            return "天空岛"
        case .bilibili:
            return "世界树"
        case .unitedStates:
            return "America"
        case .europe:
            return "Europe"
        case .asia:
            return "Asia"
        case .hongKongMacauTaiwan:
            return "TW/HK/MO"
        }
    }
}
