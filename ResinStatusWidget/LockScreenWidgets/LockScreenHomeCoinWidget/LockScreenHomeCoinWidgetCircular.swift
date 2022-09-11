//
//  LockScreenHomeCoinWidgetCircular.swift
//  GenshinPizzaHelper
//
//  Created by 戴藏龙 on 2022/9/11.
//

import SwiftUI

@available(iOSApplicationExtension 16.0, *)
struct LockScreenHomeCoinWidgetCircular: View {
    @Environment(\.widgetRenderingMode) var widgetRenderingMode

    let result: FetchResult

    var body: some View {
        switch widgetRenderingMode {
        case .accented:
            VStack(spacing: 0) {
                Image("icon.homeCoin")
                    .resizable()
                    .scaledToFit()
                #if os(watchOS)
                    .padding(.top, 3)
                #else
                    .padding(.top, 5.5)
                #endif

                switch result {
                case .success(let data):
                    Text("\(data.homeCoinInfo.currentHomeCoin)")
                        .font(.system(.body, design: .rounded).weight(.medium))
                case .failure(_):
                    Image(systemName: "ellipsis")
                }
            }
            .widgetAccentable()
        case .fullColor:
            VStack(spacing: 0) {
                Image("icon.homeCoin")
                    .resizable()
                    .scaledToFit()
                #if os(watchOS)
                    .padding(.top, 3)
                #else
                    .padding(.top, 5.5)
                #endif
                    .foregroundColor(Color("iconColor.homeCoin.lightBlue"))
                switch result {
                case .success(let data):
                    Text("\(data.homeCoinInfo.currentHomeCoin)")
                        .font(.system(.body, design: .rounded).weight(.medium))
//                        .foregroundColor(Color("iconColor.homeCoin.lightBlue"))
                case .failure(_):
                    Image(systemName: "ellipsis")
//                        .foregroundColor(Color("iconColor.homeCoin.lightBlue"))
                }
            }
        default:
            VStack(spacing: 0) {
                Image("icon.homeCoin")
                    .resizable()
                    .scaledToFit()
                #if os(watchOS)
                    .padding(.top, 3)
                #else
                    .padding(.top, 5.5)
                #endif
                switch result {
                case .success(let data):
                    Text("\(data.homeCoinInfo.currentHomeCoin)")
                        .font(.system(.body, design: .rounded).weight(.medium))
                case .failure(_):
                    Image(systemName: "ellipsis")
                }
            }
        }
    }
}

