//
//  ToolbarSharableInIOS16.swift
//  GenshinPizzaHepler
//
//  Created by 戴藏龙 on 2022/10/13.
//

import SwiftUI

@available(iOS 15, *)
extension View {
    func toolBarSharableInIOS16<ViewToRender: View>(_ viewToShare: @escaping () -> ViewToRender, placement: ToolbarItemPlacement = .navigationBarTrailing) -> some View {
        modifier(ToolBarSharableInIOS16(viewToRender: viewToShare, placement: .navigationBarTrailing))
    }
}

@available(iOS 15, *)
struct ToolBarSharableInIOS16<ViewToRender: View>: ViewModifier {

    var viewToRender: ViewToRender

    let placement: ToolbarItemPlacement

    init(@ViewBuilder viewToRender: @escaping () -> ViewToRender,
         placement: ToolbarItemPlacement = .navigationBarTrailing) {
        self.viewToRender = viewToRender()
        self.placement = placement
    }

    @MainActor @available(iOS 16.0, *)
    func generateSharePhoto() -> UIImage {
        let view = viewToRender
        let renderer = ImageRenderer(content: view)
        renderer.scale = UIScreen.main.scale
        return renderer.uiImage ?? UIImage()
    }

    func body(content: Content) -> some View {
        if #available(iOS 16, *) {
            content
                .toolbar {
                    ToolbarItem(placement: placement) {
                        ShareLink(
                            item: Image(uiImage: generateSharePhoto()),
                            preview: SharePreview("分享", image: Image(uiImage: generateSharePhoto()))
                        )
                    }
                }
        } else {
            content
        }
    }
}
