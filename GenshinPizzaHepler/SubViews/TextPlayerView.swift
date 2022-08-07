//
//  TextPlayerView.swift
//  GenshinPizzaHepler
//
//  Created by Bill Haku on 2022/8/6.
//

import SwiftUI

struct TextPlayerView: View {
    var text: String

    var body: some View {
        VStack {
            Text(text)
                .padding()
            Spacer()
        }
    }
}
