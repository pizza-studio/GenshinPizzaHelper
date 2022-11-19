//
//  ResinRecoveryActivityWidget.swift
//  GenshinPizzaHelper
//
//  Created by 戴藏龙 on 2022/11/19.
//

import Foundation
import WidgetKit
import SwiftUI

@available(iOS 16.1, *)
struct ResinRecoveryActivityWidget: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: ResinRecoveryAttributes.self) { context in
            ResinRecoveryActivityWidgetLockScreenView(context: context)
        } dynamicIsland: { context in
            DynamicIsland {
                DynamicIslandExpandedRegion(.leading) {
                    Text(timerInterval: Date()...context.state.nextResinRecoveryTime, countsDown: true)
                }
                DynamicIslandExpandedRegion(.trailing) {
                    Text(timerInterval: Date()...context.state.nextResinRecoveryTime, countsDown: true)
                }
                DynamicIslandExpandedRegion(.center) {
                    Text(timerInterval: Date()...context.state.nextResinRecoveryTime, countsDown: true)
                }
                DynamicIslandExpandedRegion(.bottom) {
                    Text(timerInterval: Date()...context.state.nextResinRecoveryTime, countsDown: true)
                }
            } compactLeading: {
                Text(timerInterval: Date()...context.state.nextResinRecoveryTime, countsDown: true)
            } compactTrailing: {
                Text(timerInterval: Date()...context.state.nextResinRecoveryTime, countsDown: true)
            } minimal: {
                Text(timerInterval: Date()...context.state.nextResinRecoveryTime, countsDown: true)
            }

        }

    }
}

@available(iOS 16.1, *)
struct ResinRecoveryActivityWidgetLockScreenView: View {
    let context: ActivityViewContext<ResinRecoveryAttributes>

    var body: some View {
        VStack {
            Text(context.attributes.accountName)
            Text("\(context.state.nextResinRecoveryTimeInterval)")
        }
    }
}
