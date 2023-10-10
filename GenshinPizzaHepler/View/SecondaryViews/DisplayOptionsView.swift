//
//  DisplayOptionsView.swift
//  GenshinPizzaHepler
//
//  Created by ShikiSuen on 2023/3/29.
//  界面偏好设置页面。

import Combine
import Defaults
import HBMihoyoAPI
import SwiftUI

// MARK: - DisplayOptionsView

struct DisplayOptionsView: View {
    // MARK: Public

    @Default(.useGuestGachaEvaluator)
    public var useGuestGachaEvaluator: Bool

    // MARK: Internal

    var body: some View {
        Group {
            mainView()
                .alert(
                    "settings.display.prompt.customizingNameForKunikuzushi",
                    isPresented: $isCustomizedNameForWandererAlertShow,
                    actions: {
                        TextField("settings.display.customizedNameForKunikuzushi", text: $customizedNameForWanderer)
                            .onReceive(Just(customizedNameForWanderer)) { _ in limitText(20) }
                        Button("完成") {
                            isCustomizedNameForWandererAlertShow.toggle()
                        }
                    }
                )
        }
        .navigationBarTitle("settings.display.title", displayMode: .inline)
    }

    // Function to keep text length in limits
    func limitText(_ upper: Int) {
        if customizedNameForWanderer.count > upper {
            customizedNameForWanderer = String(customizedNameForWanderer.prefix(upper))
        }
    }

    @ViewBuilder
    func mainView() -> some View {
        List {
            if Locale.isUILanguagePanChinese {
                Section {
                    Toggle(isOn: $forceCharacterWeaponNameFixed) {
                        Text("settings.display.chineseKanjiCorrection.title")
                    }
                } footer: {
                    Text(
                        "settings.display.chineseKanjiCorrection.description"
                    )
                }
            }

            Section {
                Toggle(isOn: $showRarityAndLevelForArtifacts) {
                    Text("settings.display.showArtifactRarityAndLevel")
                }
                Toggle(isOn: $showRatingsForArtifacts) {
                    Text("settings.display.showArtifactRank")
                }
            }

            Section {
                Toggle(isOn: $useActualCharacterNames) {
                    Text("settings.display.showTheRealNameForKunikuzushi")
                }

                if !useActualCharacterNames {
                    if #unavailable(iOS 16) {
                        HStack {
                            Text("settings.display.customizingNameForKunikuzushi")
                            Spacer()
                            TextField("流浪者".localized, text: $customizedNameForWanderer)
                                .multilineTextAlignment(.trailing)
                        }
                    } else {
                        HStack {
                            Text("settings.display.customizingNameForKunikuzushi")
                            Spacer()
                            Button(customizedNameForWanderer == "" ? "流浪者".localized : customizedNameForWanderer) {
                                isCustomizedNameForWandererAlertShow.toggle()
                            }
                        }
                    }
                }
            }

            if ThisDevice.notchType != .none || OS.type != .iPhoneOS {
                Section {
                    Toggle(isOn: $adaptiveSpacingInCharacterView) {
                        Text("settings.display.autoLineSpacingForECDDV")
                    }
                } footer: {
                    Text(
                        "settings.display.autoLineSpacingForECDDV.onlyWorksWithNotchedPhones"
                    )
                }
            }

            Section {
                Toggle(isOn: $cutShouldersForSmallAvatarPhotos) {
                    Text("settings.display.cutShouldersForSmallPhotos")
                }
            }

            Section {
                Toggle(isOn: $useGuestGachaEvaluator) {
                    Text("settings.uiRelated.useGuestGachaEvaluator")
                }
            }
        }
    }

    // MARK: Private

    @ObservedObject
    private var viewModel: MoreViewCacheViewModel = .init()

    @State
    private var isCustomizedNameForWandererAlertShow: Bool = false

    @Default(.adaptiveSpacingInCharacterView)
    private var adaptiveSpacingInCharacterView: Bool
    @Default(.showRarityAndLevelForArtifacts)
    private var showRarityAndLevelForArtifacts: Bool
    @Default(.showRatingsForArtifacts)
    private var showRatingsForArtifacts: Bool
    @Default(.forceCharacterWeaponNameFixed)
    private var forceCharacterWeaponNameFixed: Bool
    @Default(.useActualCharacterNames)
    private var useActualCharacterNames: Bool
    @Default(.customizedNameForWanderer)
    private var customizedNameForWanderer: String
    @Default(.cutShouldersForSmallAvatarPhotos)
    private var cutShouldersForSmallAvatarPhotos: Bool
}
