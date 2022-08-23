//
//  EachExpeditionView.swift
//  GenshinPizzaHelper
//
//  Created by 戴藏龙 on 2022/8/23.
//

import SwiftUI

struct EachExpeditionView: View {
    let expedition: Expedition
    let viewConfig: WidgetViewConfiguration = .defaultConfig

    var body: some View {
        HStack {
            webView(urlStr: expedition.avatarSideIcon)
            VStack(alignment: .leading) {
                Text(expedition.recoveryTime.describeIntervalLong ?? "已完成")
                    .lineLimit(1)
                    .font(.footnote)
                    .minimumScaleFactor(0.4)
                percentageBar(expedition.percentage)
            }


        }
        .foregroundColor(Color("textColor3"))
        .frame(maxWidth: UIScreen.main.bounds.width / 8 * 3)




    }

    @ViewBuilder
    func webView(urlStr: String) -> some View {
        GeometryReader { g in
            WebImage(urlStr: expedition.avatarSideIcon)
                .scaleEffect(1.2)
                .scaledToFit()
                .offset(x: -g.size.width * 0.05, y: -g.size.height * 0.17)
//                .border(.blue, width: 3)
        }
        .frame(maxWidth: 50, maxHeight: 50)
    }

    @ViewBuilder
    func percentageBar(_ percentage: Double) -> some View {
        GeometryReader { g in
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .opacity(0.3)
                    .frame(width: g.size.width, height: g.size.height)
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .frame(width: g.size.width * percentage, height: g.size.height)
            }
            .aspectRatio(30/1, contentMode: .fit)
        }
        .frame(height: 7)

    }
}




