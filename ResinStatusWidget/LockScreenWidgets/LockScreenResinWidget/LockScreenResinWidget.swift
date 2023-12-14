//
//  LockScreenWidget.swift
//  GenshinPizzaHepler
//
//  Created by 戴藏龙 on 2022/9/10.
//

import Foundation

import HoYoKit
import SwiftUI
import WidgetKit

// MARK: - LockScreenResinWidget

@available(iOSApplicationExtension 16.0, *)
struct LockScreenResinWidget: Widget {
    let kind: String = "LockScreenResinWidget"

    var body: some WidgetConfiguration {
        IntentConfiguration(
            kind: kind,
            intent: SelectOnlyAccountIntent.self,
            provider: LockScreenWidgetProvider(recommendationsTag: "watch.info.resin")
        ) { entry in
            LockScreenResinWidgetView(entry: entry)
                .lockscreenContainerBackground { EmptyView() }
        }
        .configurationDisplayName("app.dailynote.card.resin.label")
        .description("widget.intro.resin")
        #if os(watchOS)
            .supportedFamilies([
                .accessoryCircular,
                .accessoryInline,
                .accessoryRectangular,
                .accessoryCorner,
            ])
        #else
            .supportedFamilies([
                .accessoryCircular,
                .accessoryInline,
                .accessoryRectangular,
            ])
        #endif
    }
}

// MARK: - LockScreenResinWidgetView

@available(iOS 16.0, *)
struct LockScreenResinWidgetView: View {
    @Environment(\.widgetFamily)
    var family: WidgetFamily
    let entry: LockScreenWidgetProvider.Entry
    var body: some View {
        Group {
            switch family {
            #if os(watchOS)
            case .accessoryCorner:
                LockScreenResinWidgetCorner(entry: entry, result: result)
            #endif
            case .accessoryCircular:
                LockScreenResinWidgetCircular(entry: entry, result: result)
            case .accessoryRectangular:
                LockScreenResinWidgetRectangular(entry: entry, result: result)
            case .accessoryInline:
                LockScreenResinWidgetInline(entry: entry, result: result)
            default:
                EmptyView()
            }
        }
        .widgetURL(url)
    }

    var result: Result<any DailyNote, any Error> { entry.result }
//    let result: FetchResult = .defaultFetchResult
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
