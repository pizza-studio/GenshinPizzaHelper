//
//  MainInfoWithDetailView.swift
//  ResinStatusWidgetExtension
//
//  Created by Bill Haku on 2022/8/6.
//  中号Widget布局

import Foundation
import HoYoKit
import SwiftUI

// MARK: - MainInfoWithDetail

struct MainInfoWithDetail: View {
    var dailyNote: any DailyNote
    let viewConfig: WidgetViewConfiguration
    let accountName: String?

    var body: some View {
        HStack {
            Spacer()
            MainInfo(
                dailyNote: dailyNote,
                viewConfig: viewConfig,
                accountName: accountName
            )
            .padding()
            Spacer()
            DetailInfo(dailyNote: dailyNote, viewConfig: viewConfig)
                .padding([.vertical])
                .frame(maxWidth: UIScreen.main.bounds.width / 8 * 3)
            Spacer()
        }
    }
}
