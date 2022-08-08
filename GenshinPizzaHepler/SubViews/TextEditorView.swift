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

    var body: some View {
        if note == nil {
            List {
                TextEditor(text: $content)
                    .frame(height: 500)
            }
            .navigationBarTitle(title, displayMode: .inline)
        } else {
            List {
                Section(footer: Text(note!)) {
                    TextEditor(text: $content)
                        .frame(height: 500)
                }
            }
            .navigationBarTitle(title, displayMode: .inline)
        }
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
