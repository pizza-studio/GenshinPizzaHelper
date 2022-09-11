//
//  LockScreenHomeCoinWidgetCircular.swift
//  GenshinPizzaHelper
//
//  Created by 戴藏龙 on 2022/9/11.
//

import SwiftUI

@available(iOSApplicationExtension 16.0, *)
struct LockScreenHomeCoinWidgetCircular: View {
    let result: FetchResult

    var body: some View {
        VStack(spacing: 0) {
            Image("icon.homeCoin")
                .resizable()
                .scaledToFit()
            #if os(watchOS)
                .padding(.top, 3)
            #else
                .padding(.top, 5.5)
            #endif
//                    .frame(width: g.size.width*0.8)
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

