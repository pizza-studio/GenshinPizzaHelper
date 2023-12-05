//
//  MainInfoView.swift
//  ResinStatusWidgetExtension
//
//  Created by Bill Haku on 2022/8/6.
//  Widget树脂部分布局

import AppIntents
import Foundation
import HoYoKit
import SFSafeSymbols
import SwiftUI

// MARK: - MainInfo

struct MainInfo: View {
    let dailyNote: any DailyNote
    let viewConfig: WidgetViewConfiguration
    let accountName: String?
    let accountNameTest = "settings.account.myAccount"

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            if let accountName = accountName {
                HStack(alignment: .lastTextBaseline, spacing: 2) {
                    Image(systemSymbol: .personFill)
                    Text(accountName)
                        .allowsTightening(true)
                        .lineLimit(1)
                        .minimumScaleFactor(0.5)
                }
                .font(.footnote)
                .foregroundColor(Color("textColor3"))
                Spacer()
            }

            HStack(alignment: .firstTextBaseline, spacing: 2) {
                Text("\(dailyNote.resinInformation.calculatedCurrentResin)")
                    .font(.system(size: 50, design: .rounded))
                    .fontWeight(.medium)
                    .minimumScaleFactor(0.1)
                    .foregroundColor(Color("textColor3"))
                    .shadow(radius: 1)
                Image("树脂")
                    .resizable()
                    .scaledToFit()
                    .frame(maxHeight: 30)
                    .alignmentGuide(.firstTextBaseline) { context in
                        context[.bottom] - 0.17 * context.height
                    }
                    .shadow(radius: 0.8)
            }
            Spacer()
            HStack {
                if #available(iOS 17, *) {
                    Button(intent: WidgetRefreshIntent()) {
                        Image(systemSymbol: .arrowClockwiseCircle)
                            .font(.title3)
                            .foregroundColor(Color("textColor3"))
                            .clipShape(.circle)
                    }
                    .buttonStyle(.plain)
                } else {
                    Image(systemSymbol: .exclamationmarkCircle)
                        .foregroundColor(Color("textColor3"))
                        .font(.title3)
                }
                RecoveryTimeText(resinInfo: dailyNote.resinInformation)
            }
        }
    }
}

// MARK: - WidgetRefreshIntent

@available(iOSApplicationExtension 16, iOS 16, *)
struct WidgetRefreshIntent: AppIntent {
    static var title: LocalizedStringResource = "Refresh"

    func perform() async throws -> some IntentResult {
        .result()
    }
}
