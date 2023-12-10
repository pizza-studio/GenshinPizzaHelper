//
//  LockScreenResinWidgetCorner.swift
//  GenshinPizzaHelper
//
//  Created by 戴藏龙 on 2022/9/12.
//

import HoYoKit
import SwiftUI
import WidgetKit

// MARK: - LockScreenResinWidgetCorner

@available(iOSApplicationExtension 16.0, *)
struct LockScreenResinWidgetCorner: View {
    let entry: any TimelineEntry
    @Environment(\.widgetRenderingMode)
    var widgetRenderingMode

    let result: Result<any DailyNote, any Error>

    var text: String {
        switch result {
        case let .success(data):
            if data.resinInformation.calculatedCurrentResin(referTo: entry.date) >= data.resinInformation.maxResin {
                return String(format: NSLocalizedString(
                    "160, 已回满",
                    comment: "resin"
                ))
            } else {
                return "\(data.resinInformation.calculatedCurrentResin(referTo: entry.date)), \(intervalFormatter.string(from: TimeInterval.sinceNow(to: data.resinInformation.resinRecoveryTime))!), \(dateFormatter.string(from: data.resinInformation.resinRecoveryTime))"
            }
        case .failure:
            return "app.dailynote.card.resin.label".localized
        }
    }

    var body: some View {
        Image("icon.resin")
            .resizable()
            .scaledToFit()
            .padding(4)
            .widgetLabel(text)
    }
}

private let dateFormatter: DateFormatter = {
    let fmt = DateFormatter()
    fmt.doesRelativeDateFormatting = true
    fmt.dateStyle = .short
    fmt.timeStyle = .short
    return fmt
}()

private let intervalFormatter: DateComponentsFormatter = {
    let dateComponentFormatter = DateComponentsFormatter()
    dateComponentFormatter.allowedUnits = [.hour, .minute]
    dateComponentFormatter.maximumUnitCount = 2
    dateComponentFormatter.unitsStyle = .brief
    return dateComponentFormatter
}()
