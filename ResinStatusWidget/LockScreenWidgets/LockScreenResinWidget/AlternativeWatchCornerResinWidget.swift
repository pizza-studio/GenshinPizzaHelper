//
//  AlternativeWatchCornerResinWidget.swift
//  GenshinPizzaHelper
//
//  Created by 戴藏龙 on 2022/9/12.
//

import HoYoKit
import SwiftUI
import WidgetKit

// MARK: - AlternativeWatchCornerResinWidget

@available(iOSApplicationExtension 16.0, *)
struct AlternativeWatchCornerResinWidget: Widget {
    let kind: String = "AlternativeWatchCornerResinWidget"

    var body: some WidgetConfiguration {
        IntentConfiguration(
            kind: kind,
            intent: SelectOnlyAccountIntent.self,
            provider: LockScreenWidgetProvider(recommendationsTag: "的原粹树脂")
        ) { entry in
            AlternativeWatchCornerResinWidgetView(entry: entry)
        }
        .configurationDisplayName("树脂")
        .description("树脂回复状态")
        #if os(watchOS)
            .supportedFamilies([.accessoryCorner])
        #endif
    }
}

// MARK: - AlternativeWatchCornerResinWidgetView

@available(iOS 16.0, *)
struct AlternativeWatchCornerResinWidgetView: View {
    @Environment(\.widgetFamily)
    var family: WidgetFamily
    let entry: LockScreenWidgetProvider.Entry

    var result: Result<any DailyNote, any Error> { entry.result }
    var accountName: String? { entry.accountName }

    var body: some View {
        switch result {
        case let .success(data):
            resinView(resinInfo: data.resinInformation)
        case .failure:
            failureView()
        }
    }

    @ViewBuilder
    func resinView(resinInfo: ResinInformation) -> some View {
        Image("icon.resin")
            .resizable()
            .scaledToFit()
            .padding(4)
            .widgetLabel {
                Gauge(
                    value: Double(resinInfo.calculatedCurrentResin),
                    in: 0 ... Double(resinInfo.maxResin)
                ) {
                    Text("app.dailynote.card.resin.label")
                } currentValueLabel: {
                    Text("\(resinInfo.calculatedCurrentResin)")
                } minimumValueLabel: {
                    Text("\(resinInfo.calculatedCurrentResin)")
                } maximumValueLabel: {
                    Text("")
                }
            }
    }

    @ViewBuilder
    func failureView() -> some View {
        Image("icon.resin")
            .resizable()
            .scaledToFit()
            .padding(6)
            .widgetLabel {
                Gauge(value: 0, in: 0 ... 160) {
                    Text("0")
                }
            }
    }
}
