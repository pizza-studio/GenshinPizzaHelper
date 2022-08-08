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
        (homeCoinInfo.isFull) ? Image(systemName: "exclamationmark.circle") : Image(systemName: "leaf.arrow.triangle.circlepath")
    }
    
    var body: some View {
        HStack(alignment: .center ,spacing: 8) {
            Image("洞天宝钱")
                .resizable()
                .scaledToFit()
                .frame(width: 25)
                .shadow(color: .white, radius: 1)
            isHomeCoinFullImage
                .foregroundColor(Color("textColor3"))
                .font(.system(size: 14))
            HStack(alignment: .lastTextBaseline, spacing:1) {
                Text("\(homeCoinInfo.currentHomeCoin)")
                    .foregroundColor(Color("textColor3"))
                    .font(.system(.body, design: .rounded))
                    .minimumScaleFactor(0.2)
            }
        }
    }
}


