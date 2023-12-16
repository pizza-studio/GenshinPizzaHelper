//
//  ExpeditionInfoBar.swift
//  GenshinPizzaHepler
//
//  Created by 戴藏龙 on 2022/8/7.
//

import HoYoKit
import SFSafeSymbols
import SwiftUI

struct ExpeditionInfoBar: View {
    let expeditionInfo: any ExpeditionInformation

    var isExpeditionAllCompleteImage: some View {
        Image(systemSymbol: .figureWalk)
            .overlayImageWithRingProgressBar(
                1,
                scaler: 1,
                offset: (0.3, 0)
            )
    }

    var body: some View {
        HStack(alignment: .center, spacing: 8) {
            Image("派遣探索")
                .resizable()
                .scaledToFit()
                .frame(width: 25)
                .shadow(color: .white, radius: 1)
            isExpeditionAllCompleteImage

                .frame(maxWidth: 13, maxHeight: 13)
                .foregroundColor(Color("textColor3"))

            HStack(alignment: .lastTextBaseline, spacing: 1) {
                Text("\(expeditionInfo.ongoingExpeditionCount)")
                    .lineLimit(1)
                    .foregroundColor(Color("textColor3"))
                    .font(.system(.body, design: .rounded))
                    .minimumScaleFactor(0.2)
                Text(" / \(expeditionInfo.maxExpeditionsCount)")
                    .lineLimit(1)
                    .foregroundColor(Color("textColor3"))
                    .font(.system(.caption, design: .rounded))
                    .minimumScaleFactor(0.2)
            }
        }
    }
}
