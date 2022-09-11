//
//  ProgressGaugeStyle.swift
//  ResinStatusWidgetExtension
//
//  Created by 戴藏龙 on 2022/9/11.
//

import Foundation
import SwiftUI

@available(iOS 16.0, *)
struct ProgressGaugeStyle: GaugeStyle {
    func makeBody(configuration: Configuration) -> some View {
        ZStack {
            TotalArc().stroke(Color.indigo, style: StrokeStyle(lineWidth: 6, lineCap: .round)).opacity(0.5)
            Arc(percentage: configuration.value).stroke(Color.white, style: StrokeStyle(lineWidth: 6, lineCap: .round)).shadow(radius: 1)
            configuration.currentValueLabel
                .frame(maxWidth: 38)
            VStack {
                Spacer()
                configuration.label
                    .frame(width: 17, height: 17)
                    .padding(.bottom, -4)
            }
        }.frame(width: 50, height: 50)
    }
}

struct TotalArc: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let radius = max(rect.size.width, rect.size.height) / 2
        path.addArc(center: CGPoint(x: rect.midX, y: rect.midY),
                    radius: radius,
                    startAngle: .degrees(45),
                    endAngle: .degrees(135),
                    clockwise: true)
        return path
    }
}

struct Arc: Shape {
    var percentage: Double

    func path(in rect: CGRect) -> Path {
        var path = Path()
        let radius = max(rect.size.width, rect.size.height) / 2
        path.addArc(center: CGPoint(x: rect.midX, y: rect.midY),
                    radius: radius,
                    startAngle: .degrees(45 - (1 - percentage) * 270),
                    endAngle: .degrees(135),
                    clockwise: true)
        return path
    }
}
