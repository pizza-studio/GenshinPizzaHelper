//
//  LockScreenResinWidgetInline.swift
//  ResinStatusWidgetExtension
//
//  Created by 戴藏龙 on 2022/9/11.
//

import HoYoKit
import SFSafeSymbols
import SwiftUI

// MARK: - LockScreenResinWidgetInline

struct LockScreenResinWidgetInline: View {
    let result: Result<any DailyNote, any Error>

    var body: some View {
        switch result {
        case let .success(data):
            if data.resinInformation.calculatedCurrentResin >= data.resinInformation.maxResin {
                Image(systemSymbol: .moonStarsFill)
            } else {
                Image(systemSymbol: .moonFill)
            }
            Text(
                "\(data.resinInformation.calculatedCurrentResin)  \(intervalFormatter.string(from: TimeInterval.sinceNow(to: data.resinInformation.resinRecoveryTime))!)"
            )
        // 似乎不能插入自定义的树脂图片，也许以后会开放
//                Image("icon.resin")
        case .failure:
            Image(systemSymbol: .moonFill)
            Text("…")
        }
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
