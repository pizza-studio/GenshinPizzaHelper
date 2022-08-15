//
//  WidgetBackgroundView.swift
//  GenshinPizzaHepler
//
//  Created by 戴藏龙 on 2022/8/7.
//

import SwiftUI

struct WidgetBackgroundView: View {
    let backgroundColors: [Color]
    let backgroundIconName: String?
    
    var body: some View {
        ZStack{
            LinearGradient(colors: backgroundColors, startPoint: .topLeading, endPoint: .bottomTrailing)
            if let backgroundIconName = backgroundIconName {
                GeometryReader { g in
                    Image(backgroundIconName)
                        .resizable()
                        .scaledToFill()
                        .opacity(0.05)
                        .padding()
                        .frame(width: g.size.width, height: g.size.height)
//                        .blur(radius: 0.5)
                }
//                Image(backgroundIconName)
//                    .resizable()
//                    .scaledToFit()
//                    .opacity(0.05)
//                    .padding()
                    
            }
        }
        
    }
}

