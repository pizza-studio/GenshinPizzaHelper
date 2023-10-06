//
//  DisplayOptionsView.swift
//  GenshinPizzaHepler
//
//  Created by ShikiSuen on 2023/3/29.
//  界面偏好设置页面。

import Combine
import HBMihoyoAPI
import SwiftUI

// MARK: - DisplayOptionsView

struct DisplayOptionsView: View {
    // MARK: Public

    @AppStorage(
        "useGuestGachaEvaluator",
        store: .init(suiteName: "group.GenshinPizzaHelper")
    )
    public var useGuestGachaEvaluator: Bool = false

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

    @State
    private var isCustomizedNameForWandererAlertShow: Bool = false

    @AppStorage(
        "adaptiveSpacingInCharacterView",
        store: .init(suiteName: "group.GenshinPizzaHelper")
    )
    private var adaptiveSpacingInCharacterView: Bool = true

    @AppStorage(
        "showRarityAndLevelForArtifacts",
        store: UserDefaults(suiteName: "group.GenshinPizzaHelper")
    )
    private var showRarityAndLevelForArtifacts: Bool = true

    @AppStorage(
        "showRatingsForArtifacts",
        store: UserDefaults(suiteName: "group.GenshinPizzaHelper")
    )
    private var showRatingsForArtifacts: Bool = true

    @ObservedObject
    private var viewModel: MoreViewCacheViewModel = .init()

    @AppStorage(
        "forceCharacterWeaponNameFixed",
        store: .init(suiteName: "group.GenshinPizzaHelper")
    )
    private var forceCharacterWeaponNameFixed: Bool = false
    @AppStorage(
        "useActualCharacterNames",
        store: .init(suiteName: "group.GenshinPizzaHelper")
    )
    private var useActualCharacterNames: Bool = false

    @AppStorage(
        "customizedNameForWanderer",
        store: .init(suiteName: "group.GenshinPizzaHelper")
    )
    private var customizedNameForWanderer: String = ""

    @AppStorage(
        "cutShouldersForSmallAvatarPhotos",
        store: .init(suiteName: "group.GenshinPizzaHelper")
    )
    private var cutShouldersForSmallAvatarPhotos: Bool = false
}
