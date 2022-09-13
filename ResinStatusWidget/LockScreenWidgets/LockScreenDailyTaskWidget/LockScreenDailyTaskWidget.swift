//
//  LockScreenDailyTaskWidget.swift
//  GenshinPizzaHepler
//
//  Created by 戴藏龙 on 2022/9/12.
//

import SwiftUI
import WidgetKit

@available(iOSApplicationExtension 16.0, *)
struct LockScreenDailyTaskWidget: Widget {
    let kind: String = "LockScreenDailyTaskWidget"

    var body: some WidgetConfiguration {
        IntentConfiguration(kind: kind, intent: SelectOnlyAccountIntent.self, provider: LockScreenDailyTaskWidgetProvider()) { entry in
            LockScreenDailyTaskWidgetView(entry: entry)
        }
        .configurationDisplayName("每日任务")
        .description("每日任务完成情况")
        #if os(watchOS)
//        .supportedFamilies([.accessoryCircular, .accessoryCorner])
        .supportedFamilies([.accessoryCircular])
        #else
        .supportedFamilies([.accessoryCircular])
        #endif
    }
}

@available (iOS 16.0, *)
struct LockScreenDailyTaskWidgetView: View {
    @Environment(\.widgetFamily) var family: WidgetFamily
    let entry: LockScreenHomeCoinWidgetProvider.Entry
    var result: FetchResult { entry.result }
//    let result: FetchResult = .defaultFetchResult
    var accountName: String? { entry.accountName }

    var body: some View {
        switch family {
//        case .accessoryCorner:
//            LockScreenDailyTaskWidgetCorner(result: result)
        case .accessoryCircular:
            LockScreenDailyTaskWidgetCircular(result: result)
        default:
            EmptyView()
        }
    }
}
