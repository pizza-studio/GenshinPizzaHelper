//
//  ColorHandler.swift
//  GenshinPizzaHelper
//
//  Created by Bill Haku on 2022/8/12.
//

import Foundation
import SwiftUI

class ColorHandler {
    var colorName: ColorTypes
    var colors: [Color]

    init(colorName: ColorTypes) {
        self.colorName = colorName
        self.colors = colorName.colors
    }
}

enum ColorTypes {
    case purple
    case yellow

    var description: String {
        switch self {
        case .purple:
            return "刻晴紫"
        case .yellow:
            return "出金黄"
        }
    }

    var colors: [Color] {
        switch self {
        case .purple:
            return [
                Color("bgColor.purple.1"),
                Color("bgColor.purple.2"),
                Color("bgColor.purple.3")
            ]
        case .yellow:
            return [
                Color("bgColor.yellow.1"),
                Color("bgColor.yellow.2")
            ]
        }
    }
}
