//
//  ToolbarSharableInIOS16.swift
//  GenshinPizzaHepler
//
//  Created by 戴藏龙 on 2022/10/13.
//

import SwiftUI

@available(iOS 15, *)
extension View {
    func toolBarSharableInIOS16<ViewToRender: View>(viewToShare: @escaping () -> ViewToRender, placement: ToolbarItemPlacement = .navigationBarTrailing) -> some View {
        modifier(ToolBarSharableInIOS16(viewToRender: viewToShare, placement: placement))
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
    func generateSharePhoto() -> UIImage? {
//        let renderer = ImageRenderer(content: viewToRender)
        // TODO: 反正放List进去就是不行
        let renderer = ImageRenderer(content: VStack {
            List {
                Section {
                    Text("hi")
                    Text("hi")
                }
            }
        })
        renderer.scale = UIScreen.main.scale
        return renderer.uiImage
    }

    func body(content: Content) -> some View {
        if #available(iOS 16, *), let image = generateSharePhoto() {
            content
                .toolbar {
                    ToolbarItem(placement: placement) {
                        ShareLink(
                            item: Image(uiImage: image),
                            preview: SharePreview("分享", image: Image(uiImage: image))
                        )
                    }
                }
        } else {
            content
        }
    }
}
