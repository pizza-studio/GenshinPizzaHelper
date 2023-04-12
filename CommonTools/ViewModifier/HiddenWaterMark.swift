//
//  HiddenWaterMark.swift
//  GenshinPizzaHepler
//
//  Created by 戴藏龙 on 2022/10/7.
//

import SwiftUI

// MARK: - HiddenWaterMark

struct HiddenWaterMark: ViewModifier {
    func body(content: Content) -> some View {
        let waterMarkWithName = HStack {
            Image("AppIconHD")
                .resizable()
                .scaledToFit()
                .clipShape(RoundedRectangle(
                    cornerRadius: 5,
                    style: .continuous
                ))
            Text("披萨小助手").font(.footnote).bold()
        }
        .frame(maxWidth: 270, maxHeight: 20)
        switch ThisDevice.notchType {
        case .dynamicIsland:
            ZStack(alignment: .top) {
                content
                waterMarkWithName.padding(.top, 15)
            }
        case .normalNotch:
            ZStack(alignment: .top) {
                content
                waterMarkWithName.padding(.top, 10)
            }
        case .none:
            content
        }
    }
}

extension View {
    func addWaterMark(_ showVisible: Bool) -> some View {
        ZStack(alignment: .topTrailing) {
            modifier(HiddenWaterMark())
            if ThisDevice.notchType == .none, showVisible {
                Image("AppIconHD")
                    .resizable()
                    .scaledToFit()
                    .clipShape(Circle())
                    .frame(maxHeight: 20)
                    .padding()
            }
        }
    }
}
