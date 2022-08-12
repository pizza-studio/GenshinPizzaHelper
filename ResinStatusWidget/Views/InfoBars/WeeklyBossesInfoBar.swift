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
        weeklyBossesInfo.isComplete ? Image(systemName: "checkmark.circle") : Image(systemName: "questionmark.circle")
    }
    
    var body: some View {
        
        
        HStack(alignment: .center ,spacing: 8) {
            Image("参量质变仪")
                .resizable()
                .scaledToFit()
                .frame(width: 25)
                .shadow(color: .white, radius: 1)
            isWeeklyBossesFinishedImage
                .foregroundColor(Color("textColor3"))
                .font(.system(size: 14))
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
