//
//  LockScreenHomeCoinWidgetCircular.swift
//  GenshinPizzaHelper
//
//  Created by 戴藏龙 on 2022/9/11.
//

import HoYoKit
import SFSafeSymbols
import SwiftUI
import WidgetKit

@available(iOSApplicationExtension 16.0, *)
struct LockScreenHomeCoinWidgetCircular: View {
    let entry: any TimelineEntry
    @Environment(\.widgetRenderingMode)
    var widgetRenderingMode

    let result: Result<any DailyNote, any Error>

    var body: some View {
        switch widgetRenderingMode {
        case .accented:
            VStack(spacing: 0) {
                Image("icon.homeCoin")
                    .resizable()
                    .scaledToFit()
                switch result {
                case let .success(data):
                    Text("\(data.homeCoinInformation.calculatedCurrentHomeCoin(referTo: entry.date))")
                        .font(.system(.body, design: .rounded).weight(.medium))
                case .failure:
                    Image(systemSymbol: .ellipsis)
                }
            }
            #if os(watchOS)
            .padding(.vertical, 2)
            .padding(.top, 1)
            #else
            .padding(.vertical, 2)
            #endif
            .widgetAccentable()
        case .fullColor:
            VStack(spacing: 0) {
                Image("icon.homeCoin")
                    .resizable()
                    .scaledToFit()
                    .foregroundColor(Color("iconColor.homeCoin.lightBlue"))
                switch result {
                case let .success(data):
                    Text("\(data.homeCoinInformation.calculatedCurrentHomeCoin(referTo: entry.date))")
                        .font(.system(.body, design: .rounded).weight(.medium))
                case .failure:
                    Image(systemSymbol: .ellipsis)
                }
            }
            #if os(watchOS)
            .padding(.vertical, 2)
            .padding(.top, 1)
            #else
            .padding(.vertical, 2)
            #endif
        default:
            VStack(spacing: 0) {
                Image("icon.homeCoin")
                    .resizable()
                    .scaledToFit()

                switch result {
                case let .success(data):
                    Text("\(data.homeCoinInformation.calculatedCurrentHomeCoin(referTo: entry.date))")
                        .font(.system(.body, design: .rounded).weight(.medium))
                case .failure:
                    Image(systemSymbol: .ellipsis)
                }
            }
            #if os(watchOS)
            .padding(.vertical, 2)
            .padding(.top, 1)
            #else
            .padding(.vertical, 2)
            #endif
        }
    }
}
