//
//  LockScreenWidget.swift
//  GenshinPizzaHepler
//
//  Created by 戴藏龙 on 2022/9/10.
//

import Foundation

import WidgetKit
import SwiftUI

@available(iOSApplicationExtension 16.0, *)
struct LockScreenResinWidget: Widget {
    let kind: String = "LockScreenResinWidget"

    var body: some WidgetConfiguration {
        IntentConfiguration(kind: kind, intent: SelectOnlyAccountIntent.self, provider: LockScreenWidgetProvider()) { entry in
            LockScreenWidgetView(entry: entry)
        }
        .configurationDisplayName("原神状态")
        .description("查询树脂恢复状态")
        .supportedFamilies([.accessoryCircular, .accessoryInline, .accessoryRectangular])
    }
}

@available (iOS 16.0, *)
struct LockScreenWidgetView: View {
    @Environment(\.widgetFamily) var family: WidgetFamily
    let entry: LockScreenWidgetProvider.Entry
    var result: FetchResult { entry.result }
    var accountName: String? { entry.accountName }

    @ViewBuilder
    var body: some View {
        switch result {
        case .success(let data):
            Gauge(value: Double(data.resinInfo.currentResin) / Double(160)) {
                Image("树脂")
                    .resizable()
                    .frame(width: 15, height: 15)
                    .scaledToFit()
            } currentValueLabel: {
                Text("\(data.resinInfo.currentResin)")
                    .font(.system(.title3, design: .rounded))
                    .minimumScaleFactor(0.4)
            }
            .gaugeStyle(ProgressGaugeStyle())
        case .failure(_):
            Image(systemName: "exclamationmark.circle")
        }
    }
}
