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
        IntentConfiguration(kind: kind, intent: SelectOnlyAccountIntent.self, provider: LockScreenResinWidgetProvider()) { entry in
            LockScreenResinWidgetView(entry: entry)
        }
        .configurationDisplayName("树脂")
        .description("树脂回复状态")
        #if os(watchOS)
        .supportedFamilies([.accessoryCircular, .accessoryInline, .accessoryRectangular, .accessoryCorner])
        #else
        .supportedFamilies([.accessoryCircular, .accessoryInline, .accessoryRectangular])
        #endif
    }
}

@available (iOS 16.0, *)
struct LockScreenResinWidgetView: View {
    @Environment(\.widgetFamily) var family: WidgetFamily
    let entry: LockScreenResinWidgetProvider.Entry
    var result: FetchResult { entry.result }
//    let result: FetchResult = .defaultFetchResult
    var accountName: String? { entry.accountName }

    var body: some View {
        switch family {
        case .accessoryCorner:
            LockScreenResinWidgetCorner(result: result)
        case .accessoryCircular:
            LockScreenResinWidgetCircular(result: result)
//            case .accessoryRectangular:
//                <#code#>
        case .accessoryInline:
            LockScreenResinWidgetInline(result: result)
        default:
            EmptyView()
        }
    }
}
