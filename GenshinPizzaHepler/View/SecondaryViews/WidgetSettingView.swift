//
//  WidgetSettingView.swift
//  GenshinPizzaHepler
//
//  Created by 戴藏龙 on 2022/11/11.
//

import Defaults
import SwiftUI

// MARK: - WidgetSettingView

struct WidgetSettingView: View {
    @Default(.mainWidgetSyncFrequencyInMinute)
    var mainWidgetSyncFrequencyInMinute: Double
    @Default(.lockscreenWidgetSyncFrequencyInMinute)
    var lockscreenWidgetSyncFrequencyInMinute: Double
    @Default(.homeCoinRefreshFrequencyInHour)
    var homeCoinRefreshFrequency: Double

    @State
    var isWidgetTipsSheetShow: Bool = false

    var body: some View {
        List {
            Section {
                Button { isWidgetTipsSheetShow.toggle() } label: {
                    Text("app.tips.widget.general.title")
                        .multilineTextAlignment(.leading)
                }
            }

//            Section {
//                SettingSlider(
//                    title: "widget.settings.sync.frequency.homeScreen",
//                    value: $mainWidgetSyncFrequencyInMinute,
//                    valueFormatterString: "widget.settings.sync.speed:%@",
//                    bounds: 30 ... 300,
//                    step: 10
//                ) { value in
//                    let formatter = DateComponentsFormatter()
//                    formatter.maximumUnitCount = 2
//                    formatter.unitsStyle = .short
//                    formatter.zeroFormattingBehavior = .dropAll
//                    return formatter.string(from: value * 60.0)!
//                }
//                SettingSlider(
//                    title: "widget.settings.sync.frequency.lockScreen",
//                    value: $lockscreenWidgetSyncFrequencyInMinute,
//                    valueFormatterString: "widget.settings.sync.speed:%@",
//                    bounds: 30 ... 300,
//                    step: 10
//                ) { value in
//                    let formatter = DateComponentsFormatter()
//                    formatter.maximumUnitCount = 2
//                    formatter.unitsStyle = .short
//                    formatter.zeroFormattingBehavior = .dropAll
//                    return formatter.string(from: value * 60.0)!
//                }
//            } header: {
//                Text("widget.settings.sync.frequency.title")
//            } footer: {
//                Text(
//                    "widget.refresh.note"
//                )
//            }

            Section {
                SettingSlider(
                    title: "settings.widget.realmCurrency.speed",
                    value: $homeCoinRefreshFrequency,
                    valueFormatterString: "widget.settings.realmCurrency.speed:%@",
                    bounds: 4 ... 30,
                    step: 2
                ) { value in
                    "\(Int(value))"
                }
            } footer: {
                Text("settings.widget.simplifiedMode.note.notification")
            }
        }
        .navigationBarTitle("settings.widget.title", displayMode: .inline)
        .sheet(isPresented: $isWidgetTipsSheetShow) {
            WidgetTipsView(isSheetShow: $isWidgetTipsSheetShow)
        }
    }
}

// MARK: - SettingSlider

private struct SettingSlider<V>: View where V: BinaryFloatingPoint,
    V.Stride: BinaryFloatingPoint {
    let title: String
    @Binding
    var value: V
    var valueFormatterString: String = "%@"
    let bounds: ClosedRange<V>
    let step: V.Stride
    var formatMethod: (V) -> String = { "\($0)" }

    @State
    var showSlider: Bool = false

    var body: some View {
        HStack {
            Text(title.localized)
            Spacer()
            Button(action: {
                withAnimation { showSlider.toggle() }
            }) {
                Text(String(
                    format: NSLocalizedString(
                        valueFormatterString,
                        comment: ""
                    ),
                    formatMethod(value)
                ))
            }
        }
        if showSlider {
            Slider(
                value: $value,
                in: bounds,
                step: step,
                label: {
                    EmptyView()
                }
            )
        }
    }
}
