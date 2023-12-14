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
                        Text("widget.settings.sync.frequency.title")
                        Spacer()
                        Text(String(
                            format: NSLocalizedString("widget.settings.sync.speed:%@", comment: ""),
                            lockscreenWidgetRefreshFrequencyFormated
                        ))
                        .foregroundColor(.accentColor)
                    }
                }
            }
            Section {
                Toggle("settings.widget.simplifiedMode.title", isOn: $watchWidgetUseSimplifiedMode)
            } footer: {
                Text("settings.widget.simplifiedMode.note")
            }
            if watchWidgetUseSimplifiedMode {
                Section {
                    NavigationLink {
                        HomeCoinRecoverySettingView()
                    } label: {
                        HStack {
                            Text("settings.widget.realmCurrency.speed")
                            Spacer()
                            Text(String(
                                format: NSLocalizedString(
                                    "settings.widget.realmCurrency.speed.detail",
                                    comment: ""
                                ),
                                Int(homeCoinRefreshFrequency)
                            ))
                            .foregroundColor(.accentColor)
                        }
                    }
                } footer: {
                    Text("settings.widget.simplifiedMode.note.realmCurrency")
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
            Text("widget.settings.sync.frequency.title").foregroundColor(.accentColor)
            Text(String(
                format: NSLocalizedString("widget.settings.sync.speed:%@", comment: ""),
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
            Text("settings.widget.realmCurrency.speed").foregroundColor(.accentColor)
            Text(String(
                format: NSLocalizedString("settings.widget.realmCurrency.speed.detail", comment: ""),
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
