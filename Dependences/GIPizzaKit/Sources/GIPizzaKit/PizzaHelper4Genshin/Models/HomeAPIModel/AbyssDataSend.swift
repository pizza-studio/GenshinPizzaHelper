//
//  AbyssData.swift
//  GenshinPizzaHepler
//
//  Created by 戴藏龙 on 2022/10/9.
//

import Foundation
import HBMihoyoAPI
import HoYoKit

// MARK: - AvatarHoldingData

public struct AvatarHoldingData: Codable {
    /// 混淆后的UID的哈希值，用于标记是哪一位玩家打的深境螺旋
    public let uid: String
    /// 深境螺旋期数，格式为年月日+上/下半月，其中上半月用奇数表示，下半月后偶数表示，如"2022101"
    public var updateDate: String
    /// 玩家已解锁角色
    public let owningChars: [Int]
    /// 账号所属服务器ID
    public let serverId: String
}

// MARK: - AbyssData

/// 用于向服务器发送的深境螺旋数据
public struct AbyssData: Codable {
    public struct SubmitDetailModel: Codable {
        /// 深境螺旋层数
        public let floor: Int
        /// 深境螺旋间数
        public let room: Int
        /// 上半间/下半间，1表示上半，2表示下半
        public let half: Int

        /// 使用了哪些角色
        public let usedChars: [Int]
    }

    public struct AbyssRankModel: Codable {
        /// 造成的最高伤害
        public let topDamageValue: Int

        /// 最高伤害的角色ID，下同
        public let topDamage: Int
        public let topTakeDamage: Int
        public let topDefeat: Int
        public let topEUsed: Int
        public let topQUsed: Int
    }

    /// 提交数据的ID
    public var submitId: String = UUID().uuidString

    /// 混淆后的UID的哈希值，用于标记是哪一位玩家打的深境螺旋
    public let uid: String

    /// 提交时间的时间戳since1970
    public var submitTime: Int = .init(Date().timeIntervalSince1970)

    /// 深境螺旋期数，格式为年月日+上/下半月，其中上半月用奇数表示，下半月后偶数表示，如"2022101"
    public var abyssSeason: Int

    /// 账号服务器ID
    public let server: String

    /// 每半间深境螺旋的数据
    public let submitDetails: [SubmitDetailModel]

    /// 深境螺旋伤害等数据的排名统计
    public let abyssRank: AbyssRankModel?

    /// 玩家已解锁角色
    public let owningChars: [Int]

    /// 战斗次数
    public let battleCount: Int

    /// 获胜次数
    public let winCount: Int

    /// 返回结尾只有0或1的abyssSeason信息
    public func getLocalAbyssSeason() -> Int {
        if abyssSeason % 2 == 0 {
            return (abyssSeason / 10) * 10
        } else {
            return (abyssSeason / 10) * 10 + 1
        }
    }
}

extension AbyssData {
    public init?(
        accountUID: String,
        server: Server,
        basicInfo: BasicInfos,
        abyssData: SpiralAbyssDetail,
        which season: AccountSpiralAbyssDetail.WhichSeason
    ) {
        guard abyssData.totalStar == 36 else { return nil }
        let obfuscatedUid =
            "\(accountUID)\(accountUID.md5)\(AppConfig.uidSalt)"
        self.uid = obfuscatedUid.md5
        self.server = server.id

        let component = Calendar.current.dateComponents(
            [.year, .month, .day],
            from: Date(timeIntervalSince1970: Double(abyssData.startTime)!)
        )
        let abyssDataDate =
            Date(timeIntervalSince1970: Double(abyssData.startTime)!)
        let dateFormatter = DateFormatter.Gregorian()
        dateFormatter.dateFormat = "yyyyMM"
        let abyssSeasonStr = dateFormatter.string(from: abyssDataDate)
        guard let abyssSeasonInt = Int(abyssSeasonStr) else {
            return nil
        }
        if component.day! <= 15 {
            let evenNumber = [0, 2, 4, 6, 8]
            self.abyssSeason = abyssSeasonInt * 10 + evenNumber.randomElement()!
        } else {
            let oddNumber = [1, 3, 5, 7, 9]
            self.abyssSeason = abyssSeasonInt * 10 + oddNumber.randomElement()!
        }

        self.owningChars = basicInfo.avatars.map { $0.id }
        self.abyssRank = .init(data: abyssData)
        self.submitDetails = .generateArrayFrom(
            data: abyssData,
            basicInfo: basicInfo
        )
        print(submitDetails.count)
        guard submitDetails.count == 4 * 3 * 2 else {
            print(
                "submitDetails only has \(submitDetails.count), fail to create data"
            )
            return nil
        }
        self.battleCount = abyssData.totalBattleTimes
        self.winCount = abyssData.totalWinTimes
    }
}

extension AbyssData.AbyssRankModel {
    public init?(data: SpiralAbyssDetail) {
        guard [
            data.damageRank.first,
            data.defeatRank.first,
            data.takeDamageRank.first,
            data.energySkillRank.first,
            data.normalSkillRank.first,
        ].allSatisfy({ $0 != nil }) else { return nil }
        topDamageValue = data.damageRank.first?.value ?? 0
        topDamage = data.damageRank.first?.avatarId ?? -1
        topDefeat = data.defeatRank.first?.avatarId ?? -1
        topTakeDamage = data.takeDamageRank.first?.avatarId ?? -1
        topQUsed = data.energySkillRank.first?.avatarId ?? -1
        topEUsed = data.normalSkillRank.first?.avatarId ?? -1
    }
}

extension [AbyssData.SubmitDetailModel] {
    public static func generateArrayFrom(
        data: SpiralAbyssDetail,
        basicInfo: BasicInfos
    )
        -> [AbyssData.SubmitDetailModel] {
        data.floors.flatMap { floor in
            floor.levels.flatMap { level in
                level.battles.compactMap { battle in
                    if floor.gainAllStar {
                        return .init(
                            floor: floor.index,
                            room: level.index,
                            half: battle.index,
                            usedChars: battle.avatars
                                .sorted(by: { $0.id < $1.id }).map { $0.id }
                        )
                    } else { return nil }
                }
            }
        }
    }
}

extension AvatarHoldingData {
    public init?(
        accountUID: String,
        server: Server,
        basicInfo: BasicInfos,
        which season: AccountSpiralAbyssDetail.WhichSeason
    ) {
        let obfuscatedUid =
            "\(accountUID)\(accountUID.md5)\(AppConfig.uidSalt)"
        self.uid = String(obfuscatedUid.md5)

        let formatter = DateFormatter.Gregorian()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.calendar = Calendar(identifier: .gregorian)
        self.updateDate = formatter.string(from: Date())

        self.owningChars = basicInfo.avatars.map { $0.id }
        self.serverId = server.id
    }
}

// MARK: - HuTaoDBAbyssData

public struct HuTaoDBAbyssData: Codable {
    public struct SpiralAbyss: Codable {
        public struct Damage: Codable {
            public var avatarId: Int
            public var aalue: Int
        }

        public struct Floor: Codable {
            public struct Level: Codable {
                public struct Battle: Codable {
                    public var index: Int
                    public var avatars: [Int]
                }

                public var index: Int
                public var star: Int
                public var battles: [Battle]
            }

            public var index: Int
            public var star: Int
            public var levels: [Level]
        }

        public var scheduleId: Int
        public var totalBattleTimes: Int
        public var totalWinTimes: Int
        public var damage: Damage
        public var takeDamage: Damage
        public var floors: [Floor]
    }

    public struct Avatar: Codable {
        public var avatarId: Int
        public var weaponId: Int
        public var reliquarySetIds: [Int]
        public var activedConstellationNumber: Int
    }

    public var uid: String
    public var identity: String
    public var spiralAbyss: SpiralAbyss?
    public var avatars: [Avatar]
    public var reservedUserName: String
}

// MARK: - Constructor (HuTaoDBAbyssData)

extension HuTaoDBAbyssData {
    public init?(
        accountUID: String,
        server: Server,
        cookie: String,
        basicInfo: BasicInfos,
        abyssData: SpiralAbyssDetail,
        allAvatarInfo: AllAvatarDetailModel,
        which season: AccountSpiralAbyssDetail.WhichSeason
    ) async {
        guard abyssData.totalStar == 36 else { return nil }

        self.uid = accountUID
        self.identity = "GenshinPizzaHelper"
        self.reservedUserName = ""

        self.avatars = []
        for myAvatar in basicInfo.avatars {
            guard let avatar = allAvatarInfo.avatars.first(where: { avatar in
                myAvatar.id == avatar.id
            }) else { return nil }
            avatars.append(Avatar(
                avatarId: myAvatar.id,
                weaponId: avatar.weapon.id,
                reliquarySetIds: avatar.reliquaries.map(\.set.id),
                activedConstellationNumber: myAvatar.activedConstellationNum
            ))
        }

        self.spiralAbyss = .init(data: abyssData)
    }
}

// MARK: - Constructor (HuTaoDBAbyssData.SpiralAbyss)

extension HuTaoDBAbyssData.SpiralAbyss {
    public init?(data: SpiralAbyssDetail) {
        guard [
            data.damageRank.first,
            data.defeatRank.first,
            data.takeDamageRank.first,
            data.energySkillRank.first,
            data.normalSkillRank.first,
        ].allSatisfy({ $0 != nil }) else { return nil }
        scheduleId = data.scheduleId
        totalBattleTimes = data.totalBattleTimes
        totalWinTimes = data.totalWinTimes
        self.damage = HuTaoDBAbyssData.SpiralAbyss.Damage(
            avatarId: data.damageRank.first?.avatarId ?? -1,
            aalue: data.damageRank.first?.value ?? -1
        )
        takeDamage = HuTaoDBAbyssData.SpiralAbyss.Damage(
            avatarId: data.takeDamageRank.first?.avatarId ?? -1,
            aalue: data.takeDamageRank.first?.value ?? -1
        )

        floors = []
        for myFloorData in data.floors {
            var levelData = [Floor.Level]()
            for myLevelData in myFloorData.levels {
                var battleData = [Floor.Level.Battle]()
                for myBattleData in myLevelData.battles {
                    battleData.append(Floor.Level.Battle(
                        index: myBattleData.index,
                        avatars: myBattleData.avatars.map { $0.id }
                    ))
                }
                levelData.append(Floor.Level(
                    index: myLevelData.index,
                    star: myLevelData.star,
                    battles: battleData
                ))
            }
            floors.append(Floor(
                index: myFloorData.index,
                star: myFloorData.star,
                levels: levelData
            ))
        }
        if isInsane() { return nil }
    }
}

// MARK: - HuTaoDBAbyssData Sanity Checkers.

extension HuTaoDBAbyssData.SpiralAbyss.Floor.Level.Battle {
    public var isInsane: Bool { avatars.isEmpty }
}

extension HuTaoDBAbyssData.SpiralAbyss.Floor.Level {
    public mutating func isInsane() -> Bool { selfTidy() == 0 }

    @discardableResult
    public mutating func selfTidy() -> Int {
        battles = battles.filter { !$0.isInsane }
        return battles.count
    }
}

extension HuTaoDBAbyssData.SpiralAbyss.Floor {
    public mutating func isInsane() -> Bool { selfTidy() == 0 }

    @discardableResult
    public mutating func selfTidy() -> Int {
        levels = levels.compactMap { level in
            var level = level
            level.selfTidy()
            return level.isInsane() ? nil : level
        }
        return levels.count
    }
}

extension HuTaoDBAbyssData.SpiralAbyss {
    public mutating func isInsane() -> Bool { selfTidy() == 0 }

    @discardableResult
    public mutating func selfTidy() -> Int {
        floors = floors.compactMap { floor in
            var floor = floor
            floor.selfTidy()
            return floor.isInsane() ? nil : floor
        }
        return floors.count
    }
}

extension HuTaoDBAbyssData {
    public mutating func sanityCheck() -> Bool {
        guard var abyss = spiralAbyss else { return true }
        let sanityResult = abyss.selfTidy()
        spiralAbyss = (sanityResult == 0) ? nil : abyss
        return spiralAbyss == nil
    }
}
