//
//  RecoveryTimeTextView.swift
//  ResinStatusWidgetExtension
//
//  Created by Bill Haku on 2022/8/6.
//  恢复时间部分布局

import Foundation
import HoYoKit
import SwiftUI

// MARK: - RecoveryTimeText

struct RecoveryTimeText: View {
    let resinInfo: ResinInformation

    var body: some View {
        Group {
            if #available(iOS 16.0, *) {
                if resinInfo.calculatedCurrentResin != resinInfo.maxResin {
                    VStack(alignment: .leading, spacing: 0) {
                        // 下面字符串尾随一个零长空字符，区分之前的翻译
                        Text(resinInfo.resinRecoveryTime, style: .time)
                            .lineLimit(2)
                        Text(resinInfo.resinRecoveryTime, style: .relative)
                            .lineLimit(1)
                    }
                } else {
                    Text("infoBlock.resionFullyFilledDescription")
                        .lineLimit(2)
                        .lineSpacing(1)
                }

            } else {
                Group {
                    if resinInfo.resinRecoveryTime < Date() {
                        Text(
                            dateFormatter.string(from: resinInfo.resinRecoveryTime)
                                +
                                "\n\(intervalFormatter.string(from: TimeInterval.sinceNow(to: resinInfo.resinRecoveryTime))!)"
                        )
                        .lineLimit(3)
                    } else {
                        Text("infoBlock.resionFullyFilledDescription")
                            .lineLimit(2)
                    }
                }
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
    fmt.doesRelativeDateFormatting = true
    fmt.dateStyle = .none
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
