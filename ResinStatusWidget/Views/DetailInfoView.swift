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

    var body: some View {

        VStack(alignment: .leading, spacing: 13) {
            HomeCoinInfoBar(homeCoinInfo: userData.homeCoinInfo)
            ExpeditionInfoBar(expeditionInfo: userData.expeditionInfo)
            DailyTaskInfoBar(dailyTaskInfo: userData.dailyTaskInfo)
            TransformerInfoBar(transformerInfo: userData.transformerInfo)
        }
        .padding(.trailing)
    }
}
