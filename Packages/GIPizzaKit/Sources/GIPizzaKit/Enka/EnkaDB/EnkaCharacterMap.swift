// (c) 2022 and onwards Pizza Studio (GPL v3.0 License).
// ====================
// This code is released under the GPL v3.0 License (SPDX-License-Identifier: GPL-3.0)

import Foundation

// MARK: - EnkaGI.DBModels.CharacterDict

extension EnkaGI {
    public typealias CharacterMap = [String: Character]

    public struct Costume: Codable, Hashable {
        let sideIconName: String
        let icon: String
        let art: String
        let avatarId: Int
    }

    public struct Character: Codable, Hashable {
        /// 元素
        public var Element: String
        /// 技能图标
        public var Consts: [String]
        /// 技能顺序
        public var SkillOrder: [Int]
        /// 技能
        public var Skills: [String: String]
        /// 与命之座有关的技能加成资料?
        public var ProudMap: [String: Int]
        /// 名字的hashmap
        public var NameTextMapHash: Int
        /// 侧脸图
        public var SideIconName: String
        /// 星级
        public var QualityType: String
        /// 服饰
        public var Costumes: [String: Costume]?

        /// 正脸图
        public var iconString: String {
            SideIconName.replacingOccurrences(of: "_Side", with: "")
        }

        /// icon用的名字
        public var nameID: String {
            iconString.replacingOccurrences(of: "UI_AvatarIcon_", with: "")
        }

        /// 检测是否是主角兄妹当中的某位。都不是的话则返回 nil。
        /// 是 Hotaru 則返回 true，是 Sora 則返回 false。
        public var isLumine: Bool? {
            switch nameID {
            case "PlayerGirl": return true
            case "PlayerBoy": return false
            default: return nil
            }
        }

        /// 名片
        public var namecardIconString: String {
            // 主角没有对应名片；八重神子与绮良良的名片名称无法推算、只能单独定义。
            switch nameID {
            case "PlayerBoy", "PlayerGirl": return "UI_NameCardPic_Bp2_P"
            case "Yae": return "UI_NameCardPic_Yae1_P"
            case "Momoka": return "UI_NameCardPic_Kirara_P"
            default: return "UI_NameCardPic_\(nameID)_P"
            }
        }
    }
}

extension EnkaGI.DBModels.CharacterDict {
    public func getIconString(id: String) -> String {
        self[id]?.iconString ?? ""
    }

    public func getSideIconString(id: String) -> String {
        self[id]?.SideIconName ?? ""
    }

    public func getNameID(id: String) -> String {
        self[id]?.nameID ?? ""
    }
}
