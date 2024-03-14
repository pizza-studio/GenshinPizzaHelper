//
//  EnkaAPISwiftUIExtensions.swift
//  GenshinPizzaHelper
//
//  Created by ShikiSuen on 2023/4/8.
//

import Foundation
import GIPizzaKit
import SwiftUI

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

extension Enka.Character {
    var elementColor: Color {
        guard let element = PlayerDetail.Avatar.AvatarElement(rawValue: Element) else {
            return .pink
        }
        return element.color
    }
}

extension PlayerDetail.Avatar.AvatarElement {
    var color: Color {
        switch self {
        case .cryo:
            return .cyan
        case .anemo:
            return .mint
        case .electro:
            return .indigo
        case .hydro:
            return .blue
        case .pyro:
            return .red
        case .geo:
            return .orange
        case .dendro:
            return .green
        case .physico:
            return .gray
        }
    }
}

// MARK: - Profile Picture Icons

extension PlayerDetail.PlayerBasicInfo {
    @ViewBuilder
    public func cardIcon(_ size: CGFloat) -> some View {
        let charAsset = CharacterAsset.match(id: profilePictureAvatarEnkaID ?? -213)
        let costume = CostumeAsset(rawValue: profilePictureCostumeID ?? -213) // Nullable
        let givenNameCard = NameCard(rawValue: nameCardId)
        charAsset.cardIcon(size, costume: costume, namecard: givenNameCard)
    }

    @ViewBuilder
    public func decoratedIcon(_ size: CGFloat) -> some View {
        let charAsset = CharacterAsset.match(id: profilePictureAvatarEnkaID ?? -213)
        let costume = CostumeAsset(rawValue: profilePictureCostumeID ?? -213) // Nullable
        let givenNameCard = NameCard(rawValue: nameCardId)
        charAsset.decoratedIcon(size, cutTo: .head, costume: costume, namecard: givenNameCard)
    }
}
