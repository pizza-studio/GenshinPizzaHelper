//
//  LiveActivitySettingNavigator.swift
//  GenshinPizzaHepler
//
//  Created by 戴藏龙 on 2022/11/19.
//

import Defaults
import GIPizzaKit
import SFSafeSymbols
import SwiftUI

#if canImport(ActivityKit)
@available(iOS 16.1, *)
struct LiveActivitySettingNavigator: View {
    @Binding
    var selectedView: SettingsView.Navigation?

    @State
    var isAlertShow: Bool = false

    var body: some View {
        Section {
            NavigationLink(value: SettingsView.Navigation.resinTimerSetting) {
                Label("settings.resinTimer.title", systemSymbol: .timer)
            }
        } footer: {
            Button("widget.autoResinTimer.explanation") {
                isAlertShow.toggle()
            }
            .font(.footnote)
        }
        .alert(
            "widget.autoResinTimer.explanation.detail",
            isPresented: $isAlertShow
        ) {
            Button("OK") {
                isAlertShow.toggle()
            }
        }
    }
}

@available(iOS 16.1, *)
struct LiveActivitySettingDetailView: View {
    // MARK: Internal

    @Environment(\.scenePhase)
    var scenePhase

    @Default(.resinRecoveryLiveActivityUseEmptyBackground)
    var resinRecoveryLiveActivityUseEmptyBackground: Bool
    @Default(.resinRecoveryLiveActivityUseCustomizeBackground)
    var resinRecoveryLiveActivityUseCustomizeBackground: Bool
    @Default(.autoDeliveryResinTimerLiveActivity)
    var autoDeliveryResinTimerLiveActivity: Bool
    @Default(.resinRecoveryLiveActivityShowExpedition)
    var resinRecoveryLiveActivityShowExpedition: Bool
    @Default(.autoUpdateResinRecoveryTimerUsingReFetchData)
    var autoUpdateResinRecoveryTimerUsingReFetchData: Bool

    var useRandomBackground: Binding<Bool> {
        .init {
            !resinRecoveryLiveActivityUseCustomizeBackground
        } set: { newValue in
            resinRecoveryLiveActivityUseCustomizeBackground = !newValue
        }
    }

    var body: some View {
        List {
            if !allowLiveActivity {
                Section {
                    Label {
                        Text("settings.realtimeActivity.notEnabled")
                    } icon: {
                        Image(systemSymbol: .exclamationmarkCircle)
                            .foregroundColor(.red)
                    }
                    Button("widget.autoResinTimer.explanation.gotoSettings") {
                        UIApplication.shared
                            .open(URL(
                                string: UIApplication
                                    .openSettingsURLString
                            )!)
                    }
                }
            }

            Group {
                Section {
                    Toggle(
                        "widget.autoResinTimer",
                        isOn: $autoDeliveryResinTimerLiveActivity
                            .animation()
                    )
                }
                Section {
                    Button("settings.dynamicIsland.howToHide") {
                        isHowToCloseDynamicIslandAlertShow.toggle()
                    }
                }
                Section {
                    Toggle(
                        "settings.showExpedition.title",
                        isOn: $resinRecoveryLiveActivityShowExpedition
                    )
                }
                Section {
                    Toggle(
                        "settings.useTransparentBackground.title",
                        isOn: $resinRecoveryLiveActivityUseEmptyBackground
                            .animation()
                    )
                    if !resinRecoveryLiveActivityUseEmptyBackground {
                        Toggle(
                            "settings.randomBackground.title",
                            isOn: useRandomBackground.animation()
                        )
                        if resinRecoveryLiveActivityUseCustomizeBackground {
                            NavigationLink("settings.background.choose") {
                                LiveActivityBackgroundPicker()
                            }
                        }
                    }
                } header: {
                    Text("settings.resinTimer.background.title")
                }
            }
            .disabled(!allowLiveActivity)
        }
        .toolbar {
            ToolbarItem {
                Button {
                    isHelpSheetShow.toggle()
                } label: {
                    Image(systemSymbol: .questionmarkCircle)
                }
            }
        }
        .navigationTitle("settings.resinTimer.title")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $isHelpSheetShow) {
            NavigationStack {
                WebBrowserView(
                    url: "https://gi.pizzastudio.org/static/resin_timer_help.html"
                )
                .dismissableSheet(isSheetShow: $isHelpSheetShow)
            }
        }
        .alert(
            "settings.dynamicIsland.title",
            isPresented: $isHowToCloseDynamicIslandAlertShow
        ) {
            Button("OK") {
                isHowToCloseDynamicIslandAlertShow.toggle()
            }
        } message: {
            Text("settings.dynamicIsland.howToHide.answer")
        }
        .onAppear {
            withAnimation {
                allowLiveActivity = ResinRecoveryActivityController.shared
                    .allowLiveActivity
            }
        }
        .onChange(of: scenePhase) { newValue in
            if newValue == .active {
                UNUserNotificationCenter.current()
                    .getNotificationSettings { _ in
                        withAnimation {
                            allowLiveActivity =
                                ResinRecoveryActivityController
                                    .shared.allowLiveActivity
                        }
                    }
            }
        }
    }

    // MARK: Private

    @State
    private var isHelpSheetShow: Bool = false

    @State
    private var isHowToCloseDynamicIslandAlertShow: Bool = false

    @State
    private var allowLiveActivity: Bool = ResinRecoveryActivityController
        .shared.allowLiveActivity
}

@available(iOS 16.1, *)
struct LiveActivityBackgroundPicker: View {
    @State
    private var searchText = ""
    @Default(.resinRecoveryLiveActivityBackgroundOptions)
    var resinRecoveryLiveActivityBackgroundOptions: [String]

    var body: some View {
        List {
            ForEach(searchResults, id: \.rawValue) { backgroundImageView in
                HStack {
                    Label {
                        Text(
                            backgroundImageView.localized
                        )
                    } icon: {
                        GeometryReader { g in
                            Image(backgroundImageView.fileName)
                                .resizable()
                                .scaledToFill()
                                .offset(x: -g.size.width)
                        }
                        .clipShape(Circle())
                        .frame(width: 30, height: 30)
                    }
                    Spacer()
                    if resinRecoveryLiveActivityBackgroundOptions
                        .contains(backgroundImageView.fileName) {
                        Button {
                            resinRecoveryLiveActivityBackgroundOptions
                                .removeAll { name in
                                    name == backgroundImageView.fileName
                                }
                        } label: {
                            Image(systemSymbol: .checkmarkCircleFill)
                                .foregroundColor(.accentColor)
                        }
                    } else {
                        Button {
                            resinRecoveryLiveActivityBackgroundOptions
                                .append(backgroundImageView.fileName)
                        } label: {
                            Image(systemSymbol: .checkmarkCircle)
                                .foregroundColor(.accentColor)
                        }
                    }
                }
            }
        }
        .searchable(text: $searchText)
        .navigationTitle("settings.timer.chooseBackground")
        .navigationBarTitleDisplayMode(.inline)
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
}
#endif
