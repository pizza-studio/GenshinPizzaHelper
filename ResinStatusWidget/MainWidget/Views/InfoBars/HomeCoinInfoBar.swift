//
//  ResinInfoBar.swift
//  GenshinPizzaHepler
//
//  Created by 戴藏龙 on 2022/8/7.
//

import HoYoKit
import SFSafeSymbols
import SwiftUI

struct HomeCoinInfoBar: View {
    let homeCoinInfo: HomeCoinInformation

    var isHomeCoinFullImage: some View {
        homeCoinInfo.maxHomeCoin == 300
            ? Image(systemSymbol: .leafFill)
            .overlayImageWithRingProgressBar(
                Double(homeCoinInfo.calculatedCurrentHomeCoin) /
                    Double(homeCoinInfo.maxHomeCoin)
            )
            : (
                (homeCoinInfo.calculatedCurrentHomeCoin != homeCoinInfo.maxHomeCoin)
                    ? Image(systemSymbol: .exclamationmark)
                    .overlayImageWithRingProgressBar(
                        Double(homeCoinInfo.calculatedCurrentHomeCoin) / Double(homeCoinInfo.maxHomeCoin),
                        scaler: 0.78
                    )
                    : Image(systemSymbol: .leafFill)
                    .overlayImageWithRingProgressBar(
                        Double(homeCoinInfo.calculatedCurrentHomeCoin) /
                            Double(homeCoinInfo.maxHomeCoin)
                    )
            )
    }

    var body: some View {
        HStack(alignment: .center, spacing: 8) {
            Image("洞天宝钱")
                .resizable()
                .scaledToFit()
                .frame(width: 25)
                .shadow(color: .white, radius: 1)
            isHomeCoinFullImage
                .frame(maxWidth: 13, maxHeight: 13)
                .foregroundColor(Color("textColor3"))
            HStack(alignment: .lastTextBaseline, spacing: 1) {
                Text("\(homeCoinInfo.currentHomeCoin)")
                    .lineLimit(1)
                    .foregroundColor(Color("textColor3"))
                    .font(.system(.body, design: .rounded))
                    .minimumScaleFactor(0.2)
            }
        }
    }
}
