//
//  AbyssData.swift
//  GenshinPizzaHepler
//
//  Created by 戴藏龙 on 2022/10/9.
//

import Foundation
import HBMihoyoAPI

// MARK: - AvatarHoldingData

struct AvatarHoldingData: Codable {
    /// 混淆后的UID的哈希值，用于标记是哪一位玩家打的深渊
    let uid: String
    /// 深渊期数，格式为年月日+上/下半月，其中上半月用奇数表示，下半月后偶数表示，如"2022101"
    var updateDate: String
    /// 玩家已解锁角色
    let owningChars: [Int]
    /// 账号所属服务器ID
    let serverId: String
}

// MARK: - AbyssData

/// 用于向服务器发送的深渊数据
struct AbyssData: Codable {
    struct SubmitDetailModel: Codable {
        /// 深渊层数
        let floor: Int
        /// 深渊间数
        let room: Int
        /// 上半间/下半间，1表示上半，2表示下半
        let half: Int

        /// 使用了哪些角色
        let usedChars: [Int]
    }

    struct AbyssRankModel: Codable {
        /// 造成的最高伤害
        let topDamageValue: Int

        /// 最高伤害的角色ID，下同
        let topDamage: Int
        let topTakeDamage: Int
        let topDefeat: Int
        let topEUsed: Int
        let topQUsed: Int
    }

    /// 提交数据的ID
    var submitId: String = UUID().uuidString

    /// 混淆后的UID的哈希值，用于标记是哪一位玩家打的深渊
    let uid: String

    /// 提交时间的时间戳since1970
    var submitTime: Int = .init(Date().timeIntervalSince1970)

    /// 深渊期数，格式为年月日+上/下半月，其中上半月用奇数表示，下半月后偶数表示，如"2022101"
    var abyssSeason: Int

    /// 账号服务器ID
    let server: String

    /// 每半间深渊的数据
    let submitDetails: [SubmitDetailModel]

    /// 深渊伤害等数据的排名统计
    let abyssRank: AbyssRankModel?

    /// 玩家已解锁角色
    let owningChars: [Int]

    /// 战斗次数
    let battleCount: Int

    /// 获胜次数
    let winCount: Int

    /// 返回结尾只有0或1的abyssSeason信息
    func getLocalAbyssSeason() -> Int {
        if abyssSeason % 2 == 0 {
            return (abyssSeason / 10) * 10
        } else {
            return (abyssSeason / 10) * 10 + 1
        }
    }
}

extension AbyssData {
    init?(
        account: Account,
        which season: AccountSpiralAbyssDetail.WhichSeason
    ) {
        guard let abyssData = account.spiralAbyssDetail?.get(season),
              let basicInfo = account.basicInfo
        else { return nil }
        guard abyssData.totalStar == 36 else { return nil }
        let obfuscatedUid =
            "\(account.config.uid!)\(account.config.uid!.md5)\(AppConfig.uidSalt)"
        self.uid = obfuscatedUid.md5
        self.server = account.config.server.id

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
    init?(data: SpiralAbyssDetail) {
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

extension Array where Element == AbyssData.SubmitDetailModel {
    static func generateArrayFrom(
        data: SpiralAbyssDetail,
        basicInfo: BasicInfos
    ) -> [AbyssData.SubmitDetailModel] {
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
    init?(
        account: Account,
        which season: AccountSpiralAbyssDetail.WhichSeason
    ) {
        guard let basicInfo = account.basicInfo else { return nil }
        let obfuscatedUid =
            "\(account.config.uid!)\(account.config.uid!.md5)\(AppConfig.uidSalt)"
        self.uid = String(obfuscatedUid.md5)

        let formatter = DateFormatter.Gregorian()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.calendar = Calendar(identifier: .gregorian)
        self.updateDate = formatter.string(from: Date())

        self.owningChars = basicInfo.avatars.map { $0.id }
        self.serverId = account.config.server.id
    }
}

// MARK: - HuTaoDBAbyssData

struct HuTaoDBAbyssData: Codable {
    struct SpiralAbyss: Codable {
        struct Damage: Codable {
            var avatarId: Int
            var aalue: Int
        }

        struct Floor: Codable {
            struct Level: Codable {
                struct Battle: Codable {
                    var index: Int
                    var avatars: [Int]
                }

                var index: Int
                var star: Int
                var battles: [Battle]
            }

            var index: Int
            var star: Int
            var levels: [Level]
        }

        var scheduleId: Int
        var totalBattleTimes: Int
        var totalWinTimes: Int
        var damage: Damage
        var takeDamage: Damage
        var floors: [Floor]
    }

    struct Avatar: Codable {
        var avatarId: Int
        var weaponId: Int
        var reliquarySetIds: [Int]
        var activedConstellationNumber: Int
    }

    var uid: String
    var identity: String
    var spiralAbyss: SpiralAbyss?
    var avatars: [Avatar]
    var reservedUserName: String
}

// MARK: - Constructor (HuTaoDBAbyssData)

extension HuTaoDBAbyssData {
    init?(
        account: Account,
        which season: AccountSpiralAbyssDetail.WhichSeason
    ) async {
        guard let abyssData = account.spiralAbyssDetail?.get(season),
              let basicInfo = account.basicInfo,
              let uid = account.config.uid,
              let cookie = account.config.cookie
        else { return nil }
        guard abyssData.totalStar == 36 else { return nil }

        let allAvatarInfo = await withCheckedContinuation { continuation in
            MihoyoAPI.fetchAllAvatarInfos(
                region: account.config.server.region,
                serverID: account.config.server.id,
                uid: uid,
                cookie: cookie
            ) { result in
                switch result {
                case let .success(data):
                    continuation.resume(with: .success(data))
                case .failure:
                    break
                }
            }
        }

        self.uid = uid
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
    init?(data: SpiralAbyssDetail) {
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
    var isInsane: Bool { avatars.isEmpty }
}

extension HuTaoDBAbyssData.SpiralAbyss.Floor.Level {
    mutating func isInsane() -> Bool { selfTidy() == 0 }

    @discardableResult
    mutating func selfTidy() -> Int {
        battles = battles.filter { !$0.isInsane }
        return battles.count
    }
}

extension HuTaoDBAbyssData.SpiralAbyss.Floor {
    mutating func isInsane() -> Bool { selfTidy() == 0 }

    @discardableResult
    mutating func selfTidy() -> Int {
        levels = levels.compactMap { level in
            var level = level
            level.selfTidy()
            return level.isInsane() ? nil : level
        }
        return levels.count
    }
}

extension HuTaoDBAbyssData.SpiralAbyss {
    mutating func isInsane() -> Bool { selfTidy() == 0 }

    @discardableResult
    mutating func selfTidy() -> Int {
        floors = floors.compactMap { floor in
            var floor = floor
            floor.selfTidy()
            return floor.isInsane() ? nil : floor
        }
        return floors.count
    }
}

extension HuTaoDBAbyssData {
    mutating func sanityCheck() -> Bool {
        guard var abyss = spiralAbyss else { return true }
        let sanityResult = abyss.selfTidy()
        spiralAbyss = (sanityResult == 0) ? nil : abyss
        return spiralAbyss == nil
    }
}
