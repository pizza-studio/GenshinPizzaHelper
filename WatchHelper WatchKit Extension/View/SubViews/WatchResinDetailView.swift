//
//  WatchResinDetailView.swift
//  WatchHelper WatchKit Extension
//
//  Created by 戴藏龙 on 2022/9/9.
//

import HoYoKit
import SwiftUI

// MARK: - WatchResinDetailView

struct WatchResinDetailView: View {
    let resinInfo: ResinInformation

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                Image("树脂")
                    .resizable()
                    .scaledToFit()
                    .frame(height: 25)
                Text("原粹树脂")
                    .foregroundColor(.gray)
            }
            Text("\(resinInfo.currentResin)")
                .font(.system(size: 40, design: .rounded))
                .fontWeight(.medium)
            recoveryTimeText()
        }
    }

    @ViewBuilder
    func recoveryTimeText() -> some View {
        if resinInfo.resinRecoveryTime >= Date() {
            Text("infoBlock.refilledAt:\(dateFormatter.string(from: resinInfo.resinRecoveryTime))")
                .lineLimit(2)
                .foregroundColor(.gray)
                .minimumScaleFactor(0.3)
                .font(.footnote)
        } else {
            Text("树脂已全部回满")
                .foregroundColor(.gray)
                .minimumScaleFactor(0.3)
                .font(.footnote)
        }
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
