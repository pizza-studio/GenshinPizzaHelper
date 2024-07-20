// (c) 2022 and onwards Pizza Studio (GPL v3.0 License).
// ====================
// This code is released under the GPL v3.0 License (SPDX-License-Identifier: GPL-3.0)

extension EnkaGI.QueryRelated {
    /// 账号基本信息
    public struct PlayerBasicInfo {
        // MARK: Lifecycle

        public init?(
            playerInfo: EnkaGI.QueryRelated.FetchModel.PlayerInfo?,
            characterMap: EnkaGI.DBModels.CharacterDict
        ) {
            guard let playerInfo = playerInfo else { return nil }
            self.nickname = playerInfo.nickname
            self.level = playerInfo.level
            self.signature = playerInfo.signature ?? ""
            self.worldLevel = playerInfo.worldLevel
            self.finishAchievementNum = playerInfo.finishAchievementNum
            self.towerFloorIndex = playerInfo.towerFloorIndex
            self.towerLevelIndex = playerInfo.towerLevelIndex
            self.nameCardId = playerInfo.nameCardId
            self.showingNameCards = playerInfo.showNameCardIdList ?? []
            self.profilePictureAvatarEnkaID = playerInfo.profilePicture.avatarIdDeducted
            self.profilePictureCostumeID = playerInfo.profilePicture.costumeIdDeducted
            self.profilePictureAvatarIconString = playerInfo.profilePicture.assetFileName
            self.neutralPFPID = playerInfo.profilePicture.id ?? 1
            // 线下资料批配失败的场合（因为线下资料的更新可能会滞后）：
            if profilePictureAvatarIconString == nil {
                if let profilePictureId = playerInfo.profilePicture.id {
                    _ = profilePictureId

                    // 这一段负责处理自 4.1 版发行开始起「有」改过肖像的玩家的情况。
                    // TODO: 需要拿这个 id 在 ProfilePictureExcelConfigData.json 内查询到 avatarId，
                    // 然后按照下述步骤处理即可：
                    // if let obj = ProfilePictureExcelConfigData[profilePictureId] {
                    //     self.profilePictureAvatarIconString = obj.iconPath.replacingOccurrences(of: "_Circle", with: "")
                    // }
                } else if let avatarID = playerInfo.profilePicture.avatarId,
                          let matchedCharacter = characterMap[avatarID.description] {
                    // 这一段负责处理自 4.1 版发行开始起「没」改过肖像的玩家的情况。
                    self.profilePictureAvatarIconString = matchedCharacter.SideIconName.replacingOccurrences(
                        of: "_Side",
                        with: ""
                    )
                }
            }
        }

        // MARK: Public

        /// 名称
        public var nickname: String
        /// 等级
        public var level: Int
        /// 签名
        public var signature: String
        /// 世界等级
        public var worldLevel: Int

        /// 已解锁成就数
        public var finishAchievementNum: Int
        /// 本期深境螺旋层数
        public var towerFloorIndex: Int?
        /// 本期深境螺旋间数
        public var towerLevelIndex: Int?

        /// 资料名片ID
        public var nameCardId: Int
        /// 玩家肖像（与角色强绑定）
        public var profilePictureAvatarIconString: String?
        /// 玩家肖像（与角色不绑定）
        public var neutralPFPID: Int
        /// 玩家头像对应的角色 enkaID
        public var profilePictureAvatarEnkaID: Int?
        /// 玩家头像对应的角色的时装编号 enkaID
        public var profilePictureCostumeID: Int?

        /// 正在展示的名片
        public var showingNameCards: [Int]

        public var towerFloorLevelSimplified: String? {
            guard let floor = towerFloorIndex, let level = towerLevelIndex else { return "nil" }
            return "\(floor)-\(level)"
        }
    }
}
