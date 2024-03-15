//
//  PlayerDetail.swift
//  GenshinPizzaHelper
//
//  Created by 戴藏龙 on 2022/10/3.
//

import Foundation
import HBMihoyoAPI

// MARK: - Fetched Models

public typealias PlayerDetailsFetchResult = Result<
    Enka.PlayerDetailFetchModel,
    RequestError
>
public typealias PlayerDetailResult = Result<
    PlayerDetail,
    PlayerDetail.PlayerDetailError
>

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

    // MARK: - 本地化工具及其他词典

    // MARK: - Model

    /// 账号基本信息
    public struct PlayerBasicInfo {
        // MARK: Lifecycle

        public init?(
            playerInfo: Enka.PlayerDetailFetchModel.PlayerInfo?,
            characterMap: Enka.CharacterMap
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
        /// 玩家头像
        public var profilePictureAvatarIconString: String?
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

    /// 游戏角色
    public class Avatar: Hashable {
        // MARK: Lifecycle

        public init?(
            avatarInfo: Enka.PlayerDetailFetchModel.AvatarInfo,
            localizedDictionary: [String: String],
            characterDictionary: Enka.CharacterMap,
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
                .element = AvatarElement(rawValue: character.Element) ??
                .physico

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

            // var artifactScores: ArtifactRating.ScoreResult?
            print("Get artifact rating of \(name)")
            PizzaHelperAPI
                .getArtifactRatingScore(
                    artifacts: convert2ArtifactRatingModel()
                ) { artifactScores in
                    DispatchQueue.main.async {
                        self.artifactTotalScore = artifactScores.allpt
                        self.artifactScoreRank = artifactScores.result
                        for index in 0 ..< self.artifacts.count {
                            switch self.artifacts[index].artifactType {
                            case .flower:
                                self.artifacts[index].score = artifactScores
                                    .stat1pt
                            case .plume:
                                self.artifacts[index].score = artifactScores
                                    .stat2pt
                            case .sands:
                                self.artifacts[index].score = artifactScores
                                    .stat3pt
                            case .goblet:
                                self.artifacts[index].score = artifactScores
                                    .stat4pt
                            case .circlet:
                                self.artifacts[index].score = artifactScores
                                    .stat5pt
                            }
                        }
                    }
                    DispatchQueue.global(qos: .background).async {
                        // upload data to opserver
                        let encoder = JSONEncoder()
                        encoder.outputFormatting = .sortedKeys
                        let artifactScoreCollectData = artifactScores
                            .convertToCollectionModel(
                                uid: self.uid,
                                charId: String(self.enkaID)
                            )
                        let data = try! encoder.encode(artifactScoreCollectData)
                        let md5 = String(data: data, encoding: .utf8)!.md5
                        guard !UPLOAD_HOLDING_DATA_LOCKED
                        else {
                            print(
                                "uploadArtifactScoreDataLocked is locked"
                            ); return
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
        }

        // MARK: Public

        // Model
        /// 天赋
        public struct Skill: Hashable {
            /// 天赋名字(字典没有，暂时无法使用)
            public let name: String
            /// 固有天赋等级
            public let level: Int
            /// 加权天赋等级（被命之座影响过的天赋等级
            public let levelAdjusted: Int
            /// 天赋图标ID
            public let iconString: String

            /// 设定杂凑方法
            public func hash(into hasher: inout Hasher) {
                hasher.combine(name)
                hasher.combine(level)
                hasher.combine(levelAdjusted)
                hasher.combine(iconString)
            }
        }

        /// 武器
        public struct Weapon {
            // MARK: Lifecycle

            init?(
                weaponEquipment: Enka.PlayerDetailFetchModel.AvatarInfo.EquipList,
                localizedDictionary: [String: String]
            ) {
                guard weaponEquipment.flat.itemType == "ITEM_WEAPON"
                else { return nil }
                self.name = localizedDictionary.nameFromHashMap(weaponEquipment.flat.nameTextMapHash)
                self.level = weaponEquipment.weapon!.level
                self.refinementRank = (weaponEquipment.weapon?.affixMap?.first?.value ?? 0) + 1
                self.iconString = weaponEquipment.flat.icon
                self.rankLevel = .init(rawValue: weaponEquipment.flat.rankLevel) ?? .four

                self.mainAttribute = .init(
                    name: AvatarAttribute.baseATK.localized,
                    value: 0,
                    rawName: AvatarAttribute.baseATK.rawValue
                )
                self.subAttribute = nil
                weaponEquipment.flat.weaponStats?.forEach { currentStat in
                    guard let type = AvatarAttribute(rawValue: currentStat.appendPropId) else { return }
                    let localizedAttributeName = type.localized
                    switch type {
                    case .baseATK:
                        self.mainAttribute = .init(
                            name: localizedAttributeName,
                            value: currentStat.statValue,
                            rawName: currentStat.appendPropId
                        )
                    default:
                        self.subAttribute = .init(
                            name: localizedAttributeName,
                            value: currentStat.statValue,
                            rawName: currentStat.appendPropId
                        )
                    }
                }
            }

            // MARK: Public

            /// 武器名字
            public let name: String
            /// 武器等级
            public let level: Int
            /// 精炼等阶 (1-5)
            public let refinementRank: Int
            /// 武器主属性
            public var mainAttribute: Attribute
            /// 武器副属性
            public var subAttribute: Attribute?
            /// 武器图标ID
            public let iconString: String
            /// 武器星级
            public let rankLevel: RankLevel

            /// 突破后武器图标ID
            public var awakenedIconString: String { "\(iconString)_Awaken" }
            /// 经过错字订正处理的武器名称
            public var nameCorrected: String {
                name.localizedWithFix
            }
        }

        /// 圣遗物
        public struct Artifact: Identifiable, Equatable, Hashable {
            // MARK: Lifecycle

            init?(
                artifactEquipment: Enka.PlayerDetailFetchModel.AvatarInfo.EquipList,
                localizedDictionary: [String: String],
                score: Double?
            ) {
                guard artifactEquipment.flat.itemType == "ITEM_RELIQUARY"
                else { return nil }
                self.id = artifactEquipment.flat.nameTextMapHash
                self.name = localizedDictionary
                    .nameFromHashMap(artifactEquipment.flat.nameTextMapHash)
                self.setName = localizedDictionary
                    .nameFromHashMap(artifactEquipment.flat.setNameTextMapHash!)
                self.mainAttribute = Attribute(
                    name: AvatarAttribute
                        .getLocalizedName(
                            artifactEquipment.flat
                                .reliquaryMainstat!.mainPropId
                        ),
                    value: artifactEquipment.flat.reliquaryMainstat!.statValue,
                    rawName: artifactEquipment.flat.reliquaryMainstat!
                        .mainPropId
                )
                self.subAttributes = artifactEquipment.flat.reliquarySubstats?
                    .map { stats in
                        Attribute(
                            name: AvatarAttribute
                                .getLocalizedName(stats.appendPropId),
                            value: stats.statValue,
                            rawName: stats.appendPropId
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
                self.score = score
            }

            // MARK: Public

            public enum ArtifactType: String, CaseIterable {
                case flower = "EQUIP_BRACER"
                case plume = "EQUIP_NECKLACE"
                case sands = "EQUIP_SHOES"
                case goblet = "EQUIP_RING"
                case circlet = "EQUIP_DRESS"
            }

            public let id: String

            /// 圣遗物名字（词典没有，暂不可用）
            public let name: String
            /// 所属圣遗物套装的名字
            public let setName: String
            /// 圣遗物的主属性
            public let mainAttribute: Attribute
            /// 圣遗物的副属性
            public let subAttributes: [Attribute]
            /// 圣遗物图标ID
            public let iconString: String
            /// 圣遗物所属部位
            public let artifactType: ArtifactType
            /// 圣遗物等级
            public let level: Int
            /// 圣遗物星级
            public let rankLevel: RankLevel
            /// 圣遗物评分
            public var score: Double?

            /// 圣遗物套装编号
            public var setId: Int? {
                let arr = iconString.split(separator: "_")
                return arr.count == 4 ? Int(arr[2]) : nil
            }

            public var identifier: String {
                UUID().uuidString
            }

            public static func == (
                lhs: PlayerDetail.Avatar.Artifact,
                rhs: PlayerDetail.Avatar.Artifact
            )
                -> Bool {
                lhs.id == rhs.id
            }

            public func hash(into hasher: inout Hasher) {
                hasher.combine(identifier)
            }
        }

        /// 任意属性
        public struct Attribute {
            // MARK: Lifecycle

            public init(name: String, value: Double, rawName: String) {
                self.name = name
                self.value = value
                self.rawName = rawName
            }

            /// 属性图标的ID
            // let iconString: String

            // MARK: Public

            public let name: String
            public var value: Double
            public let rawName: String

            public var valueString: String {
                let result: NSMutableString
                if floor(value) == value {
                    result = .init(string: "\(Int(value))")
                } else {
                    result = .init(string: String(format: "%.1f", value))
                }
                if let last = name.last, ["％", "%"].contains(last) {
                    result.append("%")
                }
                return result.description
            }

            public var matchedType: AvatarAttribute? {
                .init(rawValue: rawName)
            }
        }

        /// 元素类型
        public enum AvatarElement: String, CaseIterable, Hashable {
            /// 原人
            case physico = "Unknown"
            /// 风
            case anemo = "Wind"
            /// 岩
            case geo = "Rock"
            /// 雷
            case electro = "Electric"
            /// 草
            case dendro = "Grass"
            /// 水
            case hydro = "Water"
            /// 火
            case pyro = "Fire"
            /// 冰
            case cryo = "Ice"

            // MARK: Lifecycle

            public init?(id: Int) {
                switch id {
                case 0: self = .physico
                case 1: self = .anemo
                case 2: self = .geo
                case 3: self = .electro
                case 4: self = .dendro
                case 5: self = .hydro
                case 6: self = .pyro
                case 7: self = .cryo
                default: return nil
                }
            }

            // MARK: Public

            /// 角色元素能力属性，依照原神提瓦特大陆游历顺序起算。物理属性为 0、风属性为 1、岩 2、雷 3，依次类推。
            public var enumerationId: Int {
                switch self {
                case .cryo: 7
                case .anemo: 1
                case .electro: 3
                case .hydro: 5
                case .pyro: 6
                case .geo: 2
                case .dendro: 4
                case .physico: 0
                }
            }
        }

        /// 角色星级，橙色为四星，紫色为五星
        public enum Quality: String {
            /// 紫色，四星角色
            case purple = "QUALITY_PURPLE"
            /// 橙色，五星角色
            case orange = "QUALITY_ORANGE"
            /// 特殊橙色，埃洛伊
            case orangeSpecial = "QUALITY_ORANGE_SP"
        }

        /// 名字
        public let name: String
        /// 元素
        public let element: AvatarElement
        /// 命之座等级 (0-6)
        public let talentCount: Int
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
        public let fightPropMap: Enka.FightPropMap

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
        public let character: Enka.Character

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

        public static func == (
            lhs: PlayerDetail.Avatar,
            rhs: PlayerDetail.Avatar
        )
            -> Bool {
            lhs.hashValue == rhs.hashValue
        }

        public func hash(into hasher: inout Hasher) {
            hasher.combine(name)
        }

        // MARK: Private

        /// 英文名ID（用于图标）
        private var nameID: String {
            iconString.replacingOccurrences(of: "UI_AvatarIcon_", with: "")
        }
    }

    public enum PlayerDetailError: Error {
        case failToGetLocalizedDictionary
        case failToGetCharacterDictionary
        case failToGetCharacterData(message: String)
        case refreshTooFast(dateWhenRefreshable: Date)
    }

    public let nextRefreshableDate: Date

    public let basicInfo: PlayerBasicInfo?

    public let avatars: [Avatar]

    public let enkaMessage: String?
}

extension Dictionary where Key == String, Value == String {
    fileprivate func nameFromHashMap(_ hashID: Int) -> String {
        self["\(hashID)"] ?? "unknown"
    }

    fileprivate func nameFromHashMap(_ hashID: String) -> String {
        self[hashID] ?? "unknown"
    }
}

// MARK: - RankLevel

public enum RankLevel: Int {
    case one = 1, two = 2, three = 3, four = 4, five = 5

    // MARK: Public

    public var rectangularBackgroundIconString: String {
        "UI_QualityBg_\(rawValue)"
    }

    public var squaredBackgroundIconString: String {
        "UI_QualityBg_\(rawValue)s"
    }
}

// MARK: - Artifact Rating Support

extension PlayerDetail.Avatar {
    public func convert2ArtifactRatingModel() -> ArtifactRating.RatingRequest {
        let extractedData = extractArtifactSetData()
        return ArtifactRating.RatingRequest(
            cid: enkaID,
            characterElement: element.enumerationId,
            flower: extractedData[.flower] ?? .init(),
            plume: extractedData[.plume] ?? .init(),
            sands: extractedData[.sands] ?? .init(),
            goblet: extractedData[.goblet] ?? .init(),
            circlet: extractedData[.circlet] ?? .init()
        )
    }

    typealias ArtifactsDataDictionary = [Artifact.ArtifactType: ArtifactRating.RatingRequest.Artifact]

    func extractArtifactSetData() -> ArtifactsDataDictionary {
        var arrResult = ArtifactsDataDictionary()
        artifacts.forEach { thisRawEnkaArtifact in
            var result = ArtifactRating.RatingRequest.Artifact()
            let artifactType = thisRawEnkaArtifact.artifactType
            result.star = thisRawEnkaArtifact.rankLevel.rawValue
            result.setId = thisRawEnkaArtifact.setId ?? -114_514
            result.lv = thisRawEnkaArtifact.level
            // 副词条
            thisRawEnkaArtifact.subAttributes.forEach { thisRawEnkaAttr in
                defer { print("\(thisRawEnkaAttr.rawName)-\(thisRawEnkaAttr.value)") }
                switch AvatarAttribute(rawValue: thisRawEnkaAttr.rawName) {
                case .ATK: result.atk = thisRawEnkaAttr.value
                case .DEF: result.def = thisRawEnkaAttr.value
                case .EM: result.em = thisRawEnkaAttr.value
                case .critRate: result.critRate = thisRawEnkaAttr.value
                case .critDmg: result.critDmg = thisRawEnkaAttr.value
                case .chargeEfficiency: result.er = thisRawEnkaAttr.value
                case .HP: result.hp = thisRawEnkaAttr.value
                case .ATKAmp: result.atkAmp = thisRawEnkaAttr.value
                case .HPAmp: result.hpAmp = thisRawEnkaAttr.value
                case .DEFAmp: result.defAmp = thisRawEnkaAttr.value
                default: break
                }
            }
            // 主词条。
            let mainAttributeType = AvatarAttribute(rawValue: thisRawEnkaArtifact.mainAttribute.rawName)
            switch (artifactType, mainAttributeType) {
            case (.sands, .HPAmp): result.mainProp3 = .hpAmp
            case (.sands, .ATKAmp): result.mainProp3 = .atkAmp
            case (.sands, .DEFAmp): result.mainProp3 = .defAmp
            case (.sands, .EM): result.mainProp3 = .em
            case (.sands, .chargeEfficiency): result.mainProp3 = .er
            case (.sands, _): result.mainProp3 = nil
            case (.goblet, .HPAmp): result.mainProp4 = .hpAmp
            case (.goblet, .ATKAmp): result.mainProp4 = .atkAmp
            case (.goblet, .DEFAmp): result.mainProp4 = .defAmp
            case (.goblet, .EM): result.mainProp4 = .em
            case (.goblet, .dmgAmpPhysico): result.mainProp4 = .dmgAmpPhysico
            case (.goblet, .dmgAmpAnemo): result.mainProp4 = .dmgAmpAnemo
            case (.goblet, .dmgAmpGeo): result.mainProp4 = .dmgAmpGeo
            case (.goblet, .dmgAmpElectro): result.mainProp4 = .dmgAmpElectro
            case (.goblet, .dmgAmpDendro): result.mainProp4 = .dmgAmpDendro
            case (.goblet, .dmgAmpHydro): result.mainProp4 = .dmgAmpHydro
            case (.goblet, .dmgAmpPyro): result.mainProp4 = .dmgAmpPyro
            case (.goblet, .dmgAmpCryo): result.mainProp4 = .dmgAmpCryo
            case (.goblet, _): result.mainProp4 = nil
            case (.circlet, .HPAmp): result.mainProp5 = .hpAmp
            case (.circlet, .ATKAmp): result.mainProp5 = .atkAmp
            case (.circlet, .DEFAmp): result.mainProp5 = .defAmp
            case (.circlet, .EM): result.mainProp5 = .em
            case (.circlet, .critRate): result.mainProp5 = .critRate
            case (.circlet, .critDmg): result.mainProp5 = .critDmg
            case (.circlet, .healAmp): result.mainProp5 = .healingBonus
            case (.circlet, _): result.mainProp5 = nil
            case (_, _): break
            }
            arrResult[artifactType] = result
        }
        return arrResult
    }
}
