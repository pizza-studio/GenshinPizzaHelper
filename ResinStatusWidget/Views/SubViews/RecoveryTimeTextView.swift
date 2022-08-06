//
//  RecoveryTimeTextView.swift
//  ResinStatusWidgetExtension
//
//  Created by Bill Haku on 2022/8/6.
//

import Foundation
import SwiftUI

struct RecoveryTimeText: View {
    let recoveryTimeDeltaInt: Int
    var recoveryTime: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .short
        dateFormatter.timeStyle = .short
        dateFormatter.doesRelativeDateFormatting = true
        dateFormatter.locale = Locale(identifier: "zh_CN")

        let date = Date().adding(seconds: recoveryTimeDeltaInt)

        return dateFormatter.string(from: date)
    }

    var body: some View {

        VStack(alignment: .leading, spacing: 1) {
            Group{
                Text("\(secondsToHoursMinutesSeconds(recoveryTimeDeltaInt))\n\(recoveryTime) 回满")
            }
            .font(.caption)
            .lineLimit(2)
            .minimumScaleFactor(0.2)
            .foregroundColor(Color("textColor3"))
            .lineSpacing(1)
        }
    }
}
