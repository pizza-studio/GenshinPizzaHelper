//
//  WatchWidgetSettingView.swift
//  WatchHelper WatchKit Extension
//
//  Created by 戴藏龙 on 2022/11/25.
//

import Defaults
import Foundation
import SwiftUI
import WidgetKit

// MARK: - WatchWidgetSettingView

struct WatchWidgetSettingView: View {
    @Default(.lockscreenWidgetSyncFrequencyInMinute)
    var lockscreenWidgetSyncFrequencyInMinute: Double
    @Default(.homeCoinRefreshFrequencyInHour)
    var homeCoinRefreshFrequency: Double
    @Default(.watchWidgetUseSimplifiedMode)
    var watchWidgetUseSimplifiedMode: Bool

    var lockscreenWidgetRefreshFrequencyFormated: String {
        let formatter = DateComponentsFormatter()
        formatter.maximumUnitCount = 2
        formatter.unitsStyle = .short
        formatter.zeroFormattingBehavior = .dropAll
        return formatter
            .string(from: lockscreenWidgetSyncFrequencyInMinute * 60.0)!
    }

    var body: some View {
        List {
            Section {
                NavigationLink {
                    QueryFrequencySettingView()
                } label: {
                    HStack {
                        Text("小组件同步频率")
                        Spacer()
                        Text(String(
                            format: NSLocalizedString("每%@", comment: ""),
                            lockscreenWidgetRefreshFrequencyFormated
                        ))
                        .foregroundColor(.accentColor)
                    }
                }
            }
            Section {
                Toggle("使用简洁模式", isOn: $watchWidgetUseSimplifiedMode)
            } footer: {
                Text("仅国服用户。更改该项需要重新添加小组件。")
            }
            if watchWidgetUseSimplifiedMode {
                Section {
                    NavigationLink {
                        HomeCoinRecoverySettingView()
                    } label: {
                        HStack {
                            Text("洞天宝钱回复速度")
                            Spacer()
                            Text(String(
                                format: NSLocalizedString(
                                    "每小时%lld个",
                                    comment: ""
                                ),
                                Int(homeCoinRefreshFrequency)
                            ))
                            .foregroundColor(.accentColor)
                        }
                    }
                } footer: {
                    Text("（仅简洁模式）未正确设置可能导致洞天宝钱数量不准确。")
                }
            }
        }
        .onChange(of: watchWidgetUseSimplifiedMode) { _ in
            if #available(watchOSApplicationExtension 9.0, *) {
                WidgetCenter.shared.invalidateConfigurationRecommendations()
            }
        }
    }
}

// MARK: - QueryFrequencySettingView

private struct QueryFrequencySettingView: View {
    @Default(.lockscreenWidgetSyncFrequencyInMinute)
    var lockscreenWidgetSyncFrequencyInMinute: Double

    var lockscreenWidgetRefreshFrequencyFormated: String {
        let formatter = DateComponentsFormatter()
        formatter.maximumUnitCount = 2
        formatter.unitsStyle = .short
        formatter.zeroFormattingBehavior = .dropAll
        return formatter
            .string(from: lockscreenWidgetSyncFrequencyInMinute * 60.0)!
    }

    var body: some View {
        VStack {
            Text("小组件同步频率").foregroundColor(.accentColor)
            Text(String(
                format: NSLocalizedString("每%@", comment: ""),
                lockscreenWidgetRefreshFrequencyFormated
            ))
            .font(.title3)
            Slider(
                value: $lockscreenWidgetSyncFrequencyInMinute,
                in: 30 ... 300,
                step: 10,
                label: {
                    Text("\(lockscreenWidgetSyncFrequencyInMinute)")
                }
            )
        }
    }
}

// MARK: - HomeCoinRecoverySettingView

private struct HomeCoinRecoverySettingView: View {
    @Default(.homeCoinRefreshFrequencyInHour)
    var homeCoinRefreshFrequency: Double

    var body: some View {
        VStack {
            Text("洞天宝钱回复速度").foregroundColor(.accentColor)
            Text(String(
                format: NSLocalizedString("每小时%lld个", comment: ""),
                Int(homeCoinRefreshFrequency)
            ))
            .font(.title3)
            Slider(
                value: $homeCoinRefreshFrequency,
                in: 4 ... 30,
                step: 2,
                label: {
                    Text("\(homeCoinRefreshFrequency)")
                }
            )
        }
    }
}
