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
