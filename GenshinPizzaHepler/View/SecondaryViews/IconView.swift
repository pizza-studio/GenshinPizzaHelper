//
//  IconView.swift
//  GenshinPizzaHelper
//
//  Created by Bill Haku on 2023/6/12.
//

import SFSafeSymbols
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
                    Image(systemSymbol: .checkmarkCircleFill)
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
            Text("settings.icon.xinzoruo.credits.description")
                .foregroundColor(.secondary)
                .font(.footnote)
                .padding()
        }
        .navigationTitle("settings.icon.xinzoruo.toggle")
        .padding()
    }
}
