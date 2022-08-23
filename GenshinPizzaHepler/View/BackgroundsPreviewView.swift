//
//  BackgroundsPreviewView.swift
//  GenshinPizzaHepler
//
//  Created by 戴藏龙 on 2022/8/22.
//

import SwiftUI


struct BackgroundsPreviewView: View {
    let backgroundOptions: [String] = BackgroundOptions.namecards
    @State private var searchText = ""

    func generateBackground(_ backgroundString: String) -> WidgetBackground {
        WidgetBackground(identifier: backgroundString, display: backgroundString)
    }

    var body: some View {
        NavigationView {
            if #available(iOS 15.0, *) {
                List {

                    ForEach(searchResults, id: \.self) { backgroundImageName in
                        Section {
                            WidgetBackgroundView(background: generateBackground(backgroundImageName), darkModeOn: false)
                                .listRowInsets(.init(top: 0, leading: 0, bottom: 0, trailing: 0))
                                .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                        } header: {
                            Text(backgroundImageName)
                        }



                    }
                }
                .listStyle(.insetGrouped)
                .searchable(text: $searchText)
                .navigationTitle("背景名片预览")
            } else {
                List {

                    ForEach(backgroundOptions, id: \.self) { backgroundImageName in
                        Section {
                            WidgetBackgroundView(background: generateBackground(backgroundImageName), darkModeOn: false)
                                .listRowInsets(.init(top: 0, leading: 0, bottom: 0, trailing: 0))
                                .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                        } header: {
                            Text(backgroundImageName)
                        }



                    }
                }
                .listStyle(.insetGrouped)
                .navigationTitle("背景名片预览")
            }


        }
    }

    var searchResults: [String] {
        if searchText.isEmpty {
            return backgroundOptions
        } else {
            return backgroundOptions.filter { $0.contains(searchText) }
        }
    }

}
@available(iOS 15.0, *)
struct BackgroundsPreviewView_Previews: PreviewProvider {

    static var previews: some View {
        BackgroundsPreviewView()
    }
}
