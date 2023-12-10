//
//  WeeklyBossesBar.swift
//  GenshinPizzaHelper
//
//  Created by 戴藏龙 on 2022/8/12.
//

import HoYoKit
import SFSafeSymbols
import SwiftUI

struct WeeklyBossesInfoBar: View {
    let weeklyBossesInfo: GeneralDailyNote.WeeklyBossesInformation

    var isWeeklyBossesFinishedImage: some View {
        (weeklyBossesInfo.remainResinDiscount == weeklyBossesInfo.totalResinDiscount)
            ? Image(systemSymbol: .checkmark)
            .overlayImageWithRingProgressBar(1.0, scaler: 0.70)
            : Image(systemSymbol: .questionmark)
            .overlayImageWithRingProgressBar(1.0)
    }

    var body: some View {
        HStack(alignment: .center, spacing: 8) {
            Image("征讨领域")
                .resizable()
                .scaledToFit()
                .frame(width: 25)
                .shadow(color: .white, radius: 1)
            isWeeklyBossesFinishedImage
                .frame(width: 13, height: 13)
                .foregroundColor(Color("textColor3"))
            HStack(alignment: .lastTextBaseline, spacing: 1) {
                Text("\(weeklyBossesInfo.remainResinDiscount)")
                    .lineLimit(1)
                    .foregroundColor(Color("textColor3"))
                    .font(.system(.body, design: .rounded))
                    .minimumScaleFactor(0.2)
                Text(" / \(weeklyBossesInfo.totalResinDiscount)")
                    .lineLimit(1)
                    .foregroundColor(Color("textColor3"))
                    .font(.system(.caption, design: .rounded))
                    .minimumScaleFactor(0.2)
            }
        }
    }
}
