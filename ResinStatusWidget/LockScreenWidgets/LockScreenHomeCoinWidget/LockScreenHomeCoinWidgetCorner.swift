//
//  LockScreenHomeCoinWidgetCorner.swift
//  GenshinPizzaHelper
//
//  Created by 戴藏龙 on 2022/9/12.
//

import HoYoKit
import SwiftUI

// MARK: - LockScreenHomeCoinWidgetCorner

@available(iOSApplicationExtension 16.0, *)
struct LockScreenHomeCoinWidgetCorner: View {
    @Environment(\.widgetRenderingMode)
    var widgetRenderingMode

    let result: Result<any DailyNote, any Error>

    var text: String {
        switch result {
        case let .success(data):
            return "\(data.homeCoinInformation.calculatedCurrentHomeCoin), \(intervalFormatter.string(from: TimeInterval.sinceNow(to: data.homeCoinInformation.fullTime))!)"
        case .failure:
            return "app.dailynote.card.homeCoin.label".localized
        }
    }

    var body: some View {
        Image("icon.homeCoin")
            .resizable()
            .scaledToFit()
            .padding(3)
            .widgetLabel(text)
    }
}

private let intervalFormatter: DateComponentsFormatter = {
    let dateComponentFormatter = DateComponentsFormatter()
    dateComponentFormatter.allowedUnits = [.hour, .minute]
    dateComponentFormatter.maximumUnitCount = 2
    dateComponentFormatter.unitsStyle = .brief
    return dateComponentFormatter
}()
