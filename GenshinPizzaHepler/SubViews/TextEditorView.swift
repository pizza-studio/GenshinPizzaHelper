//
//  TextEditorView.swift
//  GenshinPizzaHepler
//
//  Created by Bill Haku on 2022/8/7.
//

import SwiftUI

struct TextEditorView: View {
    @Binding var content: String

    var body: some View {
        List {
            TextEditor(text: $content)
        }
    }
}
