//
//  File.swift
//
//
//  Created by 戴藏龙 on 2023/10/17.
//

import Foundation

public struct BasicInfos: Codable, DecodableFromMiHoYoAPIJSONResult {
    // MARK: Public

    public struct Stats: Codable {
        // MARK: Public

        /// 解锁角色数
        public var avatarNumber: Int
        /// 精致宝箱数
        public var exquisiteChestNumber: Int
        /// 普通宝箱数
        public var commonChestNumber: Int
        /// 解锁传送点数量
        public var wayPointNumber: Int
        /// 岩神瞳
        public var geoculusNumber: Int
        /// 草神瞳
        public var dendroculusNumber: Int
        /// 解锁成就数
        public var achievementNumber: Int
        /// 解锁秘境数量
        public var domainNumber: Int
        /// 活跃天数
        public var activeDayNumber: Int
        /// 风神瞳
        public var anemoculusNumber: Int
        /// 华丽宝箱数
        public var luxuriousChestNumber: Int
        /// 雷神瞳
        public var electroculusNumber: Int
        /// 水神瞳
        public var hydroculusNumber: Int
        /// 珍贵宝箱数
        public var preciousChestNumber: Int
        /// 深境螺旋
        public var spiralAbyss: String
        /// 奇馈宝箱数
        public var magicChestNumber: Int

        // MARK: Internal

        enum CodingKeys: String, CodingKey {
            case avatarNumber = "avatar_number"
            case exquisiteChestNumber = "exquisite_chest_number"
            case commonChestNumber = "common_chest_number"
            case wayPointNumber = "way_point_number"
            case geoculusNumber = "geoculus_number"
            case dendroculusNumber = "dendroculus_number"
            case achievementNumber = "achievement_number"
            case domainNumber = "domain_number"
            case activeDayNumber = "active_day_number"
            case anemoculusNumber = "anemoculus_number"
            case luxuriousChestNumber = "luxurious_chest_number"
            case electroculusNumber = "electroculus_number"
            case hydroculusNumber = "hydroculus_number"
            case preciousChestNumber = "precious_chest_number"
            case spiralAbyss = "spiral_abyss"
            case magicChestNumber = "magic_chest_number"
        }
    }

    public struct WorldExploration: Codable {
        // MARK: Public

        public struct Offering: Codable {
            public var name: String
            public var level: Int
            public var icon: String
        }

        public var id: Int
        public var backgroundImage: String
        public var mapUrl: String
        public var parentId: Int
        public var type: String
        public var offerings: [Offering]
        public var level: Int
        public var explorationPercentage: Int
        public var icon: String
        public var innerIcon: String
        public var cover: String
        public var name: String
        public var strategyUrl: String

        // MARK: Internal

        enum CodingKeys: String, CodingKey {
            case id
            case backgroundImage = "background_image"
            case mapUrl = "map_url"
            case parentId = "parent_id"
            case type
            case offerings
            case level
            case explorationPercentage = "exploration_percentage"
            case icon
            case innerIcon = "inner_icon"
            case cover
            case name
            case strategyUrl = "strategy_url"
        }
    }

    public struct Avatar: Codable, Identifiable {
        // MARK: Public

        public var fetter: Int
        public var rarity: Int
        public var cardImage: String
        public var id: Int
        public var isChosen: Bool
        public var element: String
        public var image: String
        public var level: Int
        public var name: String
        public var activedConstellationNum: Int

        // MARK: Internal

        enum CodingKeys: String, CodingKey {
            case fetter
            case rarity
            case cardImage = "card_image"
            case id
            case isChosen = "is_chosen"
            case element
            case image
            case level
            case name
            case activedConstellationNum = "actived_constellation_num"
        }
    }

    public var stats: Stats
    public var worldExplorations: [WorldExploration]
    public var avatars: [Avatar]

    // MARK: Internal

    enum CodingKeys: String, CodingKey {
        case stats
        case worldExplorations = "world_explorations"
        case avatars
    }
}
