//
//  InfoPreviewerView.swift
//  GenshinPizzaHepler
//
//  Created by Bill Haku on 2022/8/7.
//  显示具体栏目信息的工具类View

import SwiftUI

struct InfoPreviewer: View {
    var title: String
    var content: String

    var body: some View {
        HStack {
            Text(LocalizedStringKey(title))
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
    var placeholderText: String = ""
    @State var contentColor: Color = Color(UIColor.systemGray)

    var body: some View {
        HStack {
            Text(LocalizedStringKey(title))
            Spacer()
            TextEditor(text: $content)
                .multilineTextAlignment(.trailing)
                .foregroundColor(contentColor)
                .keyboardType(keyboardType)
                .onTapGesture { contentColor = Color.primary }
        }
    }
}

