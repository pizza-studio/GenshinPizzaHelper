//
//  RecoveryTimeTextView.swift
//  ResinStatusWidgetExtension
//
//  Created by Bill Haku on 2022/8/6.
//

import Foundation
import SwiftUI

struct RecoveryTimeText: View {
    let resinInfo: ResinInfo

    var body: some View {

        VStack(alignment: .leading, spacing: 1) {
            Group{
                Text("\(resinInfo.recoveryTime.describeIntervalLong)\n\(resinInfo.recoveryTime.completeTimePointFromNow) 回满")
            }
            .font(.caption)
            .lineLimit(2)
            .minimumScaleFactor(0.2)
            .foregroundColor(Color("textColor3"))
            .lineSpacing(1)
        }
    }
}
