//
//  PlayerDetail.swift
//  GenshinPizzaHelper
//
//  Created by 戴藏龙 on 2022/10/3.
//

import Foundation

// MARK: - PlayerDetail

struct PlayerDetail {
    // MARK: Lifecycle

    // MARK: - 初始化

    init(
        playerDetailFetchModel: PlayerDetailFetchModel,
        localizedDictionary: [String: String],
        characterMap: [String: ENCharacterMap.Character]
    ) {
        self.basicInfo = .init(
            playerInfo: playerDetailFetchModel.playerInfo,
            characterMap: characterMap
        )
        if let avatarInfoList = playerDetailFetchModel.avatarInfoList {
            self.avatars = avatarInfoList.compactMap { avatarInfo in
                .init(
                    avatarInfo: avatarInfo,
                    localizedDictionary: localizedDictionary,
                    characterDictionary: characterMap
                )
            }
        } else { self.avatars = .init() }
        self.nextRefreshableDate = Calendar.current.date(
            byAdding: .second,
            value: playerDetailFetchModel.ttl ?? 30,
            to: Date()
        )!
    }

    // MARK: Internal

    // MARK: - 本地化工具及其他词典

    // MARK: - Model

    /// 账号基本信息
    struct PlayerBasicInfo {
        // MARK: Lifecycle

        init(
            playerInfo: PlayerDetailFetchModel.PlayerInfo,
            characterMap: [String: ENCharacterMap.Character]
        ) {
            self.nickname = playerInfo.nickname
            self.level = playerInfo.level
            self.signature = playerInfo.signature ?? ""
            self.worldLevel = playerInfo.worldLevel
            self.nameCardId = playerInfo.nameCardId
            self
                .profilePictureAvatarIconString =
                characterMap["\(playerInfo.profilePicture.avatarId)"]?
                    .SideIconName.replacingOccurrences(
                        of: "_Side",
                        with: ""
                    ) ?? ""
            self.showingNameCards = playerInfo.showNameCardIdList ?? []
        }

        // MARK: Internal

        /// 名称
        var nickname: String
        /// 等级
        var level: Int
        /// 签名
        var signature: String
        /// 世界等级
        var worldLevel: Int

        /// 资料名片ID
        var nameCardId: Int
        /// 玩家头像
        var profilePictureAvatarIconString: String

        /// 正在展示的名片
        var showingNameCards: [Int]
    }

    /// 游戏角色
    struct Avatar: Hashable {
        // MARK: Lifecycle

        init?(
            avatarInfo: PlayerDetailFetchModel.AvatarInfo,
            localizedDictionary: [String: String],
            characterDictionary: [String: ENCharacterMap.Character]
        ) {
            guard let character = characterDictionary["\(avatarInfo.avatarId)"]
            else { return nil }

            self.name = localizedDictionary
                .nameFromHashMap(character.NameTextMapHash)
            self.element = AvatarElement(rawValue: character.Element) ?? .unknow

            if let talentIdList = avatarInfo.talentIdList {
                self.talentCount = talentIdList.count
            } else {
                self.talentCount = 0
            }

            self.iconString = character.SideIconName.replacingOccurrences(
                of: "_Side",
                with: ""
            )
            self.sideIconString = character.SideIconName

            self.skills = character.SkillOrder.map { skillID in
                let level = avatarInfo.skillLevelMap.skillLevel
                    .first { key, _ in
                        key == String(skillID)
                    }?.value ?? 0
                let icon = character.Skills
                    .skillData[String(skillID)] ?? "unknow"
                return Skill(
                    name: localizedDictionary.nameFromHashMap(skillID),
                    level: level,
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
                    localizedDictionary: localizedDictionary
                )
            }

            self.fightPropMap = avatarInfo.fightPropMap

            self.level = Int(avatarInfo.propMap.level.val) ?? 0
            self.quality = .init(rawValue: character.QualityType) ?? .purple
        }

        // MARK: Internal

        // Model
        /// 天赋
        struct Skill: Hashable {
            /// 天赋名字(字典没有，暂时无法使用)
            let name: String
            /// 天赋等级
            let level: Int
            /// 天赋图标ID
            let iconString: String

            /// 设定杂凑方法
            func hash(into hasher: inout Hasher) {
                hasher.combine(name)
                hasher.combine(level)
                hasher.combine(iconString)
            }
        }

        /// 武器
        struct Weapon {
            // MARK: Lifecycle

            init?(
                weaponEquipment: PlayerDetailFetchModel.AvatarInfo.EquipList,
                localizedDictionary: [String: String]
            ) {
                guard weaponEquipment.flat.itemType == "ITEM_WEAPON"
                else { return nil }
                self.name = localizedDictionary
                    .nameFromHashMap(weaponEquipment.flat.nameTextMapHash)
                self.level = weaponEquipment.weapon!.level
                self
                    .refinementRank = (
                        weaponEquipment.weapon!.affixMap?.affix
                            .first?.value ?? 0
                    ) + 1

                let mainAttributeName: String = PropertyDictionary
                    .getLocalizedName("FIGHT_PROP_BASE_ATTACK")
                let mainAttributeValue: Double = weaponEquipment.flat
                    .weaponStats?.first(where: { stats in
                        stats.appendPropId == "FIGHT_PROP_BASE_ATTACK"
                    })?.statValue ?? 0
                self.mainAttribute = .init(
                    name: mainAttributeName,
                    value: mainAttributeValue
                )

                if weaponEquipment.flat.weaponStats?.first(where: { stats in
                    stats.appendPropId != "FIGHT_PROP_BASE_ATTACK"
                }) != nil {
                    let subAttributeName: String = PropertyDictionary
                        .getLocalizedName(
                            weaponEquipment.flat.weaponStats?
                                .first(where: { stats in
                                    stats
                                        .appendPropId !=
                                        "FIGHT_PROP_BASE_ATTACK"
                                })?.appendPropId ?? ""
                        )
                    let subAttributeValue: Double = weaponEquipment.flat
                        .weaponStats?.first(where: { stats in
                            stats.appendPropId != "FIGHT_PROP_BASE_ATTACK"
                        })?.statValue ?? 0
                    self.subAttribute = .init(
                        name: subAttributeName,
                        value: subAttributeValue
                    )
                } else {
                    self.subAttribute = nil
                }

                self.iconString = weaponEquipment.flat.icon

                self
                    .rankLevel = .init(
                        rawValue: weaponEquipment.flat
                            .rankLevel
                    ) ?? .four
            }

            // MARK: Internal

            /// 武器名字
            let name: String
            /// 武器等级
            let level: Int
            /// 精炼等阶 (1-5)
            let refinementRank: Int
            /// 武器主属性
            let mainAttribute: Attribute
            /// 武器副属性
            let subAttribute: Attribute?
            /// 武器图标ID
            let iconString: String
            /// 武器星级
            let rankLevel: RankLevel

            /// 突破后武器图标ID
            var awakenedIconString: String { "\(iconString)_Awaken" }
        }

        /// 圣遗物
        struct Artifact: Identifiable, Equatable {
            // MARK: Lifecycle

            init?(
                artifactEquipment: PlayerDetailFetchModel.AvatarInfo.EquipList,
                localizedDictionary: [String: String]
            ) {
                guard artifactEquipment.flat.itemType == "ITEM_RELIQUARY"
                else { return nil }
                self.id = artifactEquipment.flat.nameTextMapHash
                self.name = localizedDictionary
                    .nameFromHashMap(artifactEquipment.flat.nameTextMapHash)
                self.setName = localizedDictionary
                    .nameFromHashMap(artifactEquipment.flat.setNameTextMapHash!)
                self.mainAttribute = Attribute(
                    name: PropertyDictionary
                        .getLocalizedName(
                            artifactEquipment.flat
                                .reliquaryMainstat!.mainPropId
                        ),
                    value: artifactEquipment.flat.reliquaryMainstat!.statValue
                )
                self.subAttributes = artifactEquipment.flat.reliquarySubstats?
                    .map { stats in
                        Attribute(
                            name: PropertyDictionary
                                .getLocalizedName(stats.appendPropId),
                            value: stats.statValue
                        )
                    } ?? []
                self.iconString = artifactEquipment.flat.icon
                self
                    .artifactType = .init(
                        rawValue: artifactEquipment.flat
                            .equipType ?? ""
                    ) ?? .flower
                self
                    .rankLevel =
                    .init(
                        rawValue: artifactEquipment.flat
                            .rankLevel
                    ) ?? .five
                self.level = max(
                    (artifactEquipment.reliquary?.level ?? 1) - 1,
                    0
                )
            }

            // MARK: Internal

            enum ArtifactType: String, CaseIterable {
                case flower = "EQUIP_BRACER"
                case plume = "EQUIP_NECKLACE"
                case sand = "EQUIP_SHOES"
                case goblet = "EQUIP_RING"
                case circlet = "EQUIP_DRESS"
            }

            let id: String

            /// 圣遗物名字（词典没有，暂不可用）
            let name: String
            /// 所属圣遗物套装的名字
            let setName: String
            /// 圣遗物的主属性
            let mainAttribute: Attribute
            /// 圣遗物的副属性
            let subAttributes: [Attribute]
            /// 圣遗物图标ID
            let iconString: String
            /// 圣遗物所属部位
            let artifactType: ArtifactType
            /// 圣遗物等级
            let level: Int
            /// 圣遗物星级
            let rankLevel: RankLevel

            static func == (
                lhs: PlayerDetail.Avatar.Artifact,
                rhs: PlayerDetail.Avatar.Artifact
            )
                -> Bool {
                lhs.id == rhs.id
            }
        }

        /// 任意属性
        struct Attribute {
            // MARK: Lifecycle

            init(name: String, value: Double) {
                self.name = name
                self.value = value
            }

            /// 属性图标的ID
//            let iconString: String

            // MARK: Internal

            let name: String
            var value: Double

            var valueString: String {
                if floor(value) == value {
                    return "\(Int(value))"
                } else {
                    return String(format: "%.1f", value)
                }
            }
        }

        /// 元素类型
        enum AvatarElement: String {
            case ice = "Ice"
            case wind = "Wind"
            case electric = "Electric"
            case water = "Water"
            case fire = "Fire"
            case rock = "Rock"
            case grass = "Grass"
            case unknow
        }

        /// 角色星级，橙色为四星，紫色为五星
        enum Quality: String {
            /// 紫色，四星角色
            case purple = "QUALITY_PURPLE"
            /// 橙色，五星角色
            case orange = "QUALITY_ORANGE"
            /// 特殊橙色，埃洛伊
            case orangeSpecial = "QUALITY_ORANGE_SP"
        }

        /// 名字
        let name: String
        /// 元素
        let element: AvatarElement
        /// 命之座等级 (0-6)
        let talentCount: Int
        /// 天赋
        let skills: [Skill]

        /// 等级
        let level: Int

        /// 武器
        let weapon: Weapon
        /// 圣遗物
        let artifacts: [Artifact]

        /// 角色属性
        let fightPropMap: FightPropMap

        /// 正脸图
        let iconString: String
        /// 侧脸图
        let sideIconString: String
        let quality: Quality

        /// 名片
        var namecardIconString: String {
            // 主角没有对应名片
            if nameID == "PlayerGirl" || nameID == "PlayerBoy" {
                return "UI_NameCardPic_Bp2_P"
            } else if nameID == "Yae" {
                return "UI_NameCardPic_Yae1_P"
            } else {
                return "UI_NameCardPic_\(nameID)_P"
            }
        }

        static func == (
            lhs: PlayerDetail.Avatar,
            rhs: PlayerDetail.Avatar
        )
            -> Bool {
            lhs.hashValue == rhs.hashValue
        }

        func hash(into hasher: inout Hasher) {
            hasher.combine(name)
        }

        // MARK: Private

        /// 英文名ID（用于图标）
        private var nameID: String {
            iconString.replacingOccurrences(of: "UI_AvatarIcon_", with: "")
        }
    }

    enum PlayerDetailError: Error {
        case failToGetLocalizedDictionary
        case failToGetCharacterDictionary
        case failToGetCharacterData(message: String)
        case refreshTooFast(dateWhenRefreshable: Date)
    }

    let nextRefreshableDate: Date

    let basicInfo: PlayerBasicInfo

    let avatars: [Avatar]
}

extension Dictionary where Key == String, Value == String {
    fileprivate func nameFromHashMap(_ hashID: Int) -> String {
        self["\(hashID)"] ?? "unknow"
    }

    fileprivate func nameFromHashMap(_ hashID: String) -> String {
        self[hashID] ?? "unknow"
    }
}

// MARK: - RankLevel

enum RankLevel: Int {
    case one = 1, two = 2, three = 3, four = 4, five = 5

    // MARK: Internal

    var rectangularBackgroundIconString: String {
        "UI_QualityBg_\(rawValue)"
    }

    var squaredBackgroundIconString: String {
        "UI_QualityBg_\(rawValue)s"
    }
}
