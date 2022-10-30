//
//  DismissableSheet.swift
//  GenshinPizzaHepler
//
//  Created by 戴藏龙 on 2022/10/29.
//

import SwiftUI

struct DismissableSheet<Item>: ViewModifier where Item: Identifiable {
    @Binding var sheet: Item?
    var title: String = "完成"
    var todoOnDismiss: () -> ()
    func body(content: Content) -> some View {
        content.toolbar {
            ToolbarItem {
                Button(title.localized) {
                    sheet = nil
                    todoOnDismiss()
                }
            }
        }
    }
}

extension View {
    func dismissableSheet<Item>(sheet: Binding<Item?>,
                                title: String = "完成",
                                todoOnDismiss: @escaping () -> () = {})
    -> some View
    where Item: Identifiable {
        modifier(DismissableSheet(sheet: sheet, title: title, todoOnDismiss: todoOnDismiss))
    }
}
