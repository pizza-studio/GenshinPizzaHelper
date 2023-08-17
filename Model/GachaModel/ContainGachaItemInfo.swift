//
//  ContainGachaItemInfo.swift
//  GenshinPizzaHepler
//
//  Created by 戴藏龙 on 2023/3/29.
//

import Foundation
import SwiftUI

// MARK: - ContainGachaItemInfo

protocol ContainGachaItemInfo {
    var name: String { get }
    var lang: GachaLanguageCode { get }
    var itemType: String { get }
    var _rankLevel: GachaItem.RankType { get }
    var formattedTime: String { get }
}

// MARK: - GachaItemType

enum GachaItemType {
    case character
    case weapon
}

extension GachaItemType {
    var cnRaw: String {
        switch self {
        case .character:
            return "角色"
        case .weapon:
            return "武器"
        }
    }

    static func fromRaw(_ string: String) -> Self? {
        let manager = GachaTranslateManager.shared
        let string = manager.translateItemTypeToZHCN(string)
        switch string {
        case "武器": return .weapon
        case "角色": return .character
        default: return nil
        }
    }

    // TODO: find by name
    static func findByName(_ name: String) -> Self {
        .weapon
    }

    func toLanguageRaw(_ languageCode: GachaLanguageCode) -> String {
        let manager = GachaTranslateManager.shared
        return manager.translateItemType(cnRaw, to: languageCode) ?? "武器"
    }
}

extension ContainGachaItemInfo {
    var type: GachaItemType {
        switch itemType {
        case "武器": return .weapon
        case "角色": return .character
        default: return .character
        }
    }

    var iconImageName: String {
        switch type {
        case .character:
            if let id = GachaItemNameIconMap.characterIdMap[name] {
                return "UI_AvatarIcon_\(id)"
            } else {
                // TODO: 找不到时的默认图片
                return ""
            }
        case .weapon:
            if let iconString = WeaponOrTalentMaterial.dumpedWeaponIconMap[name] {
                return iconString
            } else {
                // TODO: 找不到时的默认图片
                return ""
            }
        }
    }

    var backgroundImageView: some View {
        GachaItemBackgroundImage(
            name: name,
            _itemType: type,
            _rankLevel: _rankLevel
        )
    }

    var localizedName: String {
//        guard lang != "zh-cn" else { return name }
        // TODO: 翻译为其他语言
        name.localizedWithFix
    }

    /// 显示带有背景的角色肖像图示或武器图示。
    /// - Parameters:
    ///   - size: 尺寸。
    ///   - cutType: 决定裁切到哪个身体部位。该选项对武器无效。
    /// - Returns: SwiftUI "some View"
    func decoratedIconView(_ size: CGFloat, cutTo cutType: DecoratedIconCutType = .shoulder) -> some View {
        guard type != .weapon else {
            let result = EnkaWebIcon(iconString: iconImageName)
                .scaleEffect(0.9)
                .background(backgroundImageView)
                .frame(width: size, height: size)
                .clipShape(Circle())
                .contentShape(Circle())
            return AnyView(result)
        }
        // 由于 Lava 强烈反对针对证件照的脸裁切与头裁切，
        // 所以不预设启用该功能。
        var cutType = cutType
        if !AppConfig.cutShouldersForSmallAvatarPhotos {
            cutType = .shoulder
        }
        let result = EnkaWebIcon(iconString: iconImageName)
            .scaledToFill()
            .frame(width: size * cutType.rawValue, height: size * cutType.rawValue)
            .clipped()
            .scaledToFit()
            .offset(y: cutType.shiftedAmount(containerSize: size))
            .background(backgroundImageView)
            .frame(width: size, height: size)
            .clipShape(Circle())
            .contentShape(Circle())
        return AnyView(result)
    }
}

// MARK: - GachaItemBackgroundImage

struct GachaItemBackgroundImage: View {
    let name: String
    let _itemType: GachaItemType
    let _rankLevel: GachaItem.RankType

    var imageString: String {
        switch _itemType {
        case .character:
            if let id = GachaItemNameIconMap.characterIdMap[name] {
                if id == "Yae" {
                    return "UI_NameCardPic_Yae1_P"
                } else {
                    return "UI_NameCardPic_\(id)_P"
                }
            } else {
                // TODO: 找不到时的默认图片
                return ""
            }
        case .weapon:
            return "UI_QualityBg_\(_rankLevel.rawValue)"
        }
    }

    var body: some View {
        switch _itemType {
        case .character:
            EnkaWebIcon(iconString: imageString).scaledToFill()
                .offset(x: -30 / 3)
        case .weapon:
            if _rankLevel.rawValue == 3 {
                EnkaWebIcon(
                    iconString: imageString
                )
                .scaledToFit()
                .scaleEffect(2)
                .offset(y: 3)
            } else {
                EnkaWebIcon(
                    iconString: imageString
                )
                .scaledToFit()
                .scaleEffect(1.5)
                .offset(y: 3)
            }
        }
    }
}

// MARK: - GachaItemNameIconMap

enum GachaItemNameIconMap {
    static var characterIdMap: [String: String] {
        [
            "芭芭拉": "Barbara",
            "安柏": "Ambor",
            "可莉": "Klee",
            "达达利亚": "Tartaglia",
            "迪奥娜": "Diona",
            "砂糖": "Sucrose",
            "埃洛伊": "Aloy",
            "莫娜": "Mona",
            "琴": "Qin",
            "优菈": "Eula",
            "迪卢克": "Diluc",
            "雷泽": "Razor",
            "诺艾尔": "Noel",
            "班尼特": "Bennett",
            "丽莎": "Lisa",
            "菲谢尔": "Fischl",
            "凯亚": "Kaeya",
            "温迪": "Venti",
            "阿贝多": "Albedo",
            "罗莎莉亚": "Rosaria",
            "米卡": "Mika",
            "魈": "Xiao",
            "凝光": "Ningguang",
            "七七": "Qiqi",
            "刻晴": "Keqing",
            "夜兰": "Yelan",
            "申鹤": "Shenhe",
            "香菱": "Xiangling",
            "重云": "Chongyun",
            "甘雨": "Ganyu",
            "胡桃": "Hutao",
            "枫原万叶": "Kazuha",
            "云堇": "Yunjin",
            "瑶瑶": "Yaoyao",
            "北斗": "Beidou",
            "行秋": "Xingqiu",
            "钟离": "Zhongli",
            "辛焱": "Xinyan",
            "烟绯": "Feiyan",
            "宵宫": "Yoimiya",
            "托马": "Tohma",
            "珊瑚宫心海": "Kokomi",
            "鹿野院平藏": "Heizo",
            "九条裟罗": "Sara",
            "神里绫华": "Ayaka",
            "荒泷一斗": "Itto",
            "久岐忍": "Shinobu",
            "神里绫人": "Ayato",
            "雷电将军": "Shougun",
            "早柚": "Sayu",
            "五郎": "Gorou",
            "八重神子": "Yae",
            "提纳里": "Tighnari",
            "坎蒂丝": "Candace",
            "赛诺": "Cyno",
            "珐露珊": "Faruzan",
            "多莉": "Dori",
            "纳西妲": "Nahida",
            "莱依拉": "Layla",
            "艾尔海森": "Alhatham",
            "柯莱": "Collei",
            "妮露": "Nilou",
            "流浪者": "Wanderer",
            "迪希雅": "Dehya",
            "卡维": "Kaveh",
            "白术": "Baizhuer",
            "绮良良": "Momoka",
            "林尼": "Liney",
            "琳妮特": "Linette",
            "菲米尼": "Freminet",
        ]
    }
}
