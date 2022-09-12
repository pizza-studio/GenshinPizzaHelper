//
//  ViewTools.swift
//  GenshinPizzaHelper
//
//  Created by Bill Haku on 2022/8/23.
//  View的一些高效扩展

import Foundation
import SwiftUI

extension View {
    /// 将View转化为UIImage
    func asUiImage() -> UIImage {
        let controller = UIHostingController(rootView: self)
        let view = controller.view

        let targetSize = controller.view.intrinsicContentSize
        view?.bounds = CGRect(origin: .zero, size: targetSize)
        view?.backgroundColor = .clear

        let renderer = UIGraphicsImageRenderer(size: targetSize)

        return renderer.image { _ in
            view?.drawHierarchy(in: controller.view.bounds, afterScreenUpdates: true)
        }
    }
}

extension View {
    /// Navigate to a new view.
    /// - Parameters:
    ///   - view: View to navigate to.
    ///   - binding: Only navigates when this condition is `true`.
    func navigate<NewView: View>(to view: NewView, when binding: Binding<Bool>) -> some View {
        ZStack {
            self
                .navigationBarTitle("")
                .navigationBarHidden(true)

            if binding.wrappedValue {
                NavigationView {
                    NavigationLink(
                        destination: view,
                        isActive: binding
                    ) {
                        EmptyView()
                    }
                }.animation(.default)
            }
        }
    }
}
