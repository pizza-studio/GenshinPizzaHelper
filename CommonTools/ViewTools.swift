//
//  ViewTools.swift
//  GenshinPizzaHelper
//
//  Created by Bill Haku on 2022/8/23.
//  View的一些高效扩展

import Foundation
import SwiftUI

extension View {
    @available(iOS 16.0, *)
    @MainActor
    func asUiImage() -> UIImage? {
        let renderer = ImageRenderer(
            content: environment(
                \.locale,
                .init(identifier: Locale.current.identifier)
            )
        )
        renderer.scale = 3
        return renderer.uiImage
    }
}

extension View {
    /// Navigate to a new view.
    /// - Parameters:
    ///   - view: View to navigate to.
    ///   - binding: Only navigates when this condition is `true`.
    func navigate<NewView: View>(
        to view: NewView,
        when binding: Binding<Bool>
    )
        -> some View {
        ZStack {
            self
                .navigationBarTitle("")
                .navigationBarHidden(true)

            if binding.wrappedValue {
                NavigationStack {
                    NavigationLink(
                        destination: view,
                        isActive: binding
                    ) {
                        EmptyView()
                    }
                }.animation(.default, value: 200)
            }
        }
    }
}

// MARK: - ScrollViewOffsetPreferenceKey

// Scroll View Offset Getter
struct ScrollViewOffsetPreferenceKey: PreferenceKey {
    typealias value = CGPoint

    static var defaultValue: CGPoint = .zero

    static func reduce(value: inout CGPoint, nextValue: () -> CGPoint) {
        value = nextValue()
    }
}

// MARK: - ScrollViewOffsetModifier

struct ScrollViewOffsetModifier: ViewModifier {
    let coordinateSpace: String
    @Binding
    var offset: CGPoint

    func body(content: Content) -> some View {
        ZStack {
            content
            GeometryReader { proxy in
                let x = proxy.frame(in: .named(coordinateSpace)).minX
                let y = proxy.frame(in: .named(coordinateSpace)).minY
                Color.clear.preference(
                    key: ScrollViewOffsetPreferenceKey.self,
                    value: CGPoint(x: x * -1, y: y * -1)
                )
            }
        }
        .onPreferenceChange(ScrollViewOffsetPreferenceKey.self) { value in
            offset = value
        }
    }
}

extension View {
    func readingScrollView(
        from coordinateSpace: String,
        into binding: Binding<CGPoint>
    )
        -> some View {
        modifier(ScrollViewOffsetModifier(
            coordinateSpace: coordinateSpace,
            offset: binding
        ))
    }
}

// MARK: - Blur Background

extension View {
    func blurMaterialBackground() -> some View {
        modifier(BlurMaterialBackground())
    }

    func adjustedBlurMaterialBackground() -> some View {
        modifier(AdjustedBlurMaterialBackground())
    }
}

// MARK: - BlurMaterialBackground

struct BlurMaterialBackground: ViewModifier {
    func body(content: Content) -> some View {
        content.background(
            .regularMaterial,
            in: RoundedRectangle(cornerRadius: 20, style: .continuous)
        )
        .contentShape(RoundedRectangle(
            cornerRadius: 20,
            style: .continuous
        ))
    }
}

// MARK: - Regualr Material List Row Background

extension View {
    @inlinable
    public func listRowMaterialBackground() -> some View {
        listRowBackground(
            Color.clear.background(.thinMaterial, in: Rectangle())
        )
    }
}

// MARK: - AdjustedBlurMaterialBackground

struct AdjustedBlurMaterialBackground: ViewModifier {
    @Environment(\.colorScheme)
    var colorScheme

    @ViewBuilder
    func body(content: Content) -> some View {
        Group {
            if colorScheme == .dark {
                content.background(
                    .thinMaterial,
                    in: RoundedRectangle(cornerRadius: 20, style: .continuous)
                )
            } else {
                content.background(
                    .regularMaterial,
                    in: RoundedRectangle(cornerRadius: 20, style: .continuous)
                )
            }
        }.contentShape(RoundedRectangle(
            cornerRadius: 20,
            style: .continuous
        ))
    }
}

// MARK: - NavigationBackground

extension View {
    @ViewBuilder
    func listContainerBackground(fileNameOverride: String? = nil) -> some View {
        let fileName = fileNameOverride ?? NameCard.currentValueForAppBackground.fileName
        background {
            EnkaWebIcon(iconString: fileName)
                .scaledToFill()
                .scaleEffect(1.2)
                .blur(radius: 50)
                .ignoresSafeArea(.all)
                .saturation(1.5)
                .overlay(
                    Color(uiColor: .systemBackground)
                        .opacity(0.3)
                        .blendMode(.hardLight)
                )
        }
    }
}

// MARK: - View.if().

extension View {
    @ViewBuilder
    func `if`<T: View>(_ conditional: Bool, transform: (Self) -> T) -> some View {
        if conditional {
            transform(self)
        } else {
            self
        }
    }
}
