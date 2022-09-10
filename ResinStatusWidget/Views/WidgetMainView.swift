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
                        .scaledToFit()
                } currentValueLabel: {
                    Text("\(userData.resinInfo.currentResin)")
                }
                #if os(watchOS)
                .gaugeStyle(.circular)
                #else
                .gaugeStyle(.accessoryCircular)
                #endif
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

