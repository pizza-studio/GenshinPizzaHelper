//
//  LockScreenResinWidgetCircular.swift
//  ResinStatusWidgetExtension
//
//  Created by 戴藏龙 on 2022/9/11.
//

import Foundation
import SwiftUI

@available(iOSApplicationExtension 16.0, *)
struct LockScreenResinWidgetCircular: View {
    let result: FetchResult

    var body: some View {
        switch result {
        case .success(let data):

            Gauge(value: Double(data.resinInfo.currentResin), in: 0.0...Double(data.resinInfo.maxResin)) {
                Image("icon.resin")
                    .resizable()
                    .scaledToFit()
            } currentValueLabel: {
                Text("\(data.resinInfo.currentResin)")
                    .font(.system(.title3, design: .rounded))
                    .minimumScaleFactor(0.4)
            }
            .gaugeStyle(ProgressGaugeStyle())
        case .failure(_):
            Gauge(value: 0.0, in: 0.0...160.0) {
                Image("icon.resin")
                    .resizable()
                    .scaledToFit()
            } currentValueLabel: {
                Image(systemName: "ellipsis")
            }
            .gaugeStyle(ProgressGaugeStyle())
        }
    }
}
