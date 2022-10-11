//
//  AbyssData.swift
//  GenshinPizzaHepler
//
//  Created by 戴藏龙 on 2022/10/9.
//

import Foundation

/// 用于向服务器发送的深渊数据
struct AbyssData: Codable {
    /// 数据生成的时间
    var date = Date()

    // 玩家ID
    /// 混淆后的UID的哈希值，用于标记是哪一位玩家打的深渊
    let accountID: Int

    // 玩家信息
    /// 账号服务器ID
    let serverID: String
    /// 玩家已解锁角色ID
    let ownAvatarIds: [Avatar]

    /// 描述各期的深渊，一般一轮数据有两期深渊
    var abysses: [Abyss]

    /// 描述一期深渊的类
    struct Abyss: Codable {
        // 深渊期数ID
        /// 本期深渊开始时间戳，可以作为深渊期数的ID
        let abyssStartTimeStamp: Int
        /// 本期深渊结束时间戳
        let abyssEndTimeStamp: Int
        /// 深渊期数ID，每期+1
        let scheduleID: Int

        /// 最深抵达层数
        let achieveFloor: Int
        /// 最深抵达间数
        let achieveLevel: Int

        /// 总挑战次数
        let totalBattleCount: Int
        /// 胜利次数
        let totalWinCount: Int

        // 排名数据
        /// 最高伤害
        var topDamage: CharacterBattleData?
        /// 最多击杀怪物
        var topDefeat: CharacterBattleData?
        /// 最高承伤
        var topTakeDamage: CharacterBattleData?
        /// 使用元素爆发最多
        var topElementalBurstUsed: CharacterBattleData?
        /// 使用元素战技最多
        var topElementalSkillUsed: CharacterBattleData?

        /// 各层数据
        let floors: [Floor]

        /// 每层数据
        struct Floor: Codable {
            /// 是否解锁
            let isUnlock: Bool
            /// 本层获取星数
            let star: Int
            /// 楼层序数，第index层（9,10,11,12）
            let index: Int

            /// 每间战斗数据
            let levels: [Level]

            /// 每间数据
            struct Level: Codable {
                /// 本间获取星数
                let star: Int
                /// 本间序数，第几间
                let index: Int

                /// 上 / 下半间数据
                let battles: [Battle]

                /// 上半 / 下半间数据
                struct Battle: Codable {
                    /// 半间序数，1为上半，2为下半
                    var index: Int
                    /// 半间完成时间戳since1970
                    var timestamp: Int

                    /// 出战角色
                    var avatars: [Avatar]
                }
            }
        }
    }

    struct Avatar: Codable {
        /// 角色ID
        var id: Int
        /// 角色等级
        var level: Int
    }

    /// 角色的某项战斗数值，用于统计排名（伤害排名等）
    struct CharacterBattleData: Codable {
        var avatarID: Int
        var value: Int
    }
}

// MARK: - initializer
extension AbyssData {
    init?(account: Account) {
        guard let basicInfo = account.basicInfo, let abyssData = account.spiralAbyssDetail else { return nil }
        // TODO: 加密方式
        accountID = account.config.uid!.hashValue

        serverID = account.config.server.rawValue

        ownAvatarIds = basicInfo.avatars.map({ avatar in
                .init(id: avatar.id, level: avatar.level)
        })

        abysses = []
        abysses.append(.init(data: abyssData.this))
        abysses.append(.init(data: abyssData.last))
    }
}

extension AbyssData.Abyss {
    init(data: SpiralAbyssDetail) {
        abyssStartTimeStamp = Int(data.startTime) ?? -1
        abyssEndTimeStamp = Int(data.endTime) ?? -1
        scheduleID = data.scheduleId

        achieveFloor = Int(data.maxFloor.split(separator: "-")[0]) ?? -1
        achieveLevel = Int(data.maxFloor.split(separator: "-")[1]) ?? -1

        totalBattleCount = data.totalBattleTimes
        totalWinCount = data.totalWinTimes

        if let topDamageRank = data.damageRank.first {
            topDamage = .init(avatarID: topDamageRank.avatarId, value: topDamageRank.value)
        }
        if let topDefeatRank = data.defeatRank.first {
            topDefeat = .init(avatarID: topDefeatRank.avatarId, value: topDefeatRank.value)
        }
        if let topTakeDamage = data.takeDamageRank.first {
            topDamage = .init(avatarID: topTakeDamage.avatarId, value: topTakeDamage.value)
        }
        if let rank = data.energySkillRank.first {
            topElementalBurstUsed = .init(avatarID: rank.avatarId, value: rank.value)
        }
        if let rank = data.normalSkillRank.first {
            topElementalSkillUsed = .init(avatarID: rank.avatarId, value: rank.value)
        }

        floors = data.floors.map { floorData in
                .init(floorData: floorData)
        }
    }
}

extension AbyssData.Abyss.Floor.Level.Battle {
    init(battleData: SpiralAbyssDetail.Floor.Level.Battle) {
        index = battleData.index
        timestamp = Int(battleData.timestamp) ?? -1
        avatars = battleData.avatars.map({ avatar in
                .init(id: avatar.id, level: avatar.level)
        })
    }
}

extension AbyssData.Abyss.Floor.Level {
    init(levelData: SpiralAbyssDetail.Floor.Level) {
        star = levelData.star
        index = levelData.index
        battles = levelData.battles.map({ battleData in
                .init(battleData: battleData)
        })
    }
}

extension AbyssData.Abyss.Floor {
    init(floorData: SpiralAbyssDetail.Floor) {
        isUnlock = floorData.isUnlock
        star = floorData.star
        index = floorData.index

        levels = floorData.levels.map({ levelData in
                .init(levelData: levelData)
        })
    }
}
