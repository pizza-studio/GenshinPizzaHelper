//
//  LockScreenHomeCoinWidgetCircular.swift
//  GenshinPizzaHelper
//
//  Created by 戴藏龙 on 2022/9/11.
//

import SwiftUI

@available(iOSApplicationExtension 16.0, *)
struct LockScreenLoopWidgetCircular: View {
    @Environment(\.widgetRenderingMode) var widgetRenderingMode

    let result: FetchResult

    var body: some View {
        switch type {
        case .resin:
            AlternativeLockScreenResinWidgetCircular(result: result)
        case .dailyTask:
            LockScreenDailyTaskWidgetCircular(result: result)
        case .expedition:
            LockScreenExpeditionWidgetCircular(result: result)
        case .homeCoin:
            LockScreenHomeCoinWidgetCircular(result: result)
        }
    }

    var type: WidgetType {
        var isTimePast8PM: Bool {
            Date() > Calendar.current.date(bySettingHour: 20, minute: 0, second: 0, of: Date())!
        }
        switch result {
        case .success(let data):
            if data.resinInfo.currentResin > 150 {
                return .resin
            } else if data.homeCoinInfo.recoveryTime.second < 60*60 {
                return .homeCoin
            } else if data.expeditionInfo.allCompleted {
                return .expedition
            } else if (!data.dailyTaskInfo.isTaskRewardReceived) && isTimePast8PM {
                return .dailyTask
            } else {
                return .resin
            }
        case .failure(_) :
            return .resin
        }
    }

    enum WidgetType {
        case resin
        case expedition
        case dailyTask
        case homeCoin
    }
}

