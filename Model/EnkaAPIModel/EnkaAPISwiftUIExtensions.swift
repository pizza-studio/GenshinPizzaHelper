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

// MARK: - DecoratedIconCutType

public enum DecoratedIconCutType: CGFloat {
    case shoulder = 1
    case head = 1.5
    case face = 2

    // MARK: Internal

    func shiftedAmount(containerSize size: CGFloat) -> CGFloat {
        switch self {
        case .shoulder: return 0
        default: return size / (4 * rawValue)
        }
    }
}

extension ENCharacterMap.Character {
    /// 显示带有背景的角色肖像。
    /// - Parameters:
    ///   - size: 尺寸。
    ///   - cutType: 决定裁切到哪个身体部位。
    /// - Returns: SwiftUI "some View"
    func decoratedIcon(_ size: CGFloat, cutTo cutType: DecoratedIconCutType = .shoulder) -> some View {
        // 由于 Lava 强烈反对针对证件照的脸裁切与头裁切，
        // 所以不预设启用该功能。
        var cutType = cutType
        if !AppConfig.cutShouldersForSmallAvatarPhotos {
            cutType = .shoulder
        }
        return EnkaWebIcon(iconString: iconString)
            .scaledToFill()
            .frame(width: size * cutType.rawValue, height: size * cutType.rawValue)
            .clipped()
            .scaledToFit()
            .offset(y: cutType.shiftedAmount(containerSize: size))
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

    /// 显示角色的扑克牌尺寸肖像，以身份证素材裁切而成。
    func cardIcon(_ size: CGFloat) -> some View {
        EnkaWebIcon(iconString: iconString)
            .scaledToFill()
            .frame(width: size * 0.74, height: size)
            .clipped()
            .scaledToFit()
            .background(
                EnkaWebIcon(
                    iconString: namecardIconString
                )
                .scaledToFill()
                .offset(x: size / -3)
            )
            .clipShape(RoundedRectangle(cornerRadius: size / 10))
            .contentShape(RoundedRectangle(cornerRadius: size / 10))
    }
}

extension PlayerDetail.Avatar {
    /// 显示带有背景的角色肖像。
    /// - Parameters:
    ///   - size: 尺寸。
    ///   - cutType: 决定裁切到哪个身体部位。
    /// - Returns: SwiftUI "some View"
    func decoratedIcon(
        _ size: CGFloat,
        cutTo cutType: DecoratedIconCutType = .shoulder
    )
        -> some View {
        character.decoratedIcon(size, cutTo: cutType)
    }

    /// 显示角色的扑克牌尺寸肖像，以身份证素材裁切而成。
    func cardIcon(_ size: CGFloat) -> some View {
        character.cardIcon(size)
    }
}
