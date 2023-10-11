//
//  RecoveryTimeTextView.swift
//  ResinStatusWidgetExtension
//
//  Created by Bill Haku on 2022/8/6.
//  恢复时间部分布局

import Foundation
import HBMihoyoAPI
import SwiftUI

struct RecoveryTimeText: View {
    let resinInfo: ResinInfo

    var body: some View {
        Group {
            if #available(iOS 16.0, *) {
                if resinInfo.recoveryTime.second != 0 {
                    let future =
                        Date(timeIntervalSinceNow: TimeInterval(
                            resinInfo
                                .recoveryTime.second
                        ))
                    VStack(alignment: .leading, spacing: 0) {
                        // 下面字符串尾随一个零长空字符，区分之前的翻译
                        Text(
                            String(
                                localized: "infoBlock.refilledAt:\(resinInfo.recoveryTime.completeTimePointFromNow())"
                            )
                        )
                        .lineLimit(2)
                        Text(future, style: .relative)
                            .lineLimit(1)
                    }
                } else {
                    Text("infoBlock.resionFullyFilledDescription")
                        .lineLimit(2)
                        .lineSpacing(1)
                }

            } else {
                Group {
                    if resinInfo.recoveryTime.second != 0 {
                        Text(
                            String(
                                localized: "infoBlock.refilledAt:\(resinInfo.recoveryTime.completeTimePointFromNow())"
                            )
                                + "\n\(resinInfo.recoveryTime.describeIntervalLong())"
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
