//
//  ToolbarSharableInIOS16.swift
//  GenshinPizzaHepler
//
//  Created by 戴藏龙 on 2022/10/13.
//

import SFSafeSymbols
import SwiftUI

extension View {
    func toolbarSavePhotoButton<ViewToRender: View>(
        title: String = "保存".localized,
        placement: ToolbarItemPlacement = .navigationBarTrailing,
        visible: Bool = true,
        viewToShare: @escaping () -> ViewToRender
    )
        -> some View {
        modifier(ToolbarSavePhotoButton(
            viewToRender: viewToShare,
            placement: placement,
            title: title,
            isButtonShown: visible
        ))
    }
}

// MARK: - ToolbarSavePhotoButton

struct ToolbarSavePhotoButton<ViewToRender: View>: ViewModifier {
    // MARK: Lifecycle

    init(
        @ViewBuilder viewToRender: @escaping () -> ViewToRender,
        placement: ToolbarItemPlacement = .navigationBarTrailing,
        title: String,
        isButtonShown: Bool = true
    ) {
        self.viewToRender = viewToRender()
        self.placement = placement
        self.title = title
        self.isButtonShown = isButtonShown
    }

    // MARK: Internal

    var viewToRender: ViewToRender

    let placement: ToolbarItemPlacement
    let title: String

    @State
    var isButtonShown: Bool = true

    func body(content: Content) -> some View {
        if isButtonShown {
            content
                .toolbar {
                    ToolbarItem(placement: placement) {
                        if let image = getImage() {
                            let outputImage = Image(uiImage: image)
                            ShareLink(
                                item: outputImage,
                                preview: SharePreview(title, image: outputImage)
                            )
                        }
                    }
                }
        } else {
            content
        }
    }

    @available(iOS 16.0, *)
    @MainActor
    func getImage() -> UIImage? {
        let renderer = ImageRenderer(
            content: viewToRender
                .environment(
                    \.locale,
                    .init(identifier: Locale.current.identifier)
                )
                .background { Color(red: 0.96, green: 0.96, blue: 0.96) }
        )
        renderer.scale = 3
        return renderer.uiImage
    }
}
