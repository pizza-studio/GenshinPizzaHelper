//
//  ContainGachaItemInfo.swift
//  GenshinPizzaHepler
//
//  Created by 戴藏龙 on 2023/3/29.
//

import Defaults
import Foundation
import GIPizzaKit
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

    public init(itemIdStr: String) {
        self = itemIdStr.count > 6 ? .character : .weapon
    }

    public init(itemId: Int) {
        self = itemId > 114_514 ? .character : .weapon
    }

    public init(rawString: String) {
        let weaponStrings: [String] = [
            "อาวุธ", "무기", "Arma", "武器",
            "武器", "Senjata", "Arma", "Waffe",
            "Arme", "武器", "Оружие", "Weapon", "Vũ Khí",
        ]
        if weaponStrings.contains(rawString) {
            self = .weapon
        } else {
            self = .character
        }
    }

    public func translatedRaw(for lang: GachaLanguageCode) -> String {
        switch (self, lang) {
        case (.character, .de): return "Figur"
        case (.character, .enUS): return "Character"
        case (.character, .es): return "Personaje"
        case (.character, .fr): return "Personnage"
        case (.character, .id): return "Karakter"
        case (.character, .ja): return "キャラクター"
        case (.character, .ko): return "캐릭터"
        case (.character, .pt): return "Personagem"
        case (.character, .ru): return "Персонаж"
        case (.character, .th): return "ตัวละคร"
        case (.character, .vi): return "Nhân Vật"
        case (.character, .zhHans): return "角色"
        case (.character, .zhHant): return "角色"
        case (.weapon, .de): return "Waffe"
        case (.weapon, .enUS): return "Weapons"
        case (.weapon, .es): return "Arma"
        case (.weapon, .fr): return "Arme"
        case (.weapon, .id): return "Senjata"
        case (.weapon, .ja): return "武器"
        case (.weapon, .ko): return "무기"
        case (.weapon, .pt): return "Arma"
        case (.weapon, .ru): return "Оружие"
        case (.weapon, .th): return "อาวุธ"
        case (.weapon, .vi): return "Vũ Khí"
        case (.weapon, .zhHans): return "武器"
        case (.weapon, .zhHant): return "武器"
        }
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
            if let asset = CharacterAsset.allCases.filter({ $0.officialSimplifiedChineseName == name }).first {
                return asset.frontPhotoFileName
            } else {
                // TODO: 找不到时的默认图片
                return ""
            }
        case .weapon:
            if let asset = WeaponAsset.allCases.filter({ $0.officialSimplifiedChineseName == name }).first {
                return asset.fileName
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
        switch type {
        case .character:
            if let asset = CharacterAsset.allCases.filter({ $0.officialSimplifiedChineseName == name }).first {
                return asset.localized.localizedWithFix
            }
        case .weapon:
            if let asset = WeaponAsset.allCases.filter({ $0.officialSimplifiedChineseName == name }).first {
                return asset.localized.localizedWithFix
            }
        }
        return name.localizedWithFix
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
        if !Defaults[.cutShouldersForSmallAvatarPhotos] {
            cutType = .shoulder
        }
        let asset = CharacterAsset.allCases.filter { $0.officialSimplifiedChineseName == name }.first
        if let asset = asset {
            return AnyView(asset.decoratedIcon(size, cutTo: cutType))
        }
        // 下述内容是垫底内容，通常情况下不该被触发。
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
            if let asset = CharacterAsset.allCases.filter({ $0.officialSimplifiedChineseName == name }).first {
                return asset.namecard.fileName
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
