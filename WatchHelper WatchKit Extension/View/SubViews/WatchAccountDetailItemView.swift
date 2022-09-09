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

    var body: some View {
        VStack(alignment: .leading) {
            Text(title)
                .foregroundColor(.gray)
                .font(.subheadline)
            Text(value)
        }
    }
}
