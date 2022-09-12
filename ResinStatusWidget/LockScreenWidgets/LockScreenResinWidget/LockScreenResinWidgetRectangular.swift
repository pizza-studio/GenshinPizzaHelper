//
//  LockScreenResinWidgetRectangular.swift
//  GenshinPizzaHelper
//
//  Created by 戴藏龙 on 2022/9/12.
//

import SwiftUI

@available(iOSApplicationExtension 16.0, *)
struct LockScreenResinWidgetRectangular: View {
    @Environment(\.widgetRenderingMode) var widgetRenderingMode

    let result: FetchResult

    var body: some View {
        switch result {
        case .success(let data):
            Grid(alignment: .leadingFirstTextBaseline, horizontalSpacing: 3, verticalSpacing: 2) {
                GridRow(alignment: .lastTextBaseline) {
                    Spacer()
                    Text("\(Image("icon.resin"))")
                    Text("\(data.resinInfo.currentResin)")
                    Spacer()
                    Text("\(Image("icon.expedition"))")
                    HStack(alignment: .lastTextBaseline, spacing: 0) {
                        Text("\(data.expeditionInfo.currentOngoingTask)")
                        Text(" / \(data.expeditionInfo.maxExpedition)")
                            .font(.caption)
                    }

                    Spacer()
                }
                GridRow(alignment: .lastTextBaseline) {
                    Spacer()
                    Text("\(Image("icon.homeCoin"))")
                    Text("\(data.homeCoinInfo.currentHomeCoin)")
                    Spacer()
                    Text("\(Image("icon.dailyTask"))")
                    HStack(alignment: .lastTextBaseline, spacing: 0) {
                        Text("\(data.dailyTaskInfo.finishedTaskNum)")
                        Text(" / \(data.dailyTaskInfo.totalTaskNum)")
                            .font(.caption)
                    }
                }
                GridRow(alignment: .lastTextBaseline) {
                    Spacer()
                    Text("\(Image("icon.transformer"))")
                    Text(data.transformerInfo.recoveryTime.describeIntervalShort(finishedTextPlaceholder: "可使用"))
                    Spacer()
                    Text("\(Image("icon.weeklyBosses"))")
                    HStack(alignment: .lastTextBaseline, spacing: 0) {
                        Text("\(data.weeklyBossesInfo.hasUsedResinDiscountNum)")
                        Text(" / \(data.weeklyBossesInfo.resinDiscountNumLimit)")
                            .font(.caption)
                    }
                    Spacer()
                }
            }
        case .failure(_):
            EmptyView()
        }
    }
}



