// (c) 2022 and onwards Pizza Studio (GPL v3.0 License).
// ====================
// This code is released under the GPL v3.0 License (SPDX-License-Identifier: GPL-3.0)

import Defaults
import GIPizzaKit
import SwiftUI

extension CharacterAsset {
    /// 显示角色的扑克牌尺寸肖像，以身份证素材裁切而成。
    @ViewBuilder
    public func cardIcon(
        _ size: CGFloat,
        costume: CostumeAsset? = nil,
        namecard givenNameCard: NameCard? = nil
    )
        -> some View {
        CharacterIconView(
            size,
            char: self,
            costume: costume,
            cutType: .card,
            namecard: namecard,
            forceRoundRect: false
        )
    }

    /// 显示带有背景的角色肖像。
    /// - Parameters:
    ///   - size: 尺寸。
    ///   - cutType: 决定裁切到哪个身体部位。
    /// - Returns: SwiftUI "some View"
    @ViewBuilder
    public func decoratedIcon(
        _ size: CGFloat,
        cutTo cutType: DecoratedIconCutType = .shoulder,
        costume: CostumeAsset? = nil,
        namecard givenNameCard: NameCard? = nil,
        roundRect: Bool = false
    )
        -> some View {
        CharacterIconView(
            size,
            char: self,
            costume: costume,
            cutType: cutType,
            namecard: namecard,
            forceRoundRect: roundRect
        )
    }
}

// MARK: - CharacterIconView

public struct CharacterIconView: View {
    // MARK: Lifecycle

    public init(
        _ size: CGFloat,
        char character: CharacterAsset,
        costume: CostumeAsset? = nil,
        cutType: DecoratedIconCutType,
        namecard: NameCard? = nil,
        forceRoundRect: Bool = false
    ) {
        self.size = size
        self.cutType = cutType
        self.nameCard = namecard
        self.character = character
        self.forceRoundRect = forceRoundRect
        // 由于 Lava 强烈反对针对证件照的脸裁切与头裁切，
        // 所以不预设启用该功能。
        self.costume = costume ?? CharacterAsset.costumeMap[character]
    }

    // MARK: Public

    public var body: some View {
        cuttedCharacterImage
            .background(background)
            .clipShape(clipContentShape)
            .contentShape(clipContentShape)
            .compositingGroup()
    }

    // MARK: Internal

    @ViewBuilder
    var cuttedCharacterImage: some View {
        let imageAssetName = costume?.frontPhotoFileName ?? character.frontPhotoFileName
        let characterImage = EnkaWebIcon(iconString: imageAssetName).scaledToFill()
        switch cutType {
        case .card: characterImage
            .frame(width: size * 0.74, height: size)
            .clipped()
            .scaledToFit()
        default: characterImage
            .frame(width: size * cutTypeGuarded.rawValue, height: size * cutTypeGuarded.rawValue)
            .clipped()
            .scaledToFit()
            .offset(y: cutTypeGuarded.shiftedAmount(containerSize: size))
            .frame(width: size, height: size)
        }
    }

    var background: some View {
        EnkaWebIcon(iconString: (nameCard ?? character.namecard).fileName)
            .scaledToFill()
            .offset(x: size / -3)
    }

    // MARK: Private

    private let cutType: DecoratedIconCutType
    private let size: CGFloat
    private let nameCard: NameCard?
    private let character: CharacterAsset
    private let costume: CostumeAsset?
    private let forceRoundRect: Bool

    @Default(.cutShouldersForSmallAvatarPhotos)
    private var cutShouder: Bool

    private var clipContentShape: RoundedRectangle {
        RoundedRectangle(cornerRadius: cornerRadius)
    }

    private var cornerRadius: CGFloat {
        switch cutTypeGuarded {
        case .card: return size / 10
        default:
            let roundRectRatio = 179.649 / 1024
            return forceRoundRect ? (roundRectRatio * size) : (size / 2)
        }
    }

    private var cutTypeGuarded: DecoratedIconCutType {
        guard cutType != .card else { return .card }
        return !cutShouder ? .shoulder : cutType
    }
}
