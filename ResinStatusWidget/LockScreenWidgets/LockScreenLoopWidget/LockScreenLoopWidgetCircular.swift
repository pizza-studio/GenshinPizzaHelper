//
//  LockScreenHomeCoinWidgetCircular.swift
//  GenshinPizzaHelper
//
//  Created by 戴藏龙 on 2022/9/11.
//

import HoYoKit
import SwiftUI
import WidgetKit

// MARK: - LockScreenLoopWidgetCircular

@available(iOSApplicationExtension 16.0, *)
struct LockScreenLoopWidgetCircular: View {
    let entry: any TimelineEntry
    @Environment(\.widgetRenderingMode)
    var widgetRenderingMode
    let result: Result<any DailyNote, any Error>

    let showWeeklyBosses: Bool
    let showTransformer: Bool

    let resinStyle: AutoRotationUsingResinWidgetStyle

    var body: some View {
        switch LockScreenLoopWidgetType.autoChoose(entry: entry, result: result) {
        case .resin:
            switch resinStyle {
            case .default_, .unknown:
                AlternativeLockScreenResinWidgetCircular(entry: entry, result: result)
            case .timer:
                LockScreenResinTimerWidgetCircular(entry: entry, result: result)
            case .time:
                LockScreenResinFullTimeWidgetCircular(entry: entry, result: result)
            case .circle:
                LockScreenResinWidgetCircular(entry: entry, result: result)
            }
        case .dailyTask:
            LockScreenDailyTaskWidgetCircular(result: result)
        case .expedition:
            LockScreenExpeditionWidgetCircular(result: result)
        case .homeCoin:
            LockScreenHomeCoinWidgetCircular(entry: entry, result: result)
        }
    }
}
