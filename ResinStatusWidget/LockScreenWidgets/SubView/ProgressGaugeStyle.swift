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
    var circleColor: Color = .white
//    var valueTextColor: Color = .white
//    var labelColor: Color = .white

    #if os(watchOS)
    let strokeLineWidth: CGFloat = 5
    #else
    let strokeLineWidth: CGFloat = 6
    #endif

    func makeBody(configuration: Configuration) -> some View {
        ZStack {
            TotalArc().stroke(circleColor, style: StrokeStyle(lineWidth: strokeLineWidth, lineCap: .round)).widgetAccentable().opacity(0.5)
            Arc(percentage: configuration.value).stroke(circleColor, style: StrokeStyle(lineWidth: strokeLineWidth, lineCap: .round)).widgetAccentable().shadow(radius: 1)
            configuration.currentValueLabel
                #if os(watchOS)
                .frame(maxWidth: 26, maxHeight: 25)
                #else
                .frame(maxWidth: 34)
                #endif
            VStack {
                Spacer()
                configuration.label
                    #if os(watchOS)
                    .frame(width: 10, height: 10)
                    .padding(.bottom, -1.5)
                    #else
                    .frame(width: 12, height: 12)
                    .padding(.bottom, -1.5)
                    #endif
            }
            .widgetAccentable()
        }
        #if !os(watchOS)
        .frame(width: 50, height: 50)
        #else
        .frame(width: 40, height: 40)
        #endif
    }
}

struct TotalArc: Shape {
//    #if os(watchOS)
//    let startAngle: Angle = .degrees(45)
//    let endAngle: Angle = .degrees(135)
//    #else
    let startAngle: Angle = .degrees(50)
    let endAngle: Angle = .degrees(130)
//    #endif

    func path(in rect: CGRect) -> Path {
        var path = Path()
        let radius = max(rect.size.width, rect.size.height) / 2
        path.addArc(center: CGPoint(x: rect.midX, y: rect.midY),
                    radius: radius,
                    startAngle: startAngle,
                    endAngle: endAngle,
                    clockwise: true)
        return path
    }
}

struct Arc: Shape {
    let percentage: Double

    func path(in rect: CGRect) -> Path {

//        #if os(watchOS)
//        let startAngle: Angle = .degrees(45 - (1 - percentage) * 270)
//        let endAngle: Angle = .degrees(135)
//        #else
        let startAngle: Angle = .degrees(50 - (1 - percentage) * (50+130))
        let endAngle: Angle = .degrees(130)
//        #endif

        var path = Path()
        let radius = max(rect.size.width, rect.size.height) / 2
        path.addArc(center: CGPoint(x: rect.midX, y: rect.midY),
                    radius: radius,
                    startAngle: startAngle,
                    endAngle: endAngle,
                    clockwise: true)
        return path
    }
}
