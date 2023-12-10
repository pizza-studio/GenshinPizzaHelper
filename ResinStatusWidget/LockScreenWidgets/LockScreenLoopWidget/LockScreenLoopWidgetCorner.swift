//
//  LockScreenLoopWidgetCorner.swift
//  GenshinPizzaHelper
//
//  Created by 戴藏龙 on 2022/9/14.
//

import HoYoKit
import SwiftUI
import WidgetKit

@available(iOSApplicationExtension 16.0, *)
struct LockScreenLoopWidgetCorner: View {
    let entry: any TimelineEntry
    @Environment(\.widgetRenderingMode)
    var widgetRenderingMode

    let result: Result<any DailyNote, any Error>

    var body: some View {
        switch LockScreenLoopWidgetType.autoChoose(entry: entry, result: result) {
        case .resin:
            LockScreenResinWidgetCorner(entry: entry, result: result)
        case .dailyTask:
            LockScreenDailyTaskWidgetCorner(result: result)
        case .expedition:
            LockScreenExpeditionWidgetCorner(result: result)
        case .homeCoin:
            LockScreenHomeCoinWidgetCorner(entry: entry, result: result)
        }
    }
}
