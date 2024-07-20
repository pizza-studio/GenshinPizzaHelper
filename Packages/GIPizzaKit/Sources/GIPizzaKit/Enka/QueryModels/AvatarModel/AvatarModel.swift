// (c) 2022 and onwards Pizza Studio (GPL v3.0 License).
// ====================
// This code is released under the GPL v3.0 License (SPDX-License-Identifier: GPL-3.0)

import Foundation
import HBMihoyoAPI

// MARK: - EnkaGI.QueryRelated.Avatar

extension EnkaGI.QueryRelated {
    /// 游戏角色
    public class Avatar {
        // MARK: Lifecycle

        public init?(
            avatarInfo: EnkaGI.QueryRelated.FetchModel.AvatarInfo,
            localizedDictionary: EnkaGI.DBModels.LocTable,
            characterDictionary: EnkaGI.DBModels.CharacterDict,
            uid: String?
        ) {
            guard let character =
                characterDictionary[
                    "\(avatarInfo.avatarId)-\(avatarInfo.skillDepotId)"
                ] ??
                characterDictionary["\(avatarInfo.avatarId)"]
            else { return nil }
            self.character = character
            self.enkaID = avatarInfo.avatarId
            self.characterAsset = CharacterAsset.match(id: avatarInfo.avatarId)
            self.costumeAsset = .init(rawValue: avatarInfo.costumeId ?? -213)

            self.name = localizedDictionary
                .nameFromHashMap(character.NameTextMapHash)

            self
                .element = EnkaGI.QueryRelated.Avatar.TeyvatElement(rawValue: character.Element) ??
                .physico

            if let talentIdList = avatarInfo.talentIdList {
                self.constellation = talentIdList.count
            } else {
                self.constellation = 0
            }

            self.iconString = character.SideIconName.replacingOccurrences(
                of: "_Side",
                with: ""
            )
            self.sideIconString = character.SideIconName

            self.skills = character.SkillOrder.compactMap { skillID in
                let rawLevel = avatarInfo.skillLevelMap[skillID.description] ?? 0
                guard rawLevel > 0 else { return nil } // 原生等级从 1 开始算。
                let icon = character.Skills[skillID.description] ??
                    "UI_Talent_Combine_Skill_ExtraItem"
                // 从 proudSkillExtraLevelMap 获取所有可能的天赋等级加成数据。
                var adjustedDelta = avatarInfo
                    .proudSkillExtraLevelMap?[(
                        character.ProudMap[skillID.description] ?? 0
                    ).description] ?? 0
                // 对该笔天赋等级加成数据做去余处理，以图仅保留命之座天赋加成。
                adjustedDelta = adjustedDelta - adjustedDelta % 3
                return Skill(
                    name: localizedDictionary.nameFromHashMap(skillID),
                    level: rawLevel,
                    levelAdjusted: rawLevel + adjustedDelta,
                    iconString: icon
                )
            }

            guard let weaponEquipment = avatarInfo.equipList
                .first(where: { equipment in
                    equipment.flat.itemType == "ITEM_WEAPON"
                }) else { return nil }
            self.weapon = .init(
                weaponEquipment: weaponEquipment,
                localizedDictionary: localizedDictionary
            )!

            self.artifacts = avatarInfo.equipList.filter { equip in
                equip.flat.itemType == "ITEM_RELIQUARY"
            }.compactMap { artifactEquipment in
                .init(
                    artifactEquipment: artifactEquipment,
                    localizedDictionary: localizedDictionary,
                    score: nil
                )
            }

            self.fightPropMap = avatarInfo.fightPropMap

            self.level = Int(avatarInfo.propMap.level.val) ?? 0
            self.quality = .init(rawValue: character.QualityType) ?? .purple
            let uid = uid ?? ""
            let obfuscatedUid =
                "\(uid)\(uid.md5)\(AppConfig.uidSalt)"
            self.uid = String(obfuscatedUid.md5)
            fetchArtifactRatings(collect: true)
        }

        // MARK: Public

        /// 名字
        public let name: String
        /// 元素
        public let element: TeyvatElement
        /// 命之座等级 (0-6)
        public let constellation: Int
        /// 天赋
        public let skills: [Skill]

        /// 时装
        public let costumeAsset: CostumeAsset?
        /// 角色 Asset
        public let characterAsset: CharacterAsset

        /// 等级
        public let level: Int

        /// 武器
        public let weapon: Weapon
        /// 圣遗物
        public var artifacts: [Artifact]
        /// 圣遗物总分
        public var artifactTotalScore: Double?
        /// 圣遗物评价
        public var artifactScoreRank: String?

        /// 角色属性
        public let fightPropMap: EnkaGI.QueryRelated.FightPropMap

        /// 正脸图
        public let iconString: String
        /// 侧脸图
        public let sideIconString: String
        public let quality: Quality

        /// Enka Character ID
        public let enkaID: Int
        /// UID
        public let uid: String

        /// 原始 character 資料備份。
        public let character: EnkaGI.Character

        /// 经过错字订正处理的角色姓名
        public var nameCorrected: String {
            CharacterAsset.match(id: enkaID).localized.localizedWithFix
        }

        public var nameCorrectedAndTruncated: String {
            let rawName = nameCorrected
            let finalName = NSMutableString()
            let maxCharsKept = 18
            var charsAdded = 0
            var isTruncated = false
            var charsLeft = rawName.count
            loopCheck: for char in rawName {
                finalName.append(char.description)
                charsAdded += char.description.containsKanjiOrKana ? 2 : 1
                charsLeft -= 1
                if charsAdded >= maxCharsKept {
                    if charsLeft != 0 {
                        isTruncated = true
                    }
                    break loopCheck
                }
            }
            if isTruncated {
                finalName.append("…")
            }
            return finalName.description
        }

        /// 名片
        public var namecardIconString: String {
            // 主角没有对应名片
            if nameID == "PlayerGirl" || nameID == "PlayerBoy" {
                return "UI_NameCardPic_Bp2_P"
            } else if nameID == "Yae" {
                return "UI_NameCardPic_Yae1_P"
            } else {
                return "UI_NameCardPic_\(nameID)_P"
            }
        }

        public func fetchArtifactRatings(collect: Bool = false) {
            print("Get artifact rating of \(name)")
            let artifactsModel = convert2ArtifactRatingModel()
            if let artifactScores = ArtifactRating.Appraiser(request: artifactsModel).evaluate() {
                artifactTotalScore = artifactScores.allpt
                artifactScoreRank = artifactScores.result
                for index in 0 ..< artifacts.count {
                    switch artifacts[index].artifactType {
                    case .flower:
                        artifacts[index].score = artifactScores
                            .stat1pt
                    case .plume:
                        artifacts[index].score = artifactScores
                            .stat2pt
                    case .sands:
                        artifacts[index].score = artifactScores
                            .stat3pt
                    case .goblet:
                        artifacts[index].score = artifactScores
                            .stat4pt
                    case .circlet:
                        artifacts[index].score = artifactScores
                            .stat5pt
                    }
                }
            }
            DispatchQueue.global(qos: .background).async {
                guard collect else { return }
                // 要上传的记录资料得忽略掉任何评分加成选项。
                let retrieved = ArtifactRating.Appraiser(request: artifactsModel, options: .allDisabled).evaluate()
                guard let retrieved = retrieved else { return }
                print("Uploading artifact rating for \(self.name)")
                // upload data to opserver
                let encoder = JSONEncoder()
                encoder.outputFormatting = .sortedKeys
                let dataToCollect = retrieved.convertToCollectionModel(uid: self.uid, charId: String(self.enkaID))
                let data = try! encoder.encode(dataToCollect)
                let md5 = String(data: data, encoding: .utf8)!.md5
                guard !UPLOAD_HOLDING_DATA_LOCKED
                else {
                    print("uploadArtifactScoreDataLocked is locked")
                    return
                }
                API.PSAServer.uploadUserData(
                    path: "/artifact_rank/upload",
                    data: data
                ) { result in
                    switch result {
                    case .success:
                        print("uploadArtifactData SUCCEED")
                        print(md5)
                    case let .failure(error):
                        switch error {
                        case let .uploadError(message):
                            if message == "Insert Failed" {
                                print(message)
                            }
                        default:
                            break
                        }
                    }
                }
            }
        }

        // MARK: Private

        /// 英文名ID（用于图标）
        private var nameID: String {
            iconString.replacingOccurrences(of: "UI_AvatarIcon_", with: "")
        }
    }
}

// MARK: - EnkaGI.QueryRelated.Avatar + Hashable, Equatable, Identifiable

extension EnkaGI.QueryRelated.Avatar: Hashable, Equatable, Identifiable {
    /// Avatar 只会出现在一个展柜内。同一个展柜在理论上不会出现重复的角色。
    /// 所以在这里用用 name 当 id 已经足够了。
    public var id: String { name }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(name)
        hasher.combine(element)
        hasher.combine(constellation)
        hasher.combine(skills)
        hasher.combine(costumeAsset)
        hasher.combine(characterAsset)
        hasher.combine(level)
        hasher.combine(weapon)
        hasher.combine(artifacts)
        hasher.combine(artifactTotalScore)
        hasher.combine(artifactScoreRank)
        hasher.combine(fightPropMap)
        hasher.combine(iconString)
        hasher.combine(sideIconString)
        hasher.combine(quality)
        hasher.combine(enkaID)
        hasher.combine(uid)
        hasher.combine(character)
    }

    public static func == (
        lhs: EnkaGI.QueryRelated.Avatar,
        rhs: EnkaGI.QueryRelated.Avatar
    )
        -> Bool {
        lhs.hashValue == rhs.hashValue
    }
}
