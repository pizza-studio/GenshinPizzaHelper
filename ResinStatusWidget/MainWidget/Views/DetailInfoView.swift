//
//  DetailInfoView.swift
//  ResinStatusWidgetExtension
//
//  Created by Bill Haku on 2022/8/6.
//  其他游戏内信息

import Foundation
import HoYoKit
import SwiftUI
import WidgetKit

// MARK: - DetailInfo

struct DetailInfo: View {
    let entry: any TimelineEntry
    let dailyNote: any DailyNote
    let viewConfig: WidgetViewConfiguration

    var body: some View {
        VStack(alignment: .leading, spacing: 13) {
            if dailyNote.homeCoinInformation.maxHomeCoin != 0 {
                HomeCoinInfoBar(entry: entry, homeCoinInfo: dailyNote.homeCoinInformation)
            }

            if dailyNote.dailyTaskInformation.totalTaskCount != 0 {
                DailyTaskInfoBar(dailyTaskInfo: dailyNote.dailyTaskInformation)
            }

            if dailyNote.expeditionInformation.maxExpeditionsCount != 0 {
                ExpeditionInfoBar(
                    expeditionInfo: dailyNote.expeditionInformation,
                    expeditionViewConfig: viewConfig.expeditionViewConfig
                )
            }

            if let dailyNote = dailyNote as? GeneralDailyNote {
                if dailyNote.transformerInformation.obtained, viewConfig.showTransformer {
                    TransformerInfoBar(transformerInfo: dailyNote.transformerInformation)
                }
                switch viewConfig.weeklyBossesShowingMethod {
                case .neverShow:
                    EmptyView()
                case .disappearAfterCompleted:
                    if dailyNote.weeklyBossesInformation.remainResinDiscount != 0 {
                        WeeklyBossesInfoBar(
                            weeklyBossesInfo: dailyNote.weeklyBossesInformation
                        )
                    }
                case .alwaysShow, .unknown:
                    WeeklyBossesInfoBar(weeklyBossesInfo: dailyNote.weeklyBossesInformation)
                }
            }
        }
        .padding(.trailing)
    }
}
