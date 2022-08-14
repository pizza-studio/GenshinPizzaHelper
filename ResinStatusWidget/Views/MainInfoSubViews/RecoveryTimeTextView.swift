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
    let showAccountName: Bool
    let accountName: String?
    
    var topString: String { showAccountName ? (accountName ?? resinInfo.recoveryTime.describeIntervalLong) : resinInfo.recoveryTime.describeIntervalLong}

    var body: some View {

        VStack(alignment: .leading, spacing: 1) {
            Group{
                Text("\(topString)\n\(resinInfo.recoveryTime.completeTimePointFromNow) 回满")
            }
            .font(.caption)
            .lineLimit(2)
            .minimumScaleFactor(0.2)
            .foregroundColor(Color("textColor3"))
            .lineSpacing(1)
        }
    }
}
