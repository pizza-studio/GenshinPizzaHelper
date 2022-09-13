//
//  LockScreenDailyTaskWidget.swift
//  GenshinPizzaHepler
//
//  Created by 戴藏龙 on 2022/9/12.
//

import SwiftUI
import WidgetKit

@available(iOSApplicationExtension 16.0, *)
struct LockScreenLoopWidget: Widget {
    let kind: String = "LockScreenLoopWidget"

    var body: some WidgetConfiguration {
        IntentConfiguration(kind: kind, intent: SelectOnlyAccountIntent.self, provider: LockScreenLoopWidgetProvider()) { entry in
            LockScreenLoopWidgetView(entry: entry)
        }
        .configurationDisplayName("自动轮换")
        .description("自动展示你最需要的信息")
        .supportedFamilies([.accessoryCircular])
    }
}

@available (iOS 16.0, *)
struct LockScreenLoopWidgetView: View {
    @Environment(\.widgetFamily) var family: WidgetFamily
    let entry: LockScreenHomeCoinWidgetProvider.Entry
    var result: FetchResult { entry.result }
    var accountName: String? { entry.accountName }

    var body: some View {
        LockScreenLoopWidgetCircular(result: result)
    }
}
