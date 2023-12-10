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
    var title: String = "sys.done"
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
        title: String = "sys.done",
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
    var title: String = "sys.done"
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
        title: String = "sys.done",
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

// MARK: - SheetCaller

struct SheetCaller<D: View, L: View>: View {
    // MARK: Lifecycle

    public init(
        forceDarkMode: Bool = false,
        @ViewBuilder destination: @escaping () -> D,
        @ViewBuilder label: @escaping () -> L
    ) {
        self.destination = destination
        self.label = label
        self.forceDarkMode = forceDarkMode
    }

    // MARK: Public

    @State
    public var forceDarkMode: Bool

    // MARK: Internal

    var body: some View {
        Button {
            isSheetShown.toggle()
        } label: {
            label()
        }
        .foregroundStyle(.primary)
        .sheet(isPresented: $isSheetShown) {
            let sheetContent = NavigationView {
                destination()
                    .navigationBarTitleDisplayMode(.inline)
                    .dismissableSheet(isSheetShow: $isSheetShown)
            }
            if forceDarkMode {
                sheetContent.environment(\.colorScheme, .dark)
            } else {
                sheetContent
            }
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
