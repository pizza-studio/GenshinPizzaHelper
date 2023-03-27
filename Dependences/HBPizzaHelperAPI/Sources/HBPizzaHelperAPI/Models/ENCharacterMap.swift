//
//  ENCharacterMap.swift
//  
//
//  Created by Bill Haku on 2023/3/27.
//

import Foundation

// MARK: - ENCharacterMap

struct ENCharacterMap: Codable {
    // MARK: Lifecycle

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

    // MARK: Internal

    struct CharacterKey: CodingKey {
        // MARK: Lifecycle

        init?(stringValue: String) {
            self.stringValue = stringValue
        }

        init?(intValue: Int) {
            self.stringValue = "\(intValue)"
            self.intValue = intValue
        }

        // MARK: Internal

        var stringValue: String
        var intValue: Int?
    }

    struct Character: Codable {
        struct Skill: Codable {
            // MARK: Lifecycle

            init(from decoder: Decoder) throws {
                let container = try decoder.container(keyedBy: SkillKey.self)

                var skill = [String: String]()
                for key in container.allKeys {
                    if let model = try? container.decode(
                        String.self,
                        forKey: key
                    ) {
                        skill[key.stringValue] = model
                    }
                }
                self.skillData = skill
            }

            // MARK: Internal

            struct SkillKey: CodingKey {
                // MARK: Lifecycle

                init?(stringValue: String) {
                    self.stringValue = stringValue
                }

                init?(intValue: Int) {
                    self.stringValue = "\(intValue)"
                    self.intValue = intValue
                }

                // MARK: Internal

                var stringValue: String
                var intValue: Int?
            }

            var skillData: [String: String]
        }

        struct ProudMap: Codable {
            // MARK: Lifecycle

            init(from decoder: Decoder) throws {
                let container = try decoder.container(keyedBy: ProudKey.self)

                var proud = [String: Int]()
                for key in container.allKeys {
                    if let model = try? container
                        .decode(Int.self, forKey: key) {
                        proud[key.stringValue] = model
                    }
                }
                self.proudMapData = proud
            }

            // MARK: Internal

            struct ProudKey: CodingKey {
                // MARK: Lifecycle

                init?(stringValue: String) {
                    self.stringValue = stringValue
                }

                init?(intValue: Int) {
                    self.stringValue = "\(intValue)"
                    self.intValue = intValue
                }

                // MARK: Internal

                var stringValue: String
                var intValue: Int?
            }

            var proudMapData: [String: Int]
        }

        /// 元素
        var Element: String
        /// 技能图标
        var Consts: [String]
        /// 技能顺序
        var SkillOrder: [Int]
        /// 技能
        var Skills: Skill
        /// 与命之座有关的技能加成资料?
        var ProudMap: ProudMap
        /// 名字的hashmap
        var NameTextMapHash: Int
        /// 侧脸图
        var SideIconName: String
        /// 星级
        var QualityType: String

        /// 正脸图
        var iconString: String {
            SideIconName.replacingOccurrences(of: "_Side", with: "")
        }

        /// icon用的名字
        var nameID: String {
            iconString.replacingOccurrences(of: "UI_AvatarIcon_", with: "")
        }

        /// 名片
        var namecardIconString: String {
            // 主角没有对应名片
            if nameID == "PlayerGirl" || nameID == "PlayerBoy" {
                return "UI_NameCardPic_Bp2_P"
            } else if nameID == "Yae" {
                return "UI_NameCardPic_Yae1_P"
            } else {
                return "UI_NameCardPic_\(nameID)_P"
            }
        }
    }

    var characterDetails: [String: Character]
}

extension Dictionary
    where Key == String, Value == ENCharacterMap.Character {
    func getIconString(id: String) -> String {
        self[id]?.iconString ?? ""
    }

    func getSideIconString(id: String) -> String {
        self[id]?.SideIconName ?? ""
    }

    func getNameID(id: String) -> String {
        self[id]?.nameID ?? ""
    }
}
