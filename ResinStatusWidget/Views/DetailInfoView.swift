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
        let currentHomeCoin: Int = userData.currentHomeCoin
        let currentExpeditionNum: Int = userData.currentExpeditionNum
        let finishedTaskNum: Int = userData.finishedTaskNum
        let transformerTimeSecondInt: Int = userData.transformerInfo.recoveryTime.second

        let isExpeditionAllComplete: Image = (currentExpeditionNum == 0) ? Image(systemName: "exclamationmark.circle") : Image(systemName: "clock.arrow.circlepath")
        let isDailyTaskAllComplete: Image = (finishedTaskNum == 4) ? Image(systemName: "checkmark.circle") : Image(systemName: "questionmark.circle")
        let isTransformerComplete: Image = (transformerTimeSecondInt == 0) ? Image(systemName: "exclamationmark.circle") : Image(systemName: "hourglass.circle")
        let isHomeCoinFull: Image = (currentHomeCoin == 2400) ? Image(systemName: "exclamationmark.circle") : Image(systemName: "leaf.arrow.triangle.circlepath")

        VStack(alignment: .leading, spacing: 13) {
            Group {
                HStack(alignment: .center ,spacing: 8) {
                    Image("洞天宝钱")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 25)
                        .shadow(color: .white, radius: 1)
                    isHomeCoinFull
                        .foregroundColor(Color("textColor3"))
                        .font(.system(size: 14))
                    HStack(alignment: .lastTextBaseline, spacing:1) {
                        Text("\(currentHomeCoin)")
                            .foregroundColor(Color("textColor3"))
                            .font(.system(.body, design: .rounded))
                            .minimumScaleFactor(0.2)
                    }
                }

                HStack(alignment: .center ,spacing: 8) {
                    Image("派遣探索")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 25)
                        .shadow(color: .white, radius: 1)
                    isExpeditionAllComplete
                        .foregroundColor(Color("textColor3"))
                        .font(.system(size: 14))
                    HStack(alignment: .lastTextBaseline, spacing:1) {
                        Text("\(currentExpeditionNum)")
                            .foregroundColor(Color("textColor3"))
                            .font(.system(.body, design: .rounded))
                            .minimumScaleFactor(0.2)
                        Text(" / 5")
                            .foregroundColor(Color("textColor3"))
                            .font(.system(.caption, design: .rounded))
                            .minimumScaleFactor(0.2)
                    }
                }

                HStack(alignment: .center ,spacing: 8) {
                    Image("每日任务")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 25)
                        .shadow(color: .white, radius: 1)
                    isDailyTaskAllComplete
                        .foregroundColor(Color("textColor3"))
                        .font(.system(size: 14))
                    HStack(alignment: .lastTextBaseline, spacing:1) {
                        Text("\(finishedTaskNum)")
                            .foregroundColor(Color("textColor3"))
                            .font(.system(.body, design: .rounded))
                            .minimumScaleFactor(0.2)
                        Text(" / 4")
                            .foregroundColor(Color("textColor3"))
                            .font(.system(.caption, design: .rounded))
                            .minimumScaleFactor(0.2)
                    }
                }
                HStack(alignment: .center ,spacing: 8) {
                    Image("参量质变仪")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 25)
                        .shadow(color: .white, radius: 1)
                    isTransformerComplete
                        .foregroundColor(Color("textColor3"))
                        .font(.system(size: 14))
                    HStack(alignment: .lastTextBaseline, spacing:1) {
                        Text("\(secondsToHrOrDay(transformerTimeSecondInt))")
                            .foregroundColor(Color("textColor3"))
                            .font(.system(.body, design: .rounded))
                            .minimumScaleFactor(0.2)
                    }
                }
            }
        }
        .padding(.trailing)
    }
}
