//
//  LockScreenHomeCoinWidget.swift
//  GenshinPizzaHepler
//
//  Created by 戴藏龙 on 2022/9/11.
//

import HoYoKit
import SwiftUI
import WidgetKit

// MARK: - LockScreenHomeCoinWidget

@available(iOSApplicationExtension 16.0, *)
struct LockScreenHomeCoinWidget: Widget {
    let kind: String = "LockScreenHomeCoinWidget"

    var body: some WidgetConfiguration {
        IntentConfiguration(
            kind: kind,
            intent: SelectOnlyAccountIntent.self,
            provider: LockScreenWidgetProvider(recommendationsTag: "watch.info.RealmCurrency")
        ) { entry in
            LockScreenHomeCoinWidgetView(entry: entry)
                .lockscreenContainerBackground { EmptyView() }
        }
        .configurationDisplayName("app.dailynote.card.homeCoin.label")
        .description("widget.intro.homeCoin")
        #if os(watchOS)
            .supportedFamilies([
                .accessoryCircular,
                .accessoryCorner,
                .accessoryRectangular,
            ])
        #else
            .supportedFamilies([.accessoryCircular, .accessoryRectangular])
        #endif
    }
}

// MARK: - LockScreenHomeCoinWidgetView

@available(iOS 16.0, *)
struct LockScreenHomeCoinWidgetView: View {
    @Environment(\.widgetFamily)
    var family: WidgetFamily
    let entry: LockScreenWidgetProvider.Entry
    var body: some View {
        Group {
            switch family {
            #if os(watchOS)
            case .accessoryCorner:
                LockScreenHomeCoinWidgetCorner(entry: entry, result: result)
            #endif
            case .accessoryCircular:
                LockScreenHomeCoinWidgetCircular(entry: entry, result: result)
            case .accessoryRectangular:
                LockScreenHomeCoinWidgetRectangular(entry: entry, result: result)
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
