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
        if let weight = weight {
            switch weight {
            case .black, .bold, .heavy, .medium, .semibold:
                return .custom("RobotoCondensed-Bold", size: size)
            case .thin, .ultraLight:
                return .custom("RobotoCondensed-Light", size: size)
            default:
                return .custom("RobotoCondensed-Regular", size: size)
            }
        }
        return .custom("RobotoCondensed-Regular", size: size)
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
        if let weight = weight {
            switch weight {
            case .black, .heavy:
                return .custom("HelveticaNeue-CondensedBlack", size: size)
            default:
                return .custom("HelveticaNeue-CondensedBold", size: size)
            }
        }
        return .custom("HelveticaNeue-CondensedBold", size: size)
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

// MARK: - Trailing Text Label

extension View {
    public func corneredTag(
        _ stringKey: LocalizedStringKey,
        alignment: Alignment,
        textSize: CGFloat = 12,
        opacity: CGFloat = 1,
        enabled: Bool = true,
        padding: CGFloat = 0
    )
        -> some View {
        guard stringKey != "", enabled else { return AnyView(self) }
        return AnyView(
            ZStack(alignment: alignment) {
                self
                Text(stringKey)
                    .font(.systemCondensed(size: textSize, weight: .medium))
                    .padding(.horizontal, 0.3 * textSize)
                    .adjustedBlurMaterialBackground().clipShape(Capsule())
                    .opacity(opacity)
                    .padding(padding)
            }
        )
    }

    public func corneredTag(
        verbatim stringVerbatim: String,
        alignment: Alignment,
        textSize: CGFloat = 12,
        opacity: CGFloat = 1,
        enabled: Bool = true,
        padding: CGFloat = 0
    )
        -> some View {
        guard stringVerbatim != "", enabled else { return AnyView(self) }
        return AnyView(
            ZStack(alignment: alignment) {
                self
                Text(stringVerbatim)
                    .font(.systemCondensed(size: textSize, weight: .medium))
                    .padding(.horizontal, 0.3 * textSize)
                    .adjustedBlurMaterialBackground().clipShape(Capsule())
                    .opacity(opacity)
                    .padding(padding)
            }
        )
    }
}

// MARK: - HelpTextForScrollingOnDesktopComputer

struct HelpTextForScrollingOnDesktopComputer: View {
    // MARK: Lifecycle

    public init(_ direction: UIAxis) {
        self.direction = direction
    }

    // MARK: Internal

    @State
    var direction: UIAxis

    var body: some View {
        if OS.type == .macOS {
            let mark: String = (direction == .horizontal) ? "⇆ " : "⇅ "
            (Text(mark) + Text("operation.scrolling.guide")).font(.footnote).opacity(0.7)
        } else {
            EmptyView()
        }
    }
}

// MARK: - Make OptionsSet Bindable.

// Ref: https://gist.github.com/vibrazy/79d407cf2eac2b0e65a61ab07f584105

extension Binding where Value: OptionSet, Value == Value.Element {
    func bindedValue(_ options: Value) -> Bool {
        wrappedValue.contains(options)
    }

    func bind(
        _ options: Value,
        animate: Bool = false
    )
        -> Binding<Bool> {
        .init { () -> Bool in
            self.wrappedValue.contains(options)
        } set: { newValue in
            let body = {
                if newValue {
                    self.wrappedValue.insert(options)
                } else {
                    self.wrappedValue.remove(options)
                }
            }
            guard animate else {
                body()
                return
            }
            withAnimation {
                body()
            }
        }
    }
}
