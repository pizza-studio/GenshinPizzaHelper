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
    case card = 1.000_001
    case head = 1.5
    case face = 2

    // MARK: Internal

    func shiftedAmount(containerSize size: CGFloat) -> CGFloat {
        switch self {
        case .card, .shoulder: return 0
        default: return size / (4 * rawValue)
        }
    }
}

extension EnkaGI.Character {
    var elementColor: Color {
        guard let element = PlayerDetail.Avatar.TeyvatElement(rawValue: Element) else {
            return .pink
        }
        return element.color
    }
}

extension PlayerDetail.Avatar.TeyvatElement {
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
    public func accountProfileIcon(_ size: CGFloat) -> some View {
        if let dataSet = costumedCharAssetDataSet {
            dataSet.characterAsset.decoratedIcon(
                size,
                cutTo: .head,
                costume: dataSet.costume,
                namecard: dataSet.namecard
            )
        } else {
            let placeholder = CharacterAsset.fallbackedValue.decoratedIcon(size, cutTo: .head)
            if let url = EnkaGI.queryProfilePictureURL(pfpID: neutralPFPID.description) {
                AsyncImage(url: url) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: size, height: size, alignment: .center)
                        .clipShape(Circle())
                        .contentShape(Circle())
                        .compositingGroup()
                } placeholder: {
                    CharacterAsset.fallbackedValue.decoratedIcon(size, cutTo: .head)
                }
            } else {
                placeholder
            }
        }
    }

    private var costumedCharAssetDataSet: (
        characterAsset: CharacterAsset,
        costume: CostumeAsset?,
        namecard: NameCard?
    )? {
        guard let profilePictureAvatarEnkaID = profilePictureAvatarEnkaID else { return nil }
        let charAsset = CharacterAsset.match(id: profilePictureAvatarEnkaID)
        let costume = CostumeAsset(rawValue: profilePictureCostumeID ?? -213) // Nullable
        let givenNameCard = NameCard(rawValue: nameCardId) // Nullable
        return (charAsset, costume, givenNameCard)
    }
}
