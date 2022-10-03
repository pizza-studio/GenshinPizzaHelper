//
//  PlayerDetail.swift
//  GenshinPizzaHelper
//
//  Created by 戴藏龙 on 2022/10/3.
//

import Foundation

struct PlayerDetail {
    let basicInfo: PlayerBasicInfo

    let avatars: [Avatar]

    // MARK: - 初始化
    init(playerDetailFetchModel: PlayerDetailFetchModel, localizedDictionary: [String : String], characterMap: ENCharacterMap) {
        basicInfo = .init(playerInfo: playerDetailFetchModel.playerInfo)
        if let avatarInfoList = playerDetailFetchModel.avatarInfoList {
            avatars = avatarInfoList.map { avatarInfo in
                    .init(avatarInfo: avatarInfo, localizedDictionary: localizedDictionary, characterDictionary: characterMap.characterDetails)!
            }
        } else { avatars = .init() }
    }

    // MARK: - 本地化工具及其他词典


    // MARK: - Model
    /// 账号基本信息
    struct PlayerBasicInfo {
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
        /// 玩家头像的角色的ID
        var profilePictureAvatarID: Int

        init(playerInfo: PlayerDetailFetchModel.PlayerInfo) {
            nickname = playerInfo.nickname
            level = playerInfo.level
            signature = playerInfo.signature
            worldLevel = playerInfo.worldLevel
            nameCardId = playerInfo.nameCardId
            profilePictureAvatarID = playerInfo.profilePicture.avatarId
        }
    }

    /// 游戏角色
    struct Avatar {
        /// 名字
        let name: String
        /// 元素
        let element: AvatarElement
        /// 命之座等级 (0-6)
        let talentCount: Int
        /// 天赋
        let skills: [Skill]

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

        init?(avatarInfo: PlayerDetailFetchModel.AvatarInfo, localizedDictionary: [String : String], characterDictionary: [String : ENCharacterMap.Character]) {
            guard let character = characterDictionary["\(avatarInfo.avatarId)"] else { return nil }

            name = localizedDictionary.nameFromHashMap(character.NameTextMapHash)
            element = AvatarElement.init(rawValue: character.Element) ?? .unknow

            if let talentIdList = avatarInfo.talentIdList {
                talentCount = talentIdList.count
            } else {
                talentCount = 0
            }

            iconString = character.SideIconName.replacingOccurrences(of: "_Side", with: "")
            sideIconString = character.SideIconName

            skills = avatarInfo.skillLevelMap.skillLevel.map { skillID, level in
                let icon = character.Skills.skillData[skillID] ?? "unknow"
                return Skill(name: localizedDictionary.nameFromHashMap(skillID), level: level, iconString: icon)
            }

            guard let weaponEquipment = avatarInfo.equipList.first(where: { equipment in
                equipment.flat.itemType == "ITEM_WEAPON"
            }) else { return nil }
            weapon = .init(weaponEquipment: weaponEquipment, localizedDictionary: localizedDictionary)!

            artifacts = avatarInfo.equipList.filter({ equip in
                equip.flat.itemType == "ITEM_RELIQUARY"
            }).map({ artifactEquipment in
                    .init(artifactEquipment: artifactEquipment, localizedDictionary: localizedDictionary)!
            })

            fightPropMap = avatarInfo.fightPropMap
        }

        // Model
        /// 天赋
        struct Skill {
            /// 天赋名字
            let name: String
            /// 天赋等级
            let level: Int
            /// 天赋图标ID
            let iconString: String
        }
        /// 武器
        struct Weapon {
            /// 武器名字
            let name: String
            /// 武器等级
            let level: Int
            /// 精炼等阶 (1-5)
            let refinementRank: Int
            /// 武器主属性
            let mainAttribute: Attribute
            /// 武器副属性
            let subAttribute: Attribute
            /// 武器图标ID
            let iconString: String

            init?(weaponEquipment: PlayerDetailFetchModel.AvatarInfo.EquipList, localizedDictionary: [String : String]) {
                guard weaponEquipment.flat.itemType == "ITEM_WEAPON" else { return nil }
                name = localizedDictionary.nameFromHashMap(weaponEquipment.flat.nameTextMapHash)
                level = weaponEquipment.weapon!.level
                refinementRank = (weaponEquipment.weapon!.affixMap.affix.first?.value ?? 0) + 1

                let mainAttributeName: String = PropertyDictionary.getLocalizedName("FIGHT_PROP_BASE_ATTACK")
                let mainAttributeValue: Double = weaponEquipment.flat.weaponStats?.first(where: { stats in
                    stats.appendPropId == mainAttributeName
                })?.statValue ?? 0
                mainAttribute = .init(name: mainAttributeName, value: mainAttributeValue)

                let subAttributeName: String = PropertyDictionary.getLocalizedName(weaponEquipment.flat.weaponStats?.first(where: { stats in
                    stats.appendPropId != mainAttributeName
                })?.appendPropId ?? "")
                let subAttributeValue: Double = weaponEquipment.flat.weaponStats?.first(where: { stats in
                    stats.appendPropId == subAttributeName
                })?.statValue ?? 0
                subAttribute = .init(name: subAttributeName, value: subAttributeValue)

                iconString = weaponEquipment.flat.icon
            }
        }
        /// 圣遗物
        struct Artifact {
            /// 圣遗物名字
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

            enum ArtifactType: String, CaseIterable {
                case flower = "EQUIP_BRACER"
                case plume = "EQUIP_NECKLACE"
                case sand = "EQUIP_SHOES"
                case goblet = "EQUIP_RING"
                case circlet = "EQUIP_DRESS"
            }

            init?(artifactEquipment: PlayerDetailFetchModel.AvatarInfo.EquipList, localizedDictionary: [String : String]) {
                guard artifactEquipment.flat.itemType == "ITEM_RELIQUARY" else { return nil }
                name = localizedDictionary.nameFromHashMap(artifactEquipment.flat.nameTextMapHash)
                setName = localizedDictionary.nameFromHashMap(artifactEquipment.flat.setNameTextMapHash!)
                mainAttribute = Attribute(name: PropertyDictionary.getLocalizedName(artifactEquipment.flat.reliquaryMainstat!.mainPropId), value: artifactEquipment.flat.reliquaryMainstat!.statValue)
                subAttributes = artifactEquipment.flat.reliquarySubstats!.map({ stats in
                    Attribute(name: PropertyDictionary.getLocalizedName(stats.appendPropId), value: stats.statValue)
                })
                iconString = artifactEquipment.flat.icon
                artifactType = .init(rawValue: artifactEquipment.flat.equipType ?? "") ?? .flower
            }
        }
        /// 任意属性
        struct Attribute {
            let name: String
            let value: Double
            /// 属性图标的ID
//            let iconString: String
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
    }

    enum PlayerDetailError: Error {
        case failToGetLocalizedDictionary
        case failToGetCharacterDictionary
        case failToGetCharacterData
    }
}

private extension Dictionary where Key == String, Value == String {
    func nameFromHashMap(_ hashID: Int) -> String {
        self["\(hashID)"] ?? "unknow"
    }
    func nameFromHashMap(_ hashID: String) -> String {
        self[hashID] ?? "unknow"
    }
}
