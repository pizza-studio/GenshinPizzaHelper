//
//  WidgetsBoundle.swift
//  GenshinPizzaHelper
//
//  Created by 戴藏龙 on 2022/9/10.
//

import SwiftUI
import WidgetKit

// MARK: - WidgetsBundleiOS16

@available(iOSApplicationExtension 16.0, watchOSApplicationExtension 9.0, *)
struct WidgetsBundleiOS16: WidgetBundle {
    var body: some Widget {
        #if canImport(ActivityKit)
        if #available(iOS 16.1, *) {
            ResinRecoveryActivityWidget()
        }
        #endif
        #if !os(watchOS)
        MainWidget()
        MaterialWidget()
        #endif
        LockScreenResinWidget()
        LockScreenLoopWidget()
        LockScreenAllInfoWidget()
        LockScreenResinTimerWidget()
        LockScreenResinFullTimeWidget()
        LockScreenHomeCoinWidget()
        LockScreenDailyTaskWidget()
        LockScreenExpeditionWidget()
        AlternativeLockScreenResinWidget()
    }
}
