//
//  File.swift
//
//
//  Created by ShikiSuen on 2024/1/22.
//

import Foundation

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
