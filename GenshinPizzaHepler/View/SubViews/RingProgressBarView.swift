//
//  RingProgressBarView.swift
//  GenshinPizzaHelper
//
//  Created by Bill Haku on 2022/8/12.
//  圆形进度条View

import SwiftUI

// MARK: - RingShape

struct RingShape: Shape {
    var progress: Double
    var thickness: CGFloat
    var startAngle: Double

    var animatableData: Double {
        get { progress }
        set { progress = newValue }
    }

    func path(in rect: CGRect) -> Path {
        var path = Path()

        path.addArc(
            center: CGPoint(x: rect.width / 2.0, y: rect.height / 2.0),
            radius: min(rect.width, rect.height) / 2.0,
            startAngle: .degrees(startAngle),
            endAngle: .degrees(360 * progress + startAngle),
            clockwise: false
        )

        return path.strokedPath(.init(lineWidth: thickness, lineCap: .round))
    }
}

// MARK: - OverlayRingProgressBar

struct OverlayRingProgressBar: ViewModifier {
    let progress: Double
    let thickness: CGFloat
    let startAngle: Double
    let showBackground: Bool
    let backgroundOpacity: Double
    let scaler: Double
    let offset: (x: Double, y: Double)

    func body(content: Content) -> some View {
        GeometryReader { g in

            // 圆内接正方形变长
            let r = g.size.width - 0.8
            let frameWidth = max(1, (sqrt(2) / 2 * r) * scaler)

            ZStack {
                if showBackground {
                    Circle()
                        .stroke(lineWidth: thickness)
                        .opacity(backgroundOpacity)
                }

                RingShape(
                    progress: Double(progress),
                    thickness: thickness,
                    startAngle: -90
                )

                content
                    .offset(x: offset.x, y: offset.y)
                    .frame(width: frameWidth, height: frameWidth)
            }
        }
    }
}

extension View {
    func overlayRingProgressBar(
        _ progress: Double,
        thickness: CGFloat = 1.0,
        startAngle: Double = -90,
        showBackground: Bool = true,
        backgroundOpacity: Double = 0.5,
        scaler: Double = 0.83,
        offset: (x: Double, y: Double) = (0, 0)
    )
        -> some View {
        modifier(OverlayRingProgressBar(
            progress: progress,
            thickness: thickness,
            startAngle: startAngle,
            showBackground: showBackground,
            backgroundOpacity: backgroundOpacity,
            scaler: scaler,
            offset: offset
        ))
    }
}

extension Image {
    func overlayImageWithRingProgressBar(
        _ progress: Double,
        thickness: CGFloat = 1.0,
        startAngle: Double = -90,
        showBackground: Bool = true,
        backgroundOpacity: Double = 0.5,
        scaler: Double = 0.83,
        offset: (x: Double, y: Double) = (0, 0)
    )
        -> some View {
        resizable()
            .scaledToFit()
            .font(Font.title.bold())
            .overlayRingProgressBar(
                progress,
                thickness: thickness,
                startAngle: startAngle,
                showBackground: showBackground,
                backgroundOpacity: backgroundOpacity,
                scaler: scaler,
                offset: offset
            )
    }
}
