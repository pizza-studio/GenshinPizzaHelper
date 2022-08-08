//
//  TextEditorView.swift
//  GenshinPizzaHepler
//
//  Created by Bill Haku on 2022/8/7.
//

import SwiftUI

struct TextEditorView: View {
    var title: String
    var note: String? = nil
    @Binding var content: String
    var showPasteButton: Bool = false
    var showShortCutsLink: Bool = false

    var body: some View {
        List {
            if showPasteButton {
                Section {
                    if showPasteButton {
                        Link("获取Cookie的脚本", destination: URL(string: "https://www.icloud.com/shortcuts/fe68f22c624949c9ad8959993239e19c")!)
                    }
                    Button("粘贴自剪贴板") {
                        content = UIPasteboard.general.string ?? ""
                    }
                }
            }
            Section(footer: Text(note ?? "")) {
                TextEditor(text: $content)
                    .frame(height: 500)
            }
        }
        .navigationBarTitle(title, displayMode: .inline)
    }
}

struct TextFieldEditorView: View {
    var title: String
    var note: String? = nil
    @Binding var content: String
    var keyboardType: UIKeyboardType = .default

    var body: some View {
        if note == nil {
            List {
                if #available(iOS 15.0, *) {
                    TextField("", text: $content)
                        .keyboardType(keyboardType)
                        .submitLabel(.done)
                } else {
                    // Fallback on earlier versions
                    TextField("", text: $content)
                        .keyboardType(keyboardType)
                }
            }
            .navigationBarTitle(title, displayMode: .inline)
        } else {
            List {
                Section(footer: Text(note!)) {
                    if #available(iOS 15.0, *) {
                        TextField(note!, text: $content)
                            .keyboardType(keyboardType)
                            .submitLabel(.done)
                    } else {
                        // Fallback on earlier versions
                        TextField(note!, text: $content)
                            .keyboardType(keyboardType)
                    }
                }
            }
            .navigationBarTitle(title, displayMode: .inline)
        }
    }
}
