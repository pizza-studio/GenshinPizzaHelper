//
//  BackgroundsPreviewView.swift
//  GenshinPizzaHepler
//
//  Created by 戴藏龙 on 2022/8/22.
//  背景名片预览View

import SwiftUI

// MARK: - BackgroundsPreviewView

struct BackgroundsPreviewView: View {
    // MARK: Internal

    var body: some View {
        List {
            ForEach(searchResults, id: \.rawValue) { currentCard in
                Section {
                    WidgetBackgroundView(
                        background: generateBackground(currentCard.fileName),
                        darkModeOn: false
                    )
                    .listRowInsets(.init(
                        top: 0,
                        leading: 0,
                        bottom: 0,
                        trailing: 0
                    ))
                    .clipShape(RoundedRectangle(
                        cornerRadius: 20,
                        style: .continuous
                    ))
                } header: {
                    Text(
                        currentCard.localized
                    )
                }
                .textCase(.none)
                .listRowBackground(Color.white.opacity(0))
            }
        }
        .sectionSpacing(UIFont.systemFontSize)
        .listStyle(.insetGrouped)
        .searchable(text: $searchText)
        .navigationTitle("settings.travelTools.backgroundNamecardPreview")
    }

    var searchResults: [NameCard] {
        if searchText.isEmpty {
            return NameCard.allLegalCases
        } else {
            return NameCard.allLegalCases.filter { cardString in
                cardString.localized.lowercased().contains(searchText.lowercased())
            }
        }
    }

    func generateBackground(_ backgroundString: String) -> WidgetBackground {
        WidgetBackground(
            identifier: backgroundString,
            display: backgroundString
        )
    }

    // MARK: Private

    @State
    private var searchText = ""
}

// MARK: - BackgroundsPreviewView_Previews

@available(iOS 15.0, *)
struct BackgroundsPreviewView_Previews: PreviewProvider {
    static var previews: some View {
        BackgroundsPreviewView()
    }
}
