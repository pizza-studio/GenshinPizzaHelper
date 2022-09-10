//
//  WidgetMainView.swift
//  GenshinPizzaHepler
//
//  Created by 戴藏龙 on 2022/8/7.
//  Widget总体布局分类

import SwiftUI
import WidgetKit

struct WidgetMainView: View {
    @Environment(\.widgetFamily) var family: WidgetFamily
    var userData: UserData
    let viewConfig: WidgetViewConfiguration
    let accountName: String?
    
    var body: some View {
        if #available(iOSApplicationExtension 16.0, *) {
            switch family {
            case .systemSmall:
                MainInfo(userData: userData, viewConfig: viewConfig, accountName: viewConfig.showAccountName ? accountName : nil)
                    .padding()
            case .systemMedium:
                MainInfoWithDetail(userData: userData, viewConfig: viewConfig, accountName: viewConfig.showAccountName ? accountName : nil)
            case .systemLarge:
                LargeWidgetView(userData: userData, viewConfig: viewConfig, accountName: viewConfig.showAccountName ? accountName : nil)
            case .accessoryCircular:
                Gauge(value: Double(userData.resinInfo.currentResin) / Double(160)) {
                    Image("树脂")
                        .resizable()
                        .frame(width: 15, height: 15)
                        .scaledToFit()
                } currentValueLabel: {
                    Text("\(userData.resinInfo.currentResin)")
                        .font(.system(.title3, design: .rounded))
                }
                .gaugeStyle(ProgressGaugeStyle())
            default:
                MainInfoWithDetail(userData: userData, viewConfig: viewConfig, accountName: viewConfig.showAccountName ? accountName : nil)
            }
        } else {
            // Fallback on earlier versions
            switch family {
            case .systemSmall:
                MainInfo(userData: userData, viewConfig: viewConfig, accountName: viewConfig.showAccountName ? accountName : nil)
                    .padding()
            case .systemMedium:
                MainInfoWithDetail(userData: userData, viewConfig: viewConfig, accountName: viewConfig.showAccountName ? accountName : nil)
            case .systemLarge:
                LargeWidgetView(userData: userData, viewConfig: viewConfig, accountName: viewConfig.showAccountName ? accountName : nil)
            default:
                MainInfoWithDetail(userData: userData, viewConfig: viewConfig, accountName: viewConfig.showAccountName ? accountName : nil)
            }
        }
    }
}

@available(iOS 16.0, *)
struct ProgressGaugeStyle: GaugeStyle {
    func makeBody(configuration: Configuration) -> some View {
        ZStack {
            TotalArc().stroke(Color.indigo, style: StrokeStyle(lineWidth: 6, lineCap: .round)).opacity(0.5)
            Arc(percentage: configuration.value).stroke(Color.white, style: StrokeStyle(lineWidth: 6, lineCap: .round)).shadow(radius: 1)
            configuration.currentValueLabel
            VStack {
                Spacer()
                configuration.label
                    .padding(.bottom, -5)
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
