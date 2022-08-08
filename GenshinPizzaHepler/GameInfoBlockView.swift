//
//  GameInfoBlockView.swift
//  GenshinPizzaHepler
//
//  Created by Bill Haku on 2022/8/7.
//

import SwiftUI

struct GameInfoBlock: View {
    var userData: UserData?
    let backgroundColors: [Color] = [
        Color("backgroundColor1"),
        Color("backgroundColor2"),
        Color("backgroundColor3")
    ]

    var body: some View {
        if userData == nil {
            HStack {
                Spacer()
                ProgressView()
                Spacer()
            }
        } else {
            MainInfoWithDetail(userData: userData!)
                .background(LinearGradient(colors: backgroundColors, startPoint: .topLeading, endPoint: .bottomTrailing))
        }
    }
}
