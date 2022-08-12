//
//  ResinInfoBar.swift
//  GenshinPizzaHepler
//
//  Created by 戴藏龙 on 2022/8/7.
//

import SwiftUI

struct HomeCoinInfoBar: View {
    let homeCoinInfo: HomeCoinInfo
    
    var isHomeCoinFullImage: Image {
        (homeCoinInfo.isFull) ? Image(systemName: "exclamationmark.circle") : Image(systemName: "leaf.fill")
    }
    
    var body: some View {
        HStack(alignment: .center ,spacing: 8) {
            Image("洞天宝钱")
                .resizable()
                .scaledToFit()
                .frame(width: 25)
                .shadow(color: .white, radius: 1)
            isHomeCoinFullImage
                .resizable()
                .scaledToFit()
                .font(Font.title.bold())
                .overlayRingProgressBar(homeCoinInfo.percentage)
                .frame(width: 15, height: 15)
                .foregroundColor(Color("textColor3"))
            HStack(alignment: .lastTextBaseline, spacing:1) {
                Text("\(homeCoinInfo.currentHomeCoin)")
                    .foregroundColor(Color("textColor3"))
                    .font(.system(.body, design: .rounded))
                    .minimumScaleFactor(0.2)
            }
        }
    }
}


