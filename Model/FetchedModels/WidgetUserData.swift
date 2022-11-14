//
//  File.swift
//  GenshinPizzaHelper
//
//  Created by Bill Haku on 2022/11/14.
//

import Foundation

struct WidgetUserData: Codable {
    var data: WidgetUserDataDetail

    struct WidgetUserDataDetail: Codable {
        var region: String
        var gameRoleId: String
        var backgroundImage: String
        var nickname: String
        var data: [DetailData]
        var gameId: Int
        var level: Int
        var regionName: String

        struct DetailData: Codable {
            var name: String
            var type: String
            var value: String
        }

        func transformToUserData() -> UserData {
            var resin = data.first { $0.name == "原粹树脂" }?.value ?? "-1/0"
            var expedition = data.first { $0.name == "探索派遣"}?.value ?? "-1/0"
            var task = data.first { $0.name == "每日委托进度" }?.value ?? "-1/0"
            var homeCoin = data.first { $0.name == "洞天财瓮" }?.value ?? "-1/0"
            return UserData(resin: resin, expedition: expedition, task: task, homeCoin: homeCoin)
        }
    }
}
