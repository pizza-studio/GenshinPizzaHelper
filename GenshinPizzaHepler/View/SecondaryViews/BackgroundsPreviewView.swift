//
//  BackgroundsPreviewView.swift
//  GenshinPizzaHepler
//
//  Created by 戴藏龙 on 2022/8/22.
//  背景名片预览View

import GIPizzaKit
import SwiftUI

// MARK: - BackgroundsPreviewView

struct BackgroundsPreviewView: View {
    // MARK: Internal

    @StateObject
    private var orientation = ThisDevice.DeviceOrientation()

    @Namespace
    var animation

    @State
    var containerSize: CGSize = .zero

    var columns: Int {
        max(Int(floor($containerSize.wrappedValue.width / 240)), 1)
    }

    var body: some View {
        GeometryReader { geometry in
            coreBodyView.onAppear {
                containerSize = geometry.size
            }.onChange(of: geometry.size) { newSize in
                containerSize = newSize
            }
        }
    }

    @ViewBuilder
    var coreBodyView: some View {
        StaggeredGrid(columns: columns, list: searchResults, content: { currentCard in
            currentCard.suiCellView
                .matchedGeometryEffect(id: currentCard.id, in: animation)
        })
        .searchable(text: $searchText)
        .padding(.horizontal)
        .animation(.easeInOut, value: columns)
        .navigationTitle("settings.travelTools.backgroundNamecardPreview")
        .environmentObject(orientation)
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

// MARK: - NameCardCellView

// 因为我们声明T为可识别的…
// 所以我们需要传递可识别集合/数组…
struct NameCardCellView: View {
    var card: NameCard

    var body: some View {
        Image(card.fileName)
            .resizable()
            .aspectRatio(contentMode: .fit)
            .cornerRadius(10)
            .corneredTag(
                verbatim: card.localized,
                alignment: .bottomLeading,
                opacity: 0.9,
                padding: 6
            )
    }
}

// MARK: - NameCard SwiftUI Extension

extension NameCard {
    public var suiCellView: some View {
        NameCardCellView(card: self)
    }
}
