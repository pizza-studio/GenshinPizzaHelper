//
//  View+OverlayCircleClipedBackground.swift
//  GenshinPizzaHepler
//
//  Created by 戴藏龙 on 2023/3/19.
//

import Foundation
import SwiftUI

struct CircleClippedBackground<Background: View>: ViewModifier {
    /// 圆内接正方形缩放大小
    let scaler: Double
    let background: () -> Background

    func body(content: Content) -> some View {
        GeometryReader { g in
            // 圆内接正方形变长
            let r = g.size.width - 0.8
            let frameWidth = ( sqrt(2)/2 * r ) * scaler

            ZStack {
                content
                    .frame(width: frameWidth, height: frameWidth)
                background()
            }
        }
    }
}

extension View {
    func circleClippedBackground<Background: View>(
        scaler: Double, background: @escaping () -> Background)
    -> some View {
        modifier(CircleClippedBackground(scaler: scaler, background: background))
    }
}
