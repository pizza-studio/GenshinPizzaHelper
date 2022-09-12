//
//  BasicInfos.swift
//  GenshinPizzaHelper
//
//  Created by Bill Haku on 2022/9/12.
//

import Foundation

struct BasicInfos: Codable {
    var stats: Stats

    struct Stats: Codable {
        var avatarNumber: Int
        var exquisiteChestNumber: Int
        var commonChestNumber: Int
        var wayPointNumber: Int
        var geoculusNumber: Int
        var dendroculusNumber: Int
        var achievementNumber: Int
        var domainNumber: Int
        var activeDayNumber: Int
        var anemoculusNumber: Int
        var luxuriousChestNumber: Int
        var electroculusNumber: Int
        var preciousChestNumber: Int
        var spiralAbyss: String
        var magicChestNumber: Int
    }
}
