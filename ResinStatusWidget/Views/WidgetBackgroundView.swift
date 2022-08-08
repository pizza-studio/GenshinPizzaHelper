//
//  WidgetBackgroundView.swift
//  GenshinPizzaHepler
//
//  Created by 戴藏龙 on 2022/8/7.
//

import SwiftUI

struct WidgetBackgroundView: View {
    let backgroundColors: [Color] = [
        Color("backgroundColor1"),
        Color("backgroundColor2"),
        Color("backgroundColor3")
    ]
    
    var body: some View {
        LinearGradient(colors: backgroundColors, startPoint: .topLeading, endPoint: .bottomTrailing)
    }
}

