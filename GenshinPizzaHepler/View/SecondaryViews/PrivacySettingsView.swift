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
                    Text("settings.privacy.abyssDataCollect")
                }
            } footer: {
                Text(
                    "settings.privacy.abyssDataCollect.detail"
                )
            }
        }
        .navigationBarTitle("settings.privacy.title", displayMode: .inline)
    }
}
