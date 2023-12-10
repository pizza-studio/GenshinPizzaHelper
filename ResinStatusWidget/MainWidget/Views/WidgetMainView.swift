//
//  WidgetMainView.swift
//  GenshinPizzaHepler
//
//  Created by 戴藏龙 on 2022/8/7.
//  Widget总体布局分类

import HoYoKit
import SwiftUI
import WidgetKit

struct WidgetMainView: View {
    let entry: any TimelineEntry
    @Environment(\.widgetFamily)
    var family: WidgetFamily
    var dailyNote: any DailyNote
    let viewConfig: WidgetViewConfiguration
    let accountName: String?

    var body: some View {
        switch family {
        case .systemSmall:
            MainInfo(
                entry: entry,
                dailyNote: dailyNote,
                viewConfig: viewConfig,
                accountName: viewConfig.showAccountName ? accountName : nil
            )
            .padding()
        case .systemMedium:
            MainInfoWithDetail(
                entry: entry,
                dailyNote: dailyNote,
                viewConfig: viewConfig,
                accountName: viewConfig.showAccountName ? accountName : nil
            )
        case .systemLarge:
            LargeWidgetView(
                entry: entry,
                dailyNote: dailyNote,
                viewConfig: viewConfig,
                accountName: viewConfig.showAccountName ? accountName : nil
            )
        default:
            MainInfoWithDetail(
                entry: entry,
                dailyNote: dailyNote,
                viewConfig: viewConfig,
                accountName: viewConfig.showAccountName ? accountName : nil
            )
        }
    }
}
