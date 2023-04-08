//
//  EnkaAPISwiftUIExtensions.swift
//  GenshinPizzaHelper
//
//  Created by ShikiSuen on 2023/4/8.
//

import Foundation
import SwiftUI

// MARK: Enka Character Icons

import HBPizzaHelperAPI

extension ENCharacterMap.Character {
    enum DecoratedIconCutType: CGFloat {
        case shoulder = 1
        case head = 1.5
        case face = 2
    }

    /// 顯示帶有背景的角色肖像。
    /// - Parameters:
    ///   - size: 尺寸。
    ///   - cutType: 決定裁切到哪個身體部位。
    /// - Returns: SwiftUI "some View"
    func decoratedIcon(_ size: CGFloat, cutTo cutType: DecoratedIconCutType = .shoulder) -> some View {
        // let delta: CGFloat = cutType.rawValue
        // 由于 Lava 强烈反对针对证件照的脸裁切与头裁切，所以上一行禁用，以下一行取而代之。
        let delta: CGFloat = DecoratedIconCutType.shoulder.rawValue
        return EnkaWebIcon(iconString: iconString)
            .scaledToFill()
            .frame(width: size * delta, height: size * delta)
            .clipped()
            .scaledToFit()
            .background(
                EnkaWebIcon(
                    iconString: namecardIconString
                )
                .scaledToFill()
                .offset(x: size / -3)
            )
            .frame(width: size, height: size)
            .clipShape(Circle())
            .contentShape(Circle())
    }
}

extension PlayerDetail.Avatar {
    /// 顯示帶有背景的角色肖像。
    /// - Parameters:
    ///   - size: 尺寸。
    ///   - cutType: 決定裁切到哪個身體部位。
    /// - Returns: SwiftUI "some View"
    func decoratedIcon(
        _ size: CGFloat,
        cutTo cutType: ENCharacterMap.Character.DecoratedIconCutType = .shoulder
    )
        -> some View {
        character.decoratedIcon(size, cutTo: cutType)
    }
}
