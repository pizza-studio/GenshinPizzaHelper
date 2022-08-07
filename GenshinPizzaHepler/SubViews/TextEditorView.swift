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
            }
            .navigationBarTitle(title, displayMode: .inline)
        } else {
            List {
                Section(footer: Text(note!)) {
                    TextEditor(text: $content)
                }
            }
            .navigationBarTitle(title, displayMode: .inline)
        }
    }
}
