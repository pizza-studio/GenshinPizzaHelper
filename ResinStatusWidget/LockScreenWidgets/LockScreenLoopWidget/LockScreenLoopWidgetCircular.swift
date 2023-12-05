//
//  LockScreenHomeCoinWidgetCircular.swift
//  GenshinPizzaHelper
//
//  Created by 戴藏龙 on 2022/9/11.
//

import HoYoKit
import SwiftUI

// MARK: - LockScreenLoopWidgetCircular

@available(iOSApplicationExtension 16.0, *)
struct LockScreenLoopWidgetCircular: View {
    @Environment(\.widgetRenderingMode)
    var widgetRenderingMode
    let result: Result<any DailyNote, any Error>

    let showWeeklyBosses: Bool
    let showTransformer: Bool

    let resinStyle: AutoRotationUsingResinWidgetStyle

    var body: some View {
        switch LockScreenLoopWidgetType.autoChoose(result: result) {
        case .resin:
            switch resinStyle {
            case .default_, .unknown:
                AlternativeLockScreenResinWidgetCircular(result: result)
            case .timer:
                LockScreenResinTimerWidgetCircular(result: result)
            case .time:
                LockScreenResinFullTimeWidgetCircular(result: result)
            case .circle:
                LockScreenResinWidgetCircular(result: result)
            }
        case .dailyTask:
            LockScreenDailyTaskWidgetCircular(result: result)
        case .expedition:
            LockScreenExpeditionWidgetCircular(result: result)
        case .homeCoin:
            LockScreenHomeCoinWidgetCircular(result: result)
        }
    }
}
