//
//  WidgetBackgroundView.swift
//  GenshinPizzaHepler
//
//  Created by 戴藏龙 on 2022/8/7.
//

import SwiftUI

struct WidgetBackgroundView: View {
    let backgroundColors: [Color] = [
        Color("bgColor.purple.1"),
        Color("bgColor.purple.2"),
        Color("bgColor.purple.3")
    ]
    
    var body: some View {
        LinearGradient(colors: backgroundColors, startPoint: .topLeading, endPoint: .bottomTrailing)
    }
}

