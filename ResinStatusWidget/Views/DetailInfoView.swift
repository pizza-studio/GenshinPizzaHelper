//
//  DetailInfoView.swift
//  ResinStatusWidgetExtension
//
//  Created by Bill Haku on 2022/8/6.
//

import Foundation
import SwiftUI

struct DetailInfo: View {
    let userData: UserData
    let viewConfig: WidgetViewConfiguration

    var body: some View {

        VStack(alignment: .leading, spacing: 13) {
            
            HomeCoinInfoBar(homeCoinInfo: userData.homeCoinInfo)
            
            DailyTaskInfoBar(dailyTaskInfo: userData.dailyTaskInfo)
            
            ExpeditionInfoBar(expeditionInfo: userData.expeditionInfo, expeditionViewConfig: viewConfig.expeditionViewConfig)
            
            if !userData.weeklyBossesInfo.isComplete {
                WeeklyBossesInfoBar(weeklyBossesInfo: userData.weeklyBossesInfo)
            } else {
                if userData.transformerInfo.obtained && viewConfig.showTransformer {
                    TransformerInfoBar(transformerInfo: userData.transformerInfo)
                }
            }
        }
        .padding(.trailing)
    }
}
