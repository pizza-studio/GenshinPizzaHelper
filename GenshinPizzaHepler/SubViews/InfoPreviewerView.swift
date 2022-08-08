//
//  InfoPreviewerView.swift
//  GenshinPizzaHepler
//
//  Created by Bill Haku on 2022/8/7.
//

import SwiftUI

struct InfoPreviewer: View {
    var title: String
    var content: String

    var body: some View {
        HStack {
            Text(title)
            Spacer()
            Text(content)
                .foregroundColor(.gray)
        }
    }
}

struct InfoEditor: View {
    var title: String
    @Binding var content: String
    var keyboardType: UIKeyboardType = .default

    var body: some View {
        HStack {
            Text(title)
            Spacer()
            TextEditor(text: $content)
                .foregroundColor(.gray)
                .keyboardType(keyboardType)
        }
    }
}
