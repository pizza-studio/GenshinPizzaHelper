//
//  AbyssData.swift
//  GenshinPizzaHepler
//
//  Created by 戴藏龙 on 2022/10/9.
//

import Foundation

/// 用于向服务器发送的深渊数据
struct AbyssData: Codable {
    // 玩家ID
    /// 混淆后的UID，用于标记是哪一位玩家打的深渊
    let accountId: String

    // 玩家信息
    /// 账号服务器ID
    let serverId: String
    /// 玩家等级
//    let playerLevel: Int
    /// 玩家已解锁角色ID
    let lockedAvatarId: [Int]

    // 深渊期数ID
    /// 本期深渊开始时间戳，可以作为深渊期数的ID
    let abyssRefreshTimeStamp: Int
    /// 本期深渊结束时间戳
    let abyssEndTimeStamp: Int
    /// 深渊期数ID，每期+1
    let scheduleId: Int

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
    let topDamage: CharacterBattleData
    /// 最多击杀怪物
    let topDefeat: CharacterBattleData
    /// 最高承伤
    let topTakeDamage: CharacterBattleData
    /// 使用元素爆发最多
    let topElementalBurstUsed: CharacterBattleData
    /// 使用元素战技最多
    let topElementalSkillUsed: CharacterBattleData

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

                struct Avatar: Codable {
                    /// 角色ID
                    var id: Int
                    /// 角色等级
                    var level: Int
                }
            }
        }
    }

    /// 角色的某项战斗数值，用于统计排名（伤害排名等）
    struct CharacterBattleData: Codable {
        var avatarID: Int
        var value: Int
    }
}
