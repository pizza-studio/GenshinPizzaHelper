//
//  ExpeditionsView.swift
//  GenshinPizzaHelper
//
//  Created by 戴藏龙 on 2022/8/23.
//  探索派遣View

import HoYoKit
import SwiftUI

struct ExpeditionsView: View {
    let expeditions: [any Expedition]
    var useAsyncImage: Bool = false

    var body: some View {
        VStack {
            ForEach(expeditions, id: \.iconURL) { expedition in
                EachExpeditionView(
                    expedition: expedition,
                    useAsyncImage: useAsyncImage
                )
            }
        }
//        .background(WidgetBackgroundView(background: .randomNamecardBackground, darkModeOn: true))
    }
}
