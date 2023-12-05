//
//  TransformerInfoBar.swift
//  GenshinPizzaHepler
//
//  Created by 戴藏龙 on 2022/8/7.
//

import HoYoKit
import SFSafeSymbols
import SwiftUI

// MARK: - TransformerInfoBar

struct TransformerInfoBar: View {
    let transformerInfo: GeneralDailyNote.TransformerInformation

    var percentage: Double {
        let second = transformerInfo.recoveryTime.timeIntervalSinceReferenceDate - Date().timeIntervalSinceReferenceDate
        return second / Double(7 * 24 * 60 * 60)
    }

    var isTransformerCompleteImage: some View {
        (transformerInfo.recoveryTime <= Date())
            ? Image(systemSymbol: .exclamationmark)
            .overlayImageWithRingProgressBar(
                percentage,
                scaler: 0.78
            )
            : Image(systemSymbol: .hourglass)
            .overlayImageWithRingProgressBar(1)
    }

    var body: some View {
        HStack(alignment: .center, spacing: 8) {
            Image("参量质变仪")
                .resizable()
                .scaledToFit()
                .frame(width: 25)
                .shadow(color: .white, radius: 1)
            isTransformerCompleteImage

                .frame(maxWidth: 13, maxHeight: 13)
                .foregroundColor(Color("textColor3"))
            HStack(alignment: .lastTextBaseline, spacing: 1) {
                Text(
                    intervalFormatter.string(from: TimeInterval.sinceNow(to: transformerInfo.recoveryTime))!
                )
                .foregroundColor(Color("textColor3"))
                .lineLimit(1)
                .font(.system(.body, design: .rounded))
                .minimumScaleFactor(0.2)
            }
        }
    }
}

private let intervalFormatter: DateComponentsFormatter = {
    let dateComponentFormatter = DateComponentsFormatter()
    dateComponentFormatter.allowedUnits = [.hour, .minute]
    dateComponentFormatter.maximumUnitCount = 2
    dateComponentFormatter.unitsStyle = .brief
    return dateComponentFormatter
}()
