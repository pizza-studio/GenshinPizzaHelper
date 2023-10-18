//
//  File.swift
//  
//
//  Created by 戴藏龙 on 2023/10/17.
//

import Foundation

public struct AllAvatarDetailModel: Codable, DecodableFromMiHoYoAPIJSONResult {
    public struct Avatar: Codable, Equatable {
        public struct Costume: Codable {
            public var id: Int
            public var name: String
            public var icon: String
        }

        public struct Reliquary: Codable {
            public struct Set: Codable {
                public struct Affix: Codable {
                    public var activationNumber: Int
                    public var effect: String

                    enum CodingKeys: String, CodingKey {
                        case activationNumber = "activation_number"
                        case effect
                    }
                }

                public var id: Int
                public var name: String
                public var affixes: [Affix]
            }

            public var pos: Int
            public var rarity: Int
            public var set: Set
            public var id: Int
            public var posName: String
            public var level: Int
            public var name: String
            public var icon: String

            enum CodingKeys: String, CodingKey {
                case pos
                case rarity
                case set
                case id
                case posName = "pos_name"
                case level
                case name
                case icon
            }
        }

        public struct Weapon: Codable {
            public var rarity: Int
            public var icon: String
            public var id: Int
            public var typeName: String
            public var level: Int
            public var affixLevel: Int
            public var type: Int
            public var promoteLevel: Int
            public var desc: String

            enum CodingKeys: String, CodingKey {
                case rarity
                case icon
                case id
                case typeName = "type_name"
                case level
                case affixLevel = "affix_level"
                case type
                case promoteLevel = "promote_level"
                case desc
            }
        }

        public struct Constellation: Codable {
            public var effect: String
            public var id: Int
            public var icon: String
            public var name: String
            public var pos: Int
            public var isActived: Bool

            enum CodingKeys: String, CodingKey {
                case effect
                case id
                case icon
                case name
                case pos
                case isActived = "is_actived"
            }
        }

        public var id: Int
        public var element: String
        public var costumes: [Costume]
        public var reliquaries: [Reliquary]
        public var level: Int
        public var image: String
        public var icon: String
        public var weapon: Weapon
        public var fetter: Int
        public var constellations: [Constellation]
        public var activedConstellationNum: Int
        public var name: String
        public var rarity: Int

        public var isProtagonist: Bool {
            switch id {
            case 10000005, 10000007: return true
            default: return false
            }
        }

        public static func == (
            lhs: AllAvatarDetailModel.Avatar,
            rhs: AllAvatarDetailModel.Avatar
        )
            -> Bool {
            lhs.id == rhs.id
        }

        enum CodingKeys: String, CodingKey {
            case id = "id"
            case element = "element"
            case costumes = "costumes"
            case reliquaries = "reliquaries"
            case level = "level"
            case image = "image"
            case icon = "icon"
            case weapon = "weapon"
            case fetter = "fetter"
            case constellations = "constellations"
            case activedConstellationNum = "actived_constellation_num"
            case name = "name"
            case rarity = "rarity"
        }
    }

    public var avatars: [Avatar]
}
