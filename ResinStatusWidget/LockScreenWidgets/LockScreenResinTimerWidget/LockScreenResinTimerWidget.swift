//
//  LockScreenResinTimerWidget.swift
//  ResinStatusWidgetExtension
//
//  Created by 戴藏龙 on 2022/11/25.
//

import HoYoKit
import SwiftUI
import WidgetKit

// MARK: - LockScreenResinTimerWidget

@available(iOSApplicationExtension 16.0, *)
struct LockScreenResinTimerWidget: Widget {
    let kind: String = "LockScreenResinTimerWidget"

    var body: some WidgetConfiguration {
        IntentConfiguration(
            kind: kind,
            intent: SelectOnlyAccountIntent.self,
            provider: LockScreenWidgetProvider(recommendationsTag: "widget.resin.refillTime.countdown.ofSb")
        ) { entry in
            LockScreenResinTimerWidgetView(entry: entry)
                .lockscreenContainerBackground { EmptyView() }
        }
        .configurationDisplayName("widget.resin.refillTime.countdown.title")
        .description("widget.resin.refillTime.countdown.show.title")
        #if os(watchOS)
            .supportedFamilies([.accessoryCircular, .accessoryCircular])
        #else
            .supportedFamilies([.accessoryCircular])
        #endif
    }
}

// MARK: - LockScreenResinTimerWidgetView

@available(iOS 16.0, *)
struct LockScreenResinTimerWidgetView: View {
    @Environment(\.widgetFamily)
    var family: WidgetFamily
    let entry: LockScreenWidgetProvider.Entry
    var body: some View {
        switch family {
        case .accessoryCircular:
            Group {
                LockScreenResinTimerWidgetCircular(entry: entry, result: result)
            }
            .widgetURL(url)
        #if os(watchOS)
        case .accessoryCorner:
            Group {
                LockScreenResinTimerWidgetCircular(entry: entry, result: result)
            }
            .widgetURL(url)
        #endif
        default:
            EmptyView()
        }
    }

    var result: Result<any DailyNote, any Error> { entry.result }
    var accountName: String? { entry.accountName }

    var url: URL? {
        let errorURL: URL = {
            var components = URLComponents()
            components.scheme = "ophelperwidget"
            components.host = "accountSetting"
            components.queryItems = [
                .init(
                    name: "accountUUIDString",
                    value: entry.accountUUIDString
                ),
            ]
            return components.url!
        }()

        switch result {
        case .success:
            return nil
        case .failure:
            return errorURL
        }
    }
}
