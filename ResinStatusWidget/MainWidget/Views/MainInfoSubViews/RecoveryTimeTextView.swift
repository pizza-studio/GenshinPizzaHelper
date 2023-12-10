//
//  RecoveryTimeTextView.swift
//  ResinStatusWidgetExtension
//
//  Created by Bill Haku on 2022/8/6.
//  恢复时间部分布局

import Foundation
import HoYoKit
import SwiftUI
import WidgetKit

// MARK: - RecoveryTimeText

struct RecoveryTimeText: View {
    let entry: any TimelineEntry
    let resinInfo: ResinInformation

    var body: some View {
        Group {
            if resinInfo.calculatedCurrentResin(referTo: entry.date) < resinInfo.maxResin {
                VStack(alignment: .leading, spacing: 0) {
                    Text(dateFormatter.string(from: resinInfo.resinRecoveryTime))
                        + Text(verbatim: "\n")
                        +
                        Text(
                            intervalFormatter
                                .string(from: TimeInterval.sinceNow(to: resinInfo.resinRecoveryTime))!
                        )
                }
            } else {
                Text("infoBlock.resionFullyFilledDescription")
                    .lineLimit(2)
                    .lineSpacing(1)
            }
        }
        .font(.caption)
        .minimumScaleFactor(0.2)
        .foregroundColor(Color("textColor3"))
    }
}

private let dateFormatter: DateFormatter = {
    let fmt = DateFormatter()
    fmt.dateStyle = .short
    fmt.timeStyle = .short
    fmt.doesRelativeDateFormatting = true
    return fmt
}()

private let intervalFormatter: DateComponentsFormatter = {
    let dateComponentFormatter = DateComponentsFormatter()
    dateComponentFormatter.allowedUnits = [.hour, .minute]
    dateComponentFormatter.maximumUnitCount = 2
    dateComponentFormatter.unitsStyle = .brief
    return dateComponentFormatter
}()
