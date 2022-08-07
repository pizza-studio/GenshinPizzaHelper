//
//  ExpeditionInfoBar.swift
//  GenshinPizzaHepler
//
//  Created by 戴藏龙 on 2022/8/7.
//

import SwiftUI

struct ExpeditionInfoBar: View {
    let expeditionInfo: ExpeditionInfo
    
    var isExpeditionAllCompleteImage: Image {
        expeditionInfo.isAllCompleted ? Image(systemName: "exclamationmark.circle") : Image(systemName: "clock.arrow.circlepath")
    }
    
    var body: some View {
        HStack(alignment: .center ,spacing: 8) {
            Image("派遣探索")
                .resizable()
                .scaledToFit()
                .frame(width: 25)
                .shadow(color: .white, radius: 1)
            isExpeditionAllCompleteImage
                .foregroundColor(Color("textColor3"))
                .font(.system(size: 14))
            HStack(alignment: .lastTextBaseline, spacing:1) {
                Text("\(expeditionInfo.currentOngoingTask)")
                    .foregroundColor(Color("textColor3"))
                    .font(.system(.body, design: .rounded))
                    .minimumScaleFactor(0.2)
                Text(" / 5")
                    .foregroundColor(Color("textColor3"))
                    .font(.system(.caption, design: .rounded))
                    .minimumScaleFactor(0.2)
            }
        }
    }
}

