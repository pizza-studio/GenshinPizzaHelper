//
//  EnkaAPISwiftUIExtensions.swift
//  GenshinPizzaHelper
//
//  Created by ShikiSuen on 2023/4/8.
//

import Foundation
import SwiftUI

// MARK: Enka Character Icons

import GIPizzaKit

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

extension Enka.CharacterMap.Character {
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
        case .unknown:
            return .gray
        }
    }
}

// MARK: - Profile Picture JSON Data Interpreter

extension Enka.PlayerDetailFetchModel.PlayerInfo.ProfilePicture {
    public var assetFileName: String? {
        if let avatarId = avatarId {
            return CharacterAsset.match(id: avatarId).frontPhotoFileName
        }
        guard let id = id else { return nil }
        let matchedCostume = CostumeAsset.allCases.filter {
            $0.profilePictureIdentifier == id
        }.first
        if let matchedCostume = matchedCostume {
            return matchedCostume.frontPhotoFileName
        }
        let matchedAvatar = CharacterAsset.allCases.filter {
            $0.possibleProfilePictureIdentifiers.contains(id)
        }.first
        guard let matchedAvatar = matchedAvatar else { return nil }
        return matchedAvatar.frontPhotoFileName
    }

    public var avatarIdDeducted: Int? {
        guard let id = id else { return avatarId }
        let matchedAvatar = CharacterAsset.allCases.filter {
            $0.possibleProfilePictureIdentifiers.contains(id)
        }.first
        guard let matchedAvatar = matchedAvatar else { return avatarId }
        return matchedAvatar.enkaId
    }

    public var costumeIdDeducted: Int? {
        guard let id = id else { return costumeId ?? avatarId }
        let matchedCostume = CostumeAsset.allCases.filter {
            $0.profilePictureIdentifier == id
        }.first
        guard let matchedCostume = matchedCostume else { return costumeId ?? avatarId }
        return matchedCostume.rawValue
    }
}

// MARK: - Profile Picture Icons

extension PlayerDetail.PlayerBasicInfo {
    @ViewBuilder
    public func cardIcon(_ size: CGFloat) -> some View {
        let charAsset = CharacterAsset.match(id: profilePictureAvatarEnkaID ?? -114_514)
        let costume = CostumeAsset(rawValue: profilePictureCostumeID ?? -114_514) // Nullable
        let givenNameCard = NameCard(rawValue: nameCardId)
        charAsset.cardIcon(size, costume: costume, namecard: givenNameCard)
    }

    @ViewBuilder
    public func decoratedIcon(_ size: CGFloat) -> some View {
        let charAsset = CharacterAsset.match(id: profilePictureAvatarEnkaID ?? -114_514)
        let costume = CostumeAsset(rawValue: profilePictureCostumeID ?? -114_514) // Nullable
        let givenNameCard = NameCard(rawValue: nameCardId)
        charAsset.decoratedIcon(size, cutTo: .head, costume: costume, namecard: givenNameCard)
    }
}
