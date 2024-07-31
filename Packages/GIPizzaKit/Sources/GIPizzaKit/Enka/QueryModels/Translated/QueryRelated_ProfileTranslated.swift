// (c) 2022 and onwards Pizza Studio (GPL v3.0 License).
// ====================
// This code is released under the GPL v3.0 License (SPDX-License-Identifier: GPL-3.0)

import Combine
import Defaults
import DefaultsKeys
import Foundation
import HBMihoyoAPI

// MARK: - EnkaGI.QueryRelated.ProfileTranslated

extension EnkaGI.QueryRelated {
    public class ProfileTranslated: ObservableObject {
        // MARK: Lifecycle

        // MARK: - 初始化

        public init(
            fetchedModel: EnkaGI.QueryRelated.ProfileRAW,
            theDB: EnkaGI.EnkaDB
        ) {
            self.theDB = theDB
            self.rawInfo = fetchedModel

            self.basicInfo = .init(
                playerInfo: fetchedModel.playerInfo,
                characterMap: theDB.characters
            )
            self.enkaMessage = fetchedModel.message
            self.nextRefreshableDate = Calendar.current.date(
                byAdding: .second,
                value: fetchedModel.ttl ?? 30,
                to: Date()
            )!
            Task.detached { @MainActor in
                self.reinit(firstRun: true) // This updates Avatars.
            }
            cancellables.append(
                theDB.objectWillChange.sink {
                    Task.detached { @MainActor in
                        self.update(newRawInfo: self.rawInfo)
                    }
                }
            )
            cancellables.append(
                Defaults.publisher(.artifactRatingOptions).sink { _ in
                    Task.detached { @MainActor in
                        self.reinit(firstRun: false)
                    }
                }
            )
        }

        // MARK: Public

        public private(set) var theDB: EnkaGI.EnkaDB

        @Published
        public var rawInfo: EnkaGI.QueryRelated.ProfileRAW

        @Published
        public var basicInfo: PlayerInfoTranslated?

        @Published
        public var enkaMessage: String?

        @Published
        public var avatars: [Avatar] = []

        @Published
        public var nextRefreshableDate: Date

        // MARK: Private

        private var cancellables: [AnyCancellable] = []
    }
}

extension EnkaGI.QueryRelated.ProfileTranslated {
    @MainActor
    public func update(
        newRawInfo: EnkaGI.QueryRelated.ProfileRAW, dropExistingData: Bool = false
    ) {
        rawInfo = dropExistingData ? newRawInfo : rawInfo.merge(new: newRawInfo)
        reinit(firstRun: false)
    }

    @MainActor
    internal func reinit(firstRun: Bool = false) {
        if let avatarInfoList = rawInfo.avatarInfoList {
            avatars = avatarInfoList.compactMap { avatarInfo in
                let newAvatar = EnkaGI.QueryRelated.Avatar(
                    avatarInfo: avatarInfo,
                    theDB: theDB,
                    uid: rawInfo.uid
                )
                return newAvatar
            }
        }
        guard firstRun else { return }
        basicInfo = .init(
            playerInfo: rawInfo.playerInfo,
            characterMap: theDB.characters
        )
        enkaMessage = rawInfo.message
        nextRefreshableDate = Calendar.current.date(
            byAdding: .second,
            value: rawInfo.ttl ?? 30,
            to: Date()
        )!
    }
}
