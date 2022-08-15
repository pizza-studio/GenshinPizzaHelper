//
//  ColorHandler.swift
//  GenshinPizzaHelper
//
//  Created by Bill Haku on 2022/8/12.
//

import Foundation
import SwiftUI

class ColorHandler {
    var backgroundColor: WidgetBackgroundColor
    var colors: [Color]

    init(widgetBackgroundColor: WidgetBackgroundColor) {
        self.backgroundColor = widgetBackgroundColor
        self.colors = widgetBackgroundColor.colors
    }
}

extension WidgetBackgroundColor {
    var description: String {
        switch self {
        case .unknown:
            return "（未知）"
        case .gray:
            return "★灰"
        case .green:
            return "★★绿"
        case .blue:
            return "★★★蓝"
        case .purple:
            return "★★★★紫"
        case .yellow:
            return "★★★★★金"
        case .red:
            return "异世界红"
            
            
        case .wind:
            return "风元素"
        case .water:
            return "水元素"
        case .ice:
            return "冰元素"
        case .fire:
            return "火元素"
        case .stone:
            return "岩元素"
        case .thunder:
            return "雷元素"
        case .glass:
            return "草元素"
        case .intertwinedFate:
            return "纠缠之缘"
            
        }
    }
    
    var iconName: String? {
        switch self {
        case .wind:
            return "风元素图标"
        case .water:
            return "水元素图标"
        case .ice:
            return "冰元素图标"
        case .fire:
            return "火元素图标"
        case .stone:
            return "岩元素图标"
        case .thunder:
            return "雷元素图标"
        case .glass:
            return "草元素图标"
        default:
            return nil
        }
    }

    var colors: [Color] {
        switch self {
        case .purple, .unknown:
            return [
                Color("bgColor.purple.1"),
                Color("bgColor.purple.2"),
                Color("bgColor.purple.3")
            ]
        case .yellow:
            return [
                Color("bgColor.yellow.1"),
                Color("bgColor.yellow.2"),
                Color("bgColor.yellow.3")
            ]
        case .gray:
            return [
                Color("bgColor.gray.1"),
                Color("bgColor.gray.2"),
                Color("bgColor.gray.3")
            ]
        case .green:
            return [
                Color("bgColor.green.1"),
                Color("bgColor.green.2"),
                Color("bgColor.green.3")
            ]
        case .blue:
            return [
                Color("bgColor.blue.1"),
                Color("bgColor.blue.2"),
                Color("bgColor.blue.3")
            ]
        case .red:
            return [
                Color("bgColor.red.1"),
                Color("bgColor.red.2"),
                Color("bgColor.red.3")
            ]
            
            
        case .wind:
            return [
                Color("bgColor.wind.1"),
                Color("bgColor.wind.2"),
                Color("bgColor.wind.3")
            ]
        case .water:
            return [
                Color("bgColor.water.1"),
                Color("bgColor.water.2"),
                Color("bgColor.water.3")
            ]
        case .ice:
            return [
                Color("bgColor.ice.1"),
                Color("bgColor.ice.2"),
                Color("bgColor.ice.3")
            ]
        case .fire:
            return [
                Color("bgColor.fire.1"),
                Color("bgColor.fire.2"),
                Color("bgColor.fire.3")
            ]
        case .stone:
            return [
                Color("bgColor.stone.1"),
                Color("bgColor.stone.2"),
                Color("bgColor.stone.3")
            ]
        case .thunder:
            return [
                Color("bgColor.thunder.1"),
                Color("bgColor.thunder.2"),
                Color("bgColor.thunder.3")
            ]
        case .glass:
            return [
                Color("bgColor.glass.1"),
                Color("bgColor.glass.2"),
                Color("bgColor.glass.3")
            ]
        case .intertwinedFate:
            return [
                Color("bgColor.intertwinedFate.1"),
                Color("bgColor.intertwinedFate.2"),
                Color("bgColor.intertwinedFate.3")
            ]
        }
    }
}




//enum ColorTypes {
//    case purple
//    case yellow
//    case gray
//    case green
//    case blue
//    case red
//
//    case wind
//    case water
//    case thunder
//    case fire
//    case ice
//    case stone
//    case glass
//
//    var description: String {
//        switch self {
//        case .gray:
//            return "★灰"
//        case .green:
//            return "★★绿"
//        case .blue:
//            return "★★★蓝"
//        case .purple:
//            return "★★★★紫"
//        case .yellow:
//            return "★★★★★金"
//        case .red:
//            return "异世界红"
//
//
//        case .wind:
//            return "风元素"
//        case .water:
//            return "水元素"
//        case .ice:
//            return "冰元素"
//        case .fire:
//            return "火元素"
//        case .stone:
//            return "岩元素"
//        case .thunder:
//            return "雷元素"
//        case .glass:
//            return "草元素"
//
//        }
//    }
//
//    var colors: [Color] {
//        switch self {
//        case .purple:
//            return [
//                Color("bgColor.purple.1"),
//                Color("bgColor.purple.2"),
//                Color("bgColor.purple.3")
//            ]
//        case .yellow:
//            return [
//                Color("bgColor.yellow.1"),
//                Color("bgColor.yellow.2"),
//                Color("bgColor.yellow.3")
//            ]
//        case .gray:
//            return [
//                Color("bgColor.gray.1"),
//                Color("bgColor.gray.2"),
//                Color("bgColor.gray.3")
//            ]
//        case .green:
//            return [
//                Color("bgColor.green.1"),
//                Color("bgColor.green.2"),
//                Color("bgColor.green.3")
//            ]
//        case .blue:
//            return [
//                Color("bgColor.blue.1"),
//                Color("bgColor.blue.2"),
//                Color("bgColor.blue.3")
//            ]
//        case .red:
//            return [
//                Color("bgColor.red.1"),
//                Color("bgColor.red.2"),
//                Color("bgColor.red.3")
//            ]
//
//
//        case .wind:
//            return [
//                Color("bgColor.wind.1"),
//                Color("bgColor.wind.2"),
//                Color("bgColor.wind.3")
//            ]
//        case .water:
//            return [
//                Color("bgColor.water.1"),
//                Color("bgColor.water.2"),
//                Color("bgColor.water.3")
//            ]
//        case .ice:
//            return [
//                Color("bgColor.ice.1"),
//                Color("bgColor.ice.2"),
//                Color("bgColor.ice.3")
//            ]
//        case .fire:
//            return [
//                Color("bgColor.fire.1"),
//                Color("bgColor.fire.2"),
//                Color("bgColor.fire.3")
//            ]
//        case .stone:
//            return [
//                Color("bgColor.stone.1"),
//                Color("bgColor.stone.2"),
//                Color("bgColor.stone.3")
//            ]
//        case .thunder:
//            return [
//                Color("bgColor.thunder.1"),
//                Color("bgColor.thunder.2"),
//                Color("bgColor.thunder.3")
//            ]
//        case .glass:
//            return [
//                Color("bgColor.glass.1"),
//                Color("bgColor.glass.2"),
//                Color("bgColor.glass.3")
//            ]
//        }
//    }
//}
