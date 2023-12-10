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

    @ViewBuilder
    let labelContent: () -> L

    let title: LocalizedStringKey

    var body: some View {
        VStack(alignment: .leading) {
            Text(title).bold()
            labelContent()
        }
    }
}
