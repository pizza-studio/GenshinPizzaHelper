//
//  WidgetTipsView.swift
//  GenshinPizzaHepler
//
//  Created by Bill Haku on 2022/9/6.
//

import SFSafeSymbols
import SwiftUI

struct WidgetTipsView: View {
    @Binding
    var isSheetShow: Bool

    var body: some View {
        NavigationStack {
            List {
                Section(header: Text("app.tips.widget.background.header").textCase(.none)) {
                    Label("app.tips.widget.background.1", systemSymbol: ._01Circle)
                        .padding(.vertical, 10)
                    Label("app.tips.widget.background.2", systemSymbol: ._02Circle)
                        .padding(.vertical, 10)
                }

                Section(header: Text("app.tips.widget.add.header").textCase(.none)) {
                    NavigationLink(
                        destination: WebBroswerView(
                            url: "https://support.apple.com/HT207122"
                        )
                        .navigationTitle("app.tips.widget.add.header")
                        .navigationBarTitleDisplayMode(.inline)
                    ) {
                        Label("app.tips.widget.add.1", systemSymbol: .safari)
                            .padding(.vertical, 10)
                    }
                    NavigationLink(
                        destination: WebBroswerView(
                            url: "https://support.apple.com/HT205536"
                        )
                        .navigationTitle("app.tips.widget.watch.add.header")
                        .navigationBarTitleDisplayMode(.inline)
                    ) {
                        Label(
                            "app.tips.widget.add.content",
                            systemSymbol: .safari
                        )
                        .padding(.vertical, 10)
                    }
                    Label(
                        "app.tips.widget.add.2",
                        systemSymbol: .exclamationmarkCircle
                    )
                    .padding(.vertical, 10)
                }

                Section(header: Text("app.tips.other").textCase(.none)) {
                    NavigationLink(
                        destination: WebBroswerView(
                            url: "https://gi.pizzastudio.org/static/faq.html"
                        )
                        .navigationTitle("FAQ")
                    ) {
                        Label(
                            "settings.misc.FAQ",
                            systemSymbol: .personFillQuestionmark
                        )
                    }
                }
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("sys.done") {
                        isSheetShow.toggle()
                    }
                }
            }
            .navigationTitle("app.tips.widget.title")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}
