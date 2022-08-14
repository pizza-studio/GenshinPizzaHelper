//
//  GameInfoBlockView.swift
//  GenshinPizzaHepler
//
//  Created by Bill Haku on 2022/8/7.
//

import SwiftUI

struct GameInfoBlock: View {
    var userData: UserData?
    let backgroundColor: WidgetBackgroundColor
    let accountName: String?

    var body: some View {
        if userData == nil {
            HStack {
                Spacer()
                ProgressView()
                Spacer()
            }
        } else {
            MainInfoWithDetail(userData: userData!, viewConfig: .defaultConfig, accountName: accountName)
                .background(LinearGradient(colors: backgroundColor.colors, startPoint: .topLeading, endPoint: .bottomTrailing))
        }
    }
}
