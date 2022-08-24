//
//  ExpeditionsView.swift
//  GenshinPizzaHelper
//
//  Created by 戴藏龙 on 2022/8/23.
//

import SwiftUI

struct ExpeditionsView: View {
    let expeditions: [Expedition]

    var body: some View {
        VStack {
            Spacer()
            ForEach(expeditions, id: \.charactersEnglishName) { expedition in
                EachExpeditionView(expedition: expedition)
                Spacer()
            }
        }
//        .background(WidgetBackgroundView(background: .randomNamecardBackground, darkModeOn: true))
    }
}


