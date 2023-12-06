//
//  DismissableSheet.swift
//  GenshinPizzaHepler
//
//  Created by 戴藏龙 on 2022/10/29.
//

import SwiftUI

// MARK: - DismissableSheet

struct DismissableSheet<Item>: ViewModifier where Item: Identifiable {
    @Binding
    var sheet: Item?
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
    func dismissableSheet<Item>(
        sheet: Binding<Item?>,
        title: String = "完成",
        todoOnDismiss: @escaping () -> () = {}
    )
        -> some View
        where Item: Identifiable {
        modifier(DismissableSheet(
            sheet: sheet,
            title: title,
            todoOnDismiss: todoOnDismiss
        ))
    }
}

// MARK: - DismissableBoolSheet

struct DismissableBoolSheet: ViewModifier {
    @Binding
    var isSheetShow: Bool
    var title: String = "完成"
    var todoOnDismiss: () -> ()

    func body(content: Content) -> some View {
        content.toolbar {
            ToolbarItem {
                Button(title.localized) {
                    isSheetShow = false
                    todoOnDismiss()
                }
            }
        }
    }
}

extension View {
    func dismissableSheet(
        isSheetShow: Binding<Bool>,
        title: String = "完成",
        todoOnDismiss: @escaping () -> () = {}
    )
        -> some View {
        modifier(DismissableBoolSheet(
            isSheetShow: isSheetShow,
            title: title,
            todoOnDismiss: todoOnDismiss
        ))
    }
}

// MARK: - NavigationLinkSheetable

struct NavigationLinkSheetable<D: View, L: View>: View {
    // MARK: Lifecycle

    public init(@ViewBuilder destination: @escaping () -> D, @ViewBuilder label: @escaping () -> L) {
        self.destination = destination
        self.label = label
    }

    // MARK: Internal

    var body: some View {
        if OS.type == .macOS {
            Button {
                isSheetShown.toggle()
            } label: {
                label()
            }
            .foregroundStyle(.primary)
            .sheet(isPresented: $isSheetShown) {
                NavigationView {
                    destination()
                        .navigationBarTitleDisplayMode(.inline)
                        .dismissableSheet(isSheetShow: $isSheetShown)
                }
            }
        } else {
            NavigationLink(destination: destination(), label: { label() })
        }
    }

    // MARK: Private

    @ViewBuilder
    private let destination: () -> D

    @ViewBuilder
    private let label: () -> L

    @State
    private var isSheetShown = false
}
