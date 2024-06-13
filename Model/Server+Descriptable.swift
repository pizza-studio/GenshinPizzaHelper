//
//  Server+Descriptable.swift
//  GenshinPizzaHelper
//
//  Created by 戴藏龙 on 2023/11/30.
//

import Foundation
import HoYoKit

#if hasFeature(RetroactiveAttribute)
extension Server: @retroactive CustomStringConvertible {}
#else
extension Server: CustomStringConvertible {}
#endif

extension Server {
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
