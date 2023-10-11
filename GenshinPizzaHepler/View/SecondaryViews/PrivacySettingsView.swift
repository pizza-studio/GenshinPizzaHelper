//
//  PrivacySettingsView.swift
//  GenshinPizzaHepler
//
//  Created by 戴藏龙 on 2022/10/16.
//

import Defaults
import SwiftUI

struct PrivacySettingsView: View {
    @Default(.allowAbyssDataCollection)
    var allowAbyssDataCollection: Bool

    var body: some View {
        List {
            Section {
                Toggle(isOn: $allowAbyssDataCollection) {
                    Text("允许收集深渊数据")
                }
            } footer: {
                Text(
                    "我们希望收集您已拥有的角色和在攻克深渊时使用的角色。如果您同意我们使用您的数据，您将可以在App内查看我们实时汇总的深渊角色使用率、队伍使用率等情况。更多相关问题，请查看深渊统计榜单页面右上角的FAQ。"
                )
            }
        }
        .sectionSpacing(UIFont.systemFontSize)
        .frame(maxWidth: 550)
        .navigationBarTitle("隐私设置", displayMode: .inline)
    }
}
