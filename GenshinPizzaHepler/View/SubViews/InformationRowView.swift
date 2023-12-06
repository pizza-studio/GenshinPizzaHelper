//
//  InformationRowView.swift
//  GenshinPizzaHepler
//
//  Created by 戴藏龙 on 2023/12/5.
//

import Foundation
import SwiftUI

struct InformationRowView<L: View>: View {
    // MARK: Lifecycle

    init(_ title: LocalizedStringKey, @ViewBuilder label: @escaping () -> L) {
        self.title = title
        self.label = label
    }

    // MARK: Internal

    let title: LocalizedStringKey
    @ViewBuilder
    let label: () -> L

    var body: some View {
        VStack(alignment: .leading) {
            Text(title).bold()
            label()
        }
    }
}
