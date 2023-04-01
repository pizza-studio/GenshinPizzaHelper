//
//  SwiftUISanFranciscoFontExtension.swift
//  GenshinPizzaHelper
//
//  Created by ShikiSuen on 2023/3/28.
//  针对 SwiftUI 新增 San Francisco 的 Compressed 与 Condensed 特性支援。

import Foundation
import SwiftUI

// MARK: - SwiftUI San Francisco Font Extension

extension Font {
    public static func systemCondensed(
        size: CGFloat,
        weight: Weight? = nil
    )
        -> Font {
        var newWeight: UIFont.Weight = .regular
        if let weight = weight {
            switch weight {
            case .ultraLight: newWeight = .ultraLight
            case .thin: newWeight = .thin
            case .light: newWeight = .light
            case .regular: newWeight = .regular
            case .medium: newWeight = .medium
            case .semibold: newWeight = .semibold
            case .bold: newWeight = .bold
            case .heavy: newWeight = .heavy
            case .black: newWeight = .black
            default: break
            }
        }
        osCheck: if #available(iOS 16, *) {
            guard AppConfig.useCondensedSystemFontForAlphanumericals
            else { break osCheck }
            return .init(
                UIFont
                    .systemFont(
                        ofSize: size,
                        weight: newWeight,
                        width: .condensed
                    )
            )
        }
        return .system(size: size, weight: weight ?? .regular)
    }

    public static func systemCompressed(
        size: CGFloat,
        weight: Weight? = nil
    )
        -> Font {
        var newWeight: UIFont.Weight = .regular
        if let weight = weight {
            switch weight {
            case .ultraLight: newWeight = .ultraLight
            case .thin: newWeight = .thin
            case .light: newWeight = .light
            case .regular: newWeight = .regular
            case .medium: newWeight = .medium
            case .semibold: newWeight = .semibold
            case .bold: newWeight = .bold
            case .heavy: newWeight = .heavy
            case .black: newWeight = .black
            default: break
            }
        }
        osCheck: if #available(iOS 16, *) {
            guard AppConfig.useCondensedSystemFontForAlphanumericals
            else { break osCheck }
            return .init(
                UIFont
                    .systemFont(
                        ofSize: size,
                        weight: newWeight,
                        width: .compressed
                    )
            )
        }
        return .system(size: size, weight: weight ?? .regular)
    }
}
