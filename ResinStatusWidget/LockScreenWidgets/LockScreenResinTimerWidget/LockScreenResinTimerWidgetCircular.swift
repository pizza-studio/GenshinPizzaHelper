//
//  LockScreenResinTimerWidgetCircular.swift
//  ResinStatusWidgetExtension
//
//  Created by 戴藏龙 on 2022/11/25.
//

import Foundation
import HoYoKit
import SFSafeSymbols
import SwiftUI
import WidgetKit

@available(iOSApplicationExtension 16.0, *)
struct LockScreenResinTimerWidgetCircular: View {
    @Environment(\.widgetRenderingMode)
    var widgetRenderingMode

    let result: Result<any DailyNote, any Error>

    var body: some View {
        switch widgetRenderingMode {
        case .fullColor:
            ZStack {
                AccessoryWidgetBackground()
                VStack(spacing: 3) {
                    LinearGradient(
                        colors: [
                            .init("iconColor.resin.dark"),
                            .init("iconColor.resin.middle"),
                            .init("iconColor.resin.light"),
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                    .mask(
                        Image("icon.resin")
                            .resizable()
                            .scaledToFit()
                    )
                    .frame(height: 10)
                    switch result {
                    case let .success(data):
                        VStack(spacing: 1) {
                            if data.resinInformation.calculatedCurrentResin != data.resinInformation.maxResin {
                                Text(
                                    Date(
                                        timeIntervalSinceNow: TimeInterval
                                            .sinceNow(to: data.resinInformation.resinRecoveryTime)
                                    ),
                                    style: .timer
                                )
                                .multilineTextAlignment(.center)
                                .font(.system(.body, design: .monospaced))
                                .minimumScaleFactor(0.1)
                                .widgetAccentable()
                                .frame(width: 50)
                                Text("\(data.resinInformation.calculatedCurrentResin)")
                                    .font(.system(
                                        .body,
                                        design: .rounded,
                                        weight: .medium
                                    ))
                                    .foregroundColor(
                                        Color("textColor.originResin")
                                    )
                            } else {
                                Text("\(data.resinInformation.calculatedCurrentResin)")
                                    .font(.system(
                                        size: 20,
                                        weight: .medium,
                                        design: .rounded
                                    ))
                                    .foregroundColor(
                                        Color("textColor.originResin")
                                    )
                            }
                        }
                    case .failure:
                        Image("icon.resin")
                            .resizable()
                            .scaledToFit()
                            .frame(height: 10)
                        Image(systemSymbol: .ellipsis)
                    }
                }
                .padding(.vertical, 2)
                #if os(watchOS)
                    .padding(.vertical, 2)
                #endif
            }
        default:
            ZStack {
                AccessoryWidgetBackground()
                VStack(spacing: 3) {
                    Image("icon.resin")
                        .resizable()
                        .scaledToFit()
                        .frame(height: 10)
                    switch result {
                    case let .success(data):
                        VStack(spacing: 1) {
                            if data.resinInformation.calculatedCurrentResin != data.resinInformation.maxResin {
                                Text(
                                    Date(
                                        timeIntervalSinceNow: TimeInterval
                                            .sinceNow(to: data.resinInformation.resinRecoveryTime)
                                    ),
                                    style: .timer
                                )
                                .multilineTextAlignment(.center)
                                .font(.system(.body, design: .monospaced))
                                .minimumScaleFactor(0.1)
                                .widgetAccentable()
                                .frame(width: 50)
                                Text("\(data.resinInformation.calculatedCurrentResin)")
                                    .font(.system(
                                        .body,
                                        design: .rounded,
                                        weight: .medium
                                    ))
                            } else {
                                Text("\(data.resinInformation.calculatedCurrentResin)")
                                    .font(.system(
                                        size: 20,
                                        weight: .medium,
                                        design: .rounded
                                    ))
                            }
                        }
                    case .failure:
                        Image("icon.resin")
                            .resizable()
                            .scaledToFit()
                            .frame(height: 10)
                        Image(systemSymbol: .ellipsis)
                    }
                }
                .padding(.vertical, 2)
                #if os(watchOS)
                    .padding(.vertical, 2)
                #endif
            }
        }
    }
}
