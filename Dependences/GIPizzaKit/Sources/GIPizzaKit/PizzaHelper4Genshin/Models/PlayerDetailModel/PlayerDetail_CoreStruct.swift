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
        PlayerDetailFetchModel: Enka.PlayerDetailFetchModel,
        localizedDictionary: [String: String],
        characterMap: Enka.CharacterMap
    ) {
        self.basicInfo = .init(
            playerInfo: PlayerDetailFetchModel.playerInfo,
            characterMap: characterMap
        )
        self.enkaMessage = PlayerDetailFetchModel.message
        if let avatarInfoList = PlayerDetailFetchModel.avatarInfoList {
            self.avatars = avatarInfoList.compactMap { avatarInfo in
                .init(
                    avatarInfo: avatarInfo,
                    localizedDictionary: localizedDictionary,
                    characterDictionary: characterMap,
                    uid: PlayerDetailFetchModel.uid
                )
            }
        } else { self.avatars = .init() }
        self.nextRefreshableDate = Calendar.current.date(
            byAdding: .second,
            value: PlayerDetailFetchModel.ttl ?? 30,
            to: Date()
        )!
    }

    // MARK: Public

    public let nextRefreshableDate: Date

    public let basicInfo: PlayerBasicInfo?

    public let avatars: [Avatar]

    public let enkaMessage: String?
}
