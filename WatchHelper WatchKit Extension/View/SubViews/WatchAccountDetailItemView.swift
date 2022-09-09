//
//  WatchAccountDetailItemView.swift
//  WatchHelper WatchKit Extension
//
//  Created by Bill Haku on 2022/9/9.
//

import SwiftUI

struct WatchAccountDetailItemView: View {
    var title: String
    var value: String
    var icon: Image?

    var body: some View {
        HStack {
            if let icon = icon {
                icon
                    .resizable()
                    .scaledToFit()
            }
            Text(LocalizedStringKey(title))
                .foregroundColor(.gray)
                .font(.subheadline)
                .lineSpacing(1)
                .minimumScaleFactor(0.3)
            Spacer()
            Text(value)
        }
        .frame(maxHeight: 20)
    }
}
