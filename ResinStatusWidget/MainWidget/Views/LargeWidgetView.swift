//
//  LargeWidgetView.swift
//  GenshinPizzaHelper
//
//  Created by 戴藏龙 on 2022/8/23.
//  大号Widget布局View

import HoYoKit
import SFSafeSymbols
import SwiftUI
import WidgetKit

// MARK: - LargeWidgetView

struct LargeWidgetView: View {
    let entry: any TimelineEntry
    var dailyNote: any DailyNote
    let viewConfig: WidgetViewConfiguration
    let accountName: String?

    var body: some View {
        VStack {
            Spacer()
            HStack {
                Spacer()
                VStack(alignment: .leading) {
                    mainInfo()
                    Spacer(minLength: 18)
                    detailInfo()
                }

                Spacer(minLength: 30)
                VStack(alignment: .leading) {
                    ExpeditionsView(
                        expeditions: dailyNote.expeditionInformation.expeditions
                    )
                    if viewConfig.showMaterialsInLargeSizeWidget {
                        Spacer(minLength: 15)
                        MaterialView()
                    }
                }
                .frame(maxWidth: UIScreen.main.bounds.width / 8 * 3)
                Spacer()
            }
            Spacer()
        }
        .padding()
    }

    @ViewBuilder
    func mainInfo() -> some View {
        VStack(alignment: .leading, spacing: 5) {
//            Spacer()
            if let accountName = accountName {
                HStack(alignment: .lastTextBaseline, spacing: 2) {
                    Image(systemSymbol: .personFill)
                    Text(accountName)
                }
                .font(.footnote)
                .foregroundColor(Color("textColor3"))
            }
            HStack(alignment: .firstTextBaseline, spacing: 2) {
                Text("\(dailyNote.resinInformation.calculatedCurrentResin(referTo: entry.date))")
                    .font(.system(size: 50, design: .rounded))
                    .fontWeight(.medium)
                    .minimumScaleFactor(0.1)
                    .foregroundColor(Color("textColor3"))
                    .shadow(radius: 1)
                Image("树脂")
                    .resizable()
                    .scaledToFit()
                    .frame(maxHeight: 30)
                    .alignmentGuide(.firstTextBaseline) { context in
                        context[.bottom] - 0.17 * context.height
                    }
                    .shadow(radius: 0.8)
            }
            HStack {
                Image("hourglass.circle")
                    .foregroundColor(Color("textColor3"))
                    .font(.title3)
                RecoveryTimeText(entry: entry, resinInfo: dailyNote.resinInformation)
            }
        }
    }

    @ViewBuilder
    func detailInfo() -> some View {
        VStack(alignment: .leading, spacing: 17) {
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
