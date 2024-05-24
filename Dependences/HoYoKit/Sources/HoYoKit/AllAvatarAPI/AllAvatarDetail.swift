//
//  File.swift
//
//
//  Created by 戴藏龙 on 2023/10/17.
//

import Foundation

public struct CharacterInventoryModel: Codable, DecodableFromMiHoYoAPIJSONResult, Hashable {
    public struct Avatar: Codable, Equatable, Hashable {
        // MARK: Public

        public struct Costume: Codable, Hashable {
            public var id: Int
            public var name: String
            public var icon: String
        }

        public struct Reliquary: Codable, Hashable {
            // MARK: Public

            public struct Set: Codable, Hashable {
                public struct Affix: Codable, Hashable {
                    // MARK: Public

                    public var activationNumber: Int
                    public var effect: String

                    // MARK: Internal

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

            // MARK: Internal

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

        public struct Weapon: Codable, Hashable {
            // MARK: Public

            public var rarity: Int
            public var icon: String
            public var id: Int
            public var typeName: String
            public var level: Int
            public var affixLevel: Int
            public var type: Int
            public var promoteLevel: Int
            public var desc: String

            // MARK: Internal

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

        public struct Constellation: Codable, Hashable {
            // MARK: Public

            public var effect: String
            public var id: Int
            public var icon: String
            public var name: String
            public var pos: Int
            public var isActived: Bool

            // MARK: Internal

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
            lhs: CharacterInventoryModel.Avatar,
            rhs: CharacterInventoryModel.Avatar
        )
            -> Bool {
            lhs.id == rhs.id
        }

        // MARK: Internal

        enum CodingKeys: String, CodingKey {
            case id
            case element
            case costumes
            case reliquaries
            case level
            case image
            case icon
            case weapon
            case fetter
            case constellations
            case activedConstellationNum = "actived_constellation_num"
            case name
            case rarity
        }
    }

    public var avatars: [Avatar]
}
