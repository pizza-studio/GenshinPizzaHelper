// (c) 2022 and onwards Pizza Studio (GPL v3.0 License).
// ====================
// This code is released under the GPL v3.0 License (SPDX-License-Identifier: GPL-3.0)

import Foundation

// MARK: - EnkaGI.PlayerDetailFetchModel

extension EnkaGI {
    public struct PlayerDetailFetchModel: Codable {
        public struct PlayerInfo: Codable {
            public struct ShowAvatarInfo: Codable {
                /// 角色ID
                public var avatarId: Int
                /// 角色等级
                public var level: Int
                /// 角色皮肤编号
                public var costumeId: Int?
            }

            public struct ProfilePicture: Codable {
                /// 在 ProfilePictureExcelConfigData.json 当中的检索用 ID。
                /// Ref: https://twitter.com/EnkaNetwork/status/1708819830693077325
                public let id: Int?
                /// 旧 API，不要删，否则自 4.1 版发行开始起没改过肖像的玩家会受到影响。
                public var avatarId: Int?
                /// 旧 API，不要删，否则自 4.1 版发行开始起没改过肖像的玩家会受到影响。
                public var costumeId: Int?
            }

            /// 名称
            public var nickname: String
            /// 等级
            public var level: Int
            /// 签名
            public var signature: String?
            /// 世界等级
            public var worldLevel: Int
            /// 资料名片ID
            public var nameCardId: Int
            /// 已解锁成就数
            public var finishAchievementNum: Int
            /// 本期深境螺旋层数
            public var towerFloorIndex: Int?
            /// 本期深境螺旋间数
            public var towerLevelIndex: Int?
            /// 正在展示角色信息列表（ID与等级）
            public var showAvatarInfoList: [ShowAvatarInfo]?
            /// 正在展示名片ID的列表
            public var showNameCardIdList: [Int]?
            /// 玩家头像编号，需要据此在 ProfilePictureExcelConfigData.json 单独查询。
            public var profilePicture: ProfilePicture
        }

        public struct AvatarInfo: Codable {
            public struct PropMap: Codable {
                // MARK: Public

                public struct Exp: Codable {
                    public var type: Int
                    public var ival: String
                }

                public struct LevelStage: Codable {
                    public var type: Int
                    public var ival: String
                    public var val: String?
                }

                public struct Level: Codable {
                    public var type: Int
                    public var ival: String
                    public var val: String
                }

                public var exp: Exp
                /// 等级突破
                public var levelStage: LevelStage
                /// 等级
                public var level: Level

                // MARK: Private

                private enum CodingKeys: String, CodingKey {
                    case exp = "1001"
                    case levelStage = "1002"
                    case level = "4001"
                }
            }

            /// 装备列表的一项，包括武器和圣遗物
            public struct EquipList: Codable {
                /// 圣遗物
                public struct Reliquary: Codable {
                    /// 圣遗物等级
                    public var level: Int
                    /// 圣遗物主属性ID
                    public var mainPropId: Int
                    /// 圣遗物副属性ID的列表
                    public var appendPropIdList: [Int]?
                }

                public struct Weapon: Codable {
                    /// 武器等级
                    public var level: Int
                    /// 武器突破等级
                    public var promoteLevel: Int?
                    /// 武器精炼等级（0-4）
                    public var affixMap: [String: Int]?
                }

                public struct Flat: Codable {
                    public struct ReliquaryMainstat: Codable {
                        public var mainPropId: String
                        public var statValue: Double
                    }

                    public struct ReliquarySubstat: Codable, Hashable {
                        public var appendPropId: String
                        public var statValue: Double
                    }

                    public struct WeaponStat: Codable {
                        public var appendPropId: String
                        public var statValue: Double
                    }

                    /// 装备名的哈希值
                    public var nameTextMapHash: String
                    /// 圣遗物套装名称的哈希值
                    public var setNameTextMapHash: String?
                    /// 装备稀有度
                    public var rankLevel: Int
                    /// 圣遗物主词条
                    public var reliquaryMainstat: ReliquaryMainstat?
                    /// 圣遗物副词条列表
                    public var reliquarySubstats: [ReliquarySubstat]?
                    /// 武器属性列表：包括基础攻击力和副属性
                    public var weaponStats: [WeaponStat]?
                    /// 装备类别：武器、圣遗物
                    public var itemType: String
                    /// 装备名称图标
                    public var icon: String
                    /// 圣遗物类型：花/羽毛/沙漏/杯子/头
                    public var equipType: String?
                }

                /// 物品的ID，武器和圣遗物共用
                public var itemId: Int
                /// 圣遗物
                public var reliquary: Reliquary?
                /// 武器
                public var weapon: Weapon?
                public var flat: Flat
            }

            public struct FetterInfo: Codable {
                public var expLevel: Int
            }

            /// 角色ID
            public var avatarId: Int
            /// 命之座ID列表
            public let talentIdList: [Int]?
            /// 角色属性
            public var propMap: PropMap
            /// 角色战斗属性
            public var fightPropMap: FightPropMap
            /// 角色天赋技能组ID
            public var skillDepotId: Int
            /// 所有固定天赋ID的列表
            public var inherentProudSkillList: [Int]
            /// 天赋等级的字典，skillLevelMap.skillLevel: [天赋ID(String) : 等级(Int)]
            public var skillLevelMap: [String: Int]
            /// 装备列表，包括武器和圣遗物
            public var equipList: [EquipList]
            /// 角色好感等级，fetterInfo.expLevel
            public var fetterInfo: FetterInfo
            /// 角色时装编号（nullable）
            public var costumeId: Int?
            /// 命之座带来的额外技能等级加成
            public var proudSkillExtraLevelMap: [String: Int]?
        }

        /// 账号基本信息
        public var playerInfo: PlayerInfo?
        /// 正在展示的角色的详细信息
        public var avatarInfoList: [AvatarInfo]?
        public var ttl: Int?
        public var uid: String?
        /// Enka 偶尔会返回错误讯息。
        public var message: String?
    }

    // MARK: - FightPropMap

    public struct FightPropMap: Codable, Hashable {
        // MARK: Public

        /// 基础生命
        public var baseHP: Double
        /// 基础攻击力
        public var baseATK: Double
        /// 基础防御力
        public var baseDEF: Double
        /// 暴击率
        public var criticalRate: Double
        /// 暴击伤害
        public var criticalDamage: Double
        /// 元素充能效率
        public var energyRecharge: Double
        /// 治疗加成
        public var healingBonus: Double
        /// 受治疗加成
        public var healedBonus: Double
        /// 元素精通
        public var elementalMastery: Double

        /// 物理伤害加成
        public var physicoDamage: Double
        /// 火元素伤害加成
        public var pyroDamage: Double
        /// 雷元素伤害加成
        public var electroDamage: Double
        /// 水元素伤害加成
        public var hydroDamage: Double
        /// 草元素伤害加成
        public var dendroDamage: Double
        /// 风元素伤害加成
        public var anemoDamage: Double
        /// 岩元素伤害加成
        public var geoDamage: Double
        /// 冰元素伤害加成
        public var cryoDamage: Double

        /// 物理抗性
        public var physicoResistance: Double
        /// 火元素抗性
        public var pyroResistance: Double
        /// 雷元素抗性
        public var electroResistance: Double
        /// 水元素抗性
        public var hydroResistance: Double
        /// 草元素抗性
        public var dendroResistance: Double
        /// 风元素抗性
        public var anemoResistance: Double
        /// 岩元素抗性
        public var geoResistance: Double
        /// 冰元素抗性
        public var cryoResistance: Double

        public var pyroEnergyCost: Double?
        public var electroEnergyCost: Double?
        public var hydroEnergyCost: Double?
        public var dendroEnergyCost: Double?
        public var anemoEnergyCost: Double?
        public var cryoEnergyCost: Double?
        public var geoEnergyCost: Double?

        /// 生命值上限
        public var HP: Double
        /// 攻击力
        public var ATK: Double
        /// 防御力
        public var DEF: Double

        // MARK: Private

        private enum CodingKeys: String, CodingKey {
            case baseHP = "1"
            case baseATK = "4"
            case baseDEF = "7"
            case criticalRate = "20"
            case criticalDamage = "22"
            case energyRecharge = "23"
            case healingBonus = "26"
            case healedBonus = "27"
            case elementalMastery = "28"
            case physicoResistance = "29"
            case physicoDamage = "30"
            case pyroDamage = "40"
            case electroDamage = "41"
            case hydroDamage = "42"
            case dendroDamage = "43"
            case anemoDamage = "44"
            case geoDamage = "45"
            case cryoDamage = "46"
            case pyroResistance = "50"
            case electroResistance = "51"
            case hydroResistance = "52"
            case dendroResistance = "53"
            case anemoResistance = "54"
            case geoResistance = "55"
            case cryoResistance = "56"
            case pyroEnergyCost = "70"
            case electroEnergyCost = "71"
            case hydroEnergyCost = "72"
            case dendroEnergyCost = "73"
            case anemoEnergyCost = "74"
            case cryoEnergyCost = "75"
            case geoEnergyCost = "76"
            case HP = "2000"
            case ATK = "2001"
            case DEF = "2002"
        }
    }
}
