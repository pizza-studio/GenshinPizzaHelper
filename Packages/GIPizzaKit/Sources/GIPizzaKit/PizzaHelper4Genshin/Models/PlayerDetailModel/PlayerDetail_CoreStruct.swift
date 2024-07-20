// (c) 2022 and onwards Pizza Studio (GPL v3.0 License).
// ====================
// This code is released under the GPL v3.0 License (SPDX-License-Identifier: GPL-3.0)

import Foundation
import HBMihoyoAPI

// MARK: - PlayerDetail

public struct PlayerDetail {
    // MARK: Lifecycle

    // MARK: - 初始化

    public init(
        fetchedModel: EnkaGI.PlayerDetailFetchModel,
        localizedDictionary: [String: String],
        characterMap: EnkaGI.CharacterMap
    ) {
        self.rawFetchedData = fetchedModel
        var rawResultTXT = [Int: String]()
        var rawResultMD = [Int: String]()

        self.basicInfo = .init(
            playerInfo: fetchedModel.playerInfo,
            characterMap: characterMap
        )
        self.enkaMessage = fetchedModel.message
        if let avatarInfoList = fetchedModel.avatarInfoList {
            self.avatars = avatarInfoList.compactMap { avatarInfo in
                let newAvatar = Avatar(
                    avatarInfo: avatarInfo,
                    localizedDictionary: localizedDictionary,
                    characterDictionary: characterMap,
                    uid: fetchedModel.uid
                )
                #if !os(watchOS)
                if let newAvatar = newAvatar {
                    rawResultTXT[newAvatar.enkaID] = newAvatar
                        .summarize(locMap: localizedDictionary, useMarkDown: false)
                    rawResultMD[newAvatar.enkaID] = newAvatar.summarize(locMap: localizedDictionary, useMarkDown: true)
                }
                #endif
                return newAvatar
            }
        } else { self.avatars = .init() }
        self.nextRefreshableDate = Calendar.current.date(
            byAdding: .second,
            value: fetchedModel.ttl ?? 30,
            to: Date()
        )!
        self.summariesText = rawResultTXT
        self.summariesMarkDown = rawResultMD
    }

    // MARK: Public

    public let rawFetchedData: EnkaGI.PlayerDetailFetchModel

    public let nextRefreshableDate: Date

    public let basicInfo: PlayerBasicInfo?

    public let avatars: [Avatar]

    public let summariesText: [Int: String]

    public let summariesMarkDown: [Int: String]

    public let enkaMessage: String?
}

extension EnkaGI.CharacterMap {
    public func checkValidity(against fetchedProfile: EnkaGI.PlayerDetailFetchModel) -> Bool {
        let fetchedIDs = Set<String>(fetchedProfile.avatarInfoList?.map(\.avatarId.description) ?? [])
        let allSelfIDs = Set<String>(keys)
        return fetchedIDs.isSubset(of: allSelfIDs)
    }
}
