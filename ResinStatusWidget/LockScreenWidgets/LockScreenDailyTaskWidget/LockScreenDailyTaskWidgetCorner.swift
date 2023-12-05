//
//  LockScreenHomeCoinWidgetCorner.swift
//  GenshinPizzaHelper
//
//  Created by 戴藏龙 on 2022/9/12.
//

import HoYoKit
import SwiftUI

@available(iOSApplicationExtension 16.0, *)
struct LockScreenDailyTaskWidgetCorner: View {
    @Environment(\.widgetRenderingMode)
    var widgetRenderingMode

    let result: Result<any DailyNote, any Error>

    var body: some View {
        switch result {
        case let .success(data):
            Image("icon.dailyTask")
                .resizable()
                .scaledToFit()
                .padding(3.5)
                .widgetLabel {
                    Gauge(
                        value: Double(data.dailyTaskInformation.finishedTaskCount),
                        in: 0 ... Double(data.dailyTaskInformation.totalTaskCount)
                    ) {
                        Text("每日委托")
                    } currentValueLabel: {
                        Text(
                            "\(data.dailyTaskInformation.finishedTaskCount) / \(data.dailyTaskInformation.totalTaskCount)"
                        )
                    } minimumValueLabel: {
                        Text(
                            "  \(data.dailyTaskInformation.finishedTaskCount)/\(data.dailyTaskInformation.totalTaskCount)  "
                        )
                    } maximumValueLabel: {
                        Text("")
                    }
                }
        case .failure:
            Image("icon.dailyTask")
                .resizable()
                .scaledToFit()
                .padding(4.5)
                .widgetLabel("每日委托".localized)
        }
    }
}
