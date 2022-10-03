//
//  ENCharacterMapModel.swift
//  GenshinPizzaHelper
//
//  Created by Bill Haku on 2022/9/24.
//

import Foundation

struct ENCharacterMap: Codable {
    var characterDetails: [String: Character]

    struct CharacterKey: CodingKey {
        var stringValue: String
        var intValue: Int?
        init?(stringValue: String) {
            self.stringValue = stringValue
        }
        init?(intValue: Int) {
            self.stringValue = "\(intValue)"
            self.intValue = intValue
        }
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CharacterKey.self)

        var character = [String: Character]()
        for key in container.allKeys {
            if let model = try? container.decode(Character.self, forKey: key) {
                character[key.stringValue] = model
            }
        }
        self.characterDetails = character
    }

    struct Character: Codable {
        /// 元素
        var Element: String
        /// 技能图标
        var Consts: [String]
        /// 技能顺序
        var SkillOrder: [Int]
        /// 技能
        var Skills: Skill
        /// ？
        var ProudMap: ProudMap
        /// 名字的hashmap
        var NameTextMapHash: Int
        /// 侧脸图
        var SideIconName: String
        /// 星级
        var QualityType: String

        struct Skill: Codable {
            var skillData: [String: String]

            struct SkillKey: CodingKey {
                var stringValue: String
                var intValue: Int?
                init?(stringValue: String) {
                    self.stringValue = stringValue
                }
                init?(intValue: Int) {
                    self.stringValue = "\(intValue)"
                    self.intValue = intValue
                }
            }

            init(from decoder: Decoder) throws {
                let container = try decoder.container(keyedBy: SkillKey.self)

                var skill = [String: String]()
                for key in container.allKeys {
                    if let model = try? container.decode(String.self, forKey: key) {
                        skill[key.stringValue] = model
                    }
                }
                self.skillData = skill
            }
        }

        struct ProudMap: Codable {
            var proudMapData: [String: Int]

            struct ProudKey: CodingKey {
                var stringValue: String
                var intValue: Int?
                init?(stringValue: String) {
                    self.stringValue = stringValue
                }
                init?(intValue: Int) {
                    self.stringValue = "\(intValue)"
                    self.intValue = intValue
                }
            }

            init(from decoder: Decoder) throws {
                let container = try decoder.container(keyedBy: ProudKey.self)

                var proud = [String: Int]()
                for key in container.allKeys {
                    if let model = try? container.decode(Int.self, forKey: key) {
                        proud[key.stringValue] = model
                    }
                }
                self.proudMapData = proud
            }
        }
    }
}
