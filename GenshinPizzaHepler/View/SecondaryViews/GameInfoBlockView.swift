//
//  GameInfoBlockView.swift
//  GenshinPizzaHepler
//
//  Created by Bill Haku on 2022/8/7.
//  主页展示账号信息的Block

import HBMihoyoAPI
import SFSafeSymbols
import SwiftUI

struct GameInfoBlock: View {
    var userData: UserData?
    let accountName: String?
    var accountUUIDString: String = UUID().uuidString

    let viewConfig = WidgetViewConfiguration.defaultConfig
    var animation: Namespace.ID

    var widgetBackground: WidgetBackground

    var fetchComplete: Bool

    var body: some View {
        if let userData = userData {
            ZStack {
                HStack {
                    VStack(alignment: .leading, spacing: 5) {
                        if let accountName = accountName {
                            HStack(alignment: .lastTextBaseline, spacing: 2) {
                                Image(systemSymbol: .personFill)
                                Text(accountName)
                            }
                            .font(.footnote)
                            .foregroundColor(Color("textColor3"))
                            .matchedGeometryEffect(
                                id: "\(accountUUIDString)name",
                                in: animation
                            )
                        }
                        Spacer()
                        HStack(alignment: .firstTextBaseline, spacing: 2) {
                            Text("\(userData.resinInfo.currentResin)")
                                .font(.system(size: 50, design: .rounded))
                                .fontWeight(.medium)
                                .minimumScaleFactor(0.1)
                                .foregroundColor(Color("textColor3"))
                                .shadow(radius: 1)
                                .matchedGeometryEffect(
                                    id: "\(accountUUIDString)curResin",
                                    in: animation
                                )
                            Image("树脂")
                                .resizable()
                                .scaledToFit()
                                .frame(maxHeight: 30)
                                .alignmentGuide(.firstTextBaseline) { context in
                                    context[.bottom] - 0.17 * context.height
                                }
                                .matchedGeometryEffect(
                                    id: "\(accountUUIDString)Resinlogo",
                                    in: animation
                                )
                        }
                        HStack {
                            Image(systemSymbol: .hourglassCircle)
                                .foregroundColor(Color("textColor3"))
                                .font(.title3)
                            recoveryTimeText(resinInfo: userData.resinInfo)
                        }
                        .matchedGeometryEffect(
                            id: "\(accountUUIDString)recovery",
                            in: animation
                        )
                    }
                    .frame(maxWidth: .infinity)
                    DetailInfo(userData: userData, viewConfig: viewConfig)
                        .frame(maxWidth: .infinity)
                        .matchedGeometryEffect(
                            id: "\(accountUUIDString)detail",
                            in: animation
                        )
                }
                .padding()
                .frame(maxHeight: 166)
                .opacity(fetchComplete ? 1 : 0)
                if !fetchComplete {
                    HStack {
                        Spacer()
                        ProgressView()
                        Spacer()
                    }
                }
            }
            .background(
                AppBlockBackgroundView(
                    background: .init(identifier: widgetBackground.imageName, display: ""),
                    darkModeOn: true
                )
                .id(widgetBackground.imageName!)
                .transition(.opacity)
                .matchedGeometryEffect(
                    id: "\(accountUUIDString)bg",
                    in: animation
                )
                .opacity(fetchComplete ? 1 : 0),
                alignment: .trailing
            )
            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
            .contentShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        } else {
            HStack {
                Spacer()
                ProgressView()
                Spacer()
            }
        }
    }

    @ViewBuilder
    func recoveryTimeText(resinInfo: ResinInfo) -> some View {
        if resinInfo.recoveryTime.second != 0 {
            Text(
                String(localized: "infoBlock.refilledAt:\(resinInfo.recoveryTime.completeTimePointFromNow())")
                    +
                    "\n\(resinInfo.recoveryTime.describeIntervalLong())"
            )
            .font(.caption)
            .lineLimit(3)
            .minimumScaleFactor(0.2)
            .foregroundColor(Color("textColor3"))
            .lineSpacing(1)
        } else {
            Text("infoBlock.resionFullyFilledDescription")
                .font(.caption)
                .lineLimit(2)
                .minimumScaleFactor(0.2)
                .foregroundColor(Color("textColor3"))
                .lineSpacing(1)
        }
    }
}
