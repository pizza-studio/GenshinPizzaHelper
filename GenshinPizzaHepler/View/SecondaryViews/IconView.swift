//
//  IconView.swift
//  GenshinPizzaHelper
//
//  Created by Bill Haku on 2023/6/12.
//

import SwiftUI

// MARK: - IconView

struct IconView: View {
    let icon: Icon
    let selected: Bool

    var body: some View {
        Image(uiImage: icon.image)
            .resizable()
            .frame(width: 90, height: 90)
            .cornerRadius(10)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(lineWidth: 2)
            )
            .padding([.trailing], 2)
            .if(selected) {
                $0.overlay(
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.green),
                    alignment: .bottomTrailing
                )
            }
    }
}

// MARK: - IconChooserView

struct IconChooserView: View {
    @StateObject
    var iconManager = IconManager.shared

    var body: some View {
        HStack {
            ForEach(iconManager.icons) { icon in
                Button {
                    Task {
                        try await iconManager.set(icon: icon)
                    }
                } label: {
                    IconView(icon: icon, selected: iconManager.currentIcon == icon)
                }
            }
        }
    }
}

// MARK: - IconSettingsView

struct IconSettingsView: View {
    var body: some View {
        VStack {
            IconChooserView()
                .padding()
            Spacer()
            Text("感谢[@心臓弱眞君](https://twitter.com/xinzoruo)为我们绘制了全新的App图标。您也可以继续使用以前的图标。")
                .foregroundColor(.secondary)
                .font(.footnote)
                .padding()
        }
        .navigationTitle("更换App图标")
        .padding()
    }
}
