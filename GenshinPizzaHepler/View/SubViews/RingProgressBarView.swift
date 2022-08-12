//
//  RingProgressBarView.swift
//  GenshinPizzaHelper
//
//  Created by Bill Haku on 2022/8/12.
//

import SwiftUI

struct RingProgressBar: View {
    var thickness: CGFloat = 2
    var width: CGFloat = 15
    var startAngle = -90.0
    @Binding var progress: CGFloat

    var body: some View {
        ZStack {
            Circle()
                .stroke(Color(.systemGray6), lineWidth: thickness)

            RingShape(progress: progress, thickness: thickness, startAngle: startAngle)
                .fill(AngularGradient(gradient: Gradient(colors: ColorHandler(colorName: .yellow).colors), center: .center, startAngle: .degrees(startAngle), endAngle: .degrees(360 * 0.3 + startAngle)))
        }
        .frame(width: width, height: width, alignment: .center)
        .animation(Animation.easeInOut(duration: 1.0), value: progress)
    }
}

private struct RingShape: Shape {

    var progress: Double
    var thickness: CGFloat
    var startAngle: Double

    var animatableData: Double {
        get { progress }
        set { progress = newValue }
    }

    func path(in rect: CGRect) -> Path {

        var path = Path()

        path.addArc(center: CGPoint(x: rect.width / 2.0, y: rect.height / 2.0), radius: min(rect.width, rect.height) / 2.0,startAngle: .degrees(startAngle),endAngle: .degrees(360 * progress + startAngle), clockwise: false)

        return path.strokedPath(.init(lineWidth: thickness, lineCap: .round))
    }
}
