//
//  WeeklyBossesBar.swift
//  GenshinPizzaHelper
//
//  Created by 戴藏龙 on 2022/8/12.
//

import SwiftUI

struct WeeklyBossesInfoBar: View {
    let weeklyBossesInfo: WeeklyBossesInfo
    
    var isWeeklyBossesFinishedImage: Image {
        weeklyBossesInfo.isComplete ? Image(systemName: "checkmark") : Image(systemName: "questionmark")
    }
    
    var body: some View {
        
        
        HStack(alignment: .center ,spacing: 8) {
            Image("北陆单手剑原胚")
                .resizable()
                .scaledToFit()
                .frame(width: 25)
                .shadow(color: .white, radius: 1)
            isWeeklyBossesFinishedImage
                .overlayImageWithRingProgressBar(1.0)
                .frame(width: 13, height: 13)
                .foregroundColor(Color("textColor3"))
            HStack(alignment: .lastTextBaseline, spacing:1) {
                Text("\(weeklyBossesInfo.remainResinDiscountNum)")
                    .foregroundColor(Color("textColor3"))
                    .font(.system(.body, design: .rounded))
                    .minimumScaleFactor(0.2)
                Text(" / \(weeklyBossesInfo.resinDiscountNumLimit)")
                    .foregroundColor(Color("textColor3"))
                    .font(.system(.caption, design: .rounded))
                    .minimumScaleFactor(0.2)
            }
        }
    }
}
