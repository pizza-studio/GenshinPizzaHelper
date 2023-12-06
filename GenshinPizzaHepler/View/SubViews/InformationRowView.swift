//
//  InformationRowView.swift
//  GenshinPizzaHepler
//
//  Created by 戴藏龙 on 2023/12/5.
//

import Defaults
import Foundation
import SwiftUI

struct InformationRowView<L: View>: View {
    // MARK: Lifecycle

    init(_ title: LocalizedStringKey, @ViewBuilder labelContent: @escaping () -> L) {
        self.title = title
        self.labelContent = labelContent
    }

    // MARK: Internal

    let title: LocalizedStringKey
    @ViewBuilder
    let labelContent: () -> L

    var body: some View {
        VStack(alignment: .leading) {
            if !hideSubSectionTitleFromInformationRowView {
                Text(title).bold()
            }
            labelContent()
        }
    }

    // MARK: Private

    @Default(.hideSubSectionTitleFromInformationRowView)
    private var hideSubSectionTitleFromInformationRowView: Bool
}
