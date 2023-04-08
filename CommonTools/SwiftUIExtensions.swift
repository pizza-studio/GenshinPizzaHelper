//
//  SwiftUIExtensions.swift
//  GenshinPizzaHelper
//
//  Created by ShikiSuen on 2023/3/28.
//  SwiftUI 功能扩充。

import Foundation
import SwiftUI

// MARK: - SwiftUI San Francisco Font Extension

// 针对 SwiftUI 新增 San Francisco 的 Compressed 与 Condensed 特性支援。
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
        if #available(iOS 16, *) {
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
        if #available(iOS 16, *) {
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

// MARK: SwiftUI CenterCropped Image Extension

extension Image {
    public func centerCropped() -> some View {
        GeometryReader { geo in
            self
                .resizable()
                .scaledToFill()
                .frame(width: geo.size.width, height: geo.size.height)
                .clipped()
        }
    }
}
