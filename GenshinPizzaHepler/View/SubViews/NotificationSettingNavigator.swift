//
//  NotificationSettingNavigator.swift
//  GenshinPizzaHepler
//
//  Created by 戴藏龙 on 2022/8/21.
//  通知设置部分

import Defaults
import SFSafeSymbols
import SwiftUI

// MARK: - NotificationSettingNavigator

struct NotificationSettingNavigator: View {
    @Binding
    var selectedView: SettingsView.Navigation?

    @Environment(\.scenePhase)
    var scenePhase

    @Default(.allowResinNotification)
    var allowResinNotification: Bool
    @Default(.allowHomeCoinNotification)
    var allowHomeCoinNotification: Bool
    @Default(.allowExpeditionNotification)
    var allowExpeditionNotification: Bool
    @Default(.allowWeeklyBossesNotification)
    var allowWeeklyBossesNotification: Bool
    @Default(.allowTransformerNotification)
    var allowTransformerNotification: Bool
    @Default(.allowDailyTaskNotification)
    var allowDailyTaskNotification: Bool
    @Default(.allowFullResinNotification)
    var allowFullResinNotification: Bool

    @State
    var isNotificationHintShow: Bool = false

    @State
    var allowNotification: Bool = true

    var masterSwitch: Binding<Bool> {
        .init(get: {
            allowResinNotification || allowHomeCoinNotification ||
                allowExpeditionNotification ||
                allowWeeklyBossesNotification ||
                allowDailyTaskNotification ||
                allowTransformerNotification ||
                allowFullResinNotification

        }, set: { newValue in
            withAnimation {
                allowResinNotification = newValue
                allowHomeCoinNotification = newValue
                allowExpeditionNotification = newValue
                allowWeeklyBossesNotification = newValue
                allowDailyTaskNotification = newValue
                allowTransformerNotification = newValue
                allowFullResinNotification = newValue
            }
        })
    }

    var body: some View {
        Section {
            Toggle(isOn: masterSwitch.animation()) {
                Label("settings.notification.delivery", systemSymbol: .appBadge)
            }
            .disabled(!allowNotification)
            if masterSwitch.wrappedValue, allowNotification {
                NavigationLink(value: SettingsView.Navigation.notificationSetting) {
                    Label("settings.notification.deliverySettings", systemSymbol: .appBadgeFill)
                }
                .animation(.easeInOut, value: masterSwitch.wrappedValue)
            }
            if !allowNotification {
                Button("前往设置开启通知") {
                    UIApplication.shared
                        .open(URL(string: UIApplication.openSettingsURLString)!)
                }
            }
        } footer: {
            if !allowNotification {
                Text("未启用通知，请前往设置开启。")
            } else {
                if masterSwitch.wrappedValue {
                    Button("settings.howToUseNotifications") {
                        isNotificationHintShow = true
                    }
                    .font(.footnote)
                }
            }
        }
        .alert(isPresented: $isNotificationHintShow) {
            Alert(
                title: Text(
                    "您的通知均在本地创建，并在小组件自动刷新时，或您主动打开App时自动更新。\n长时间未打开App或未使用小组件可能会导致通知不准确。\n小组件若处于简洁模式下，部分通知可能仅能通过打开App刷新。"
                )
            )
        }
        .onAppear {
            UNUserNotificationCenter.current()
                .getNotificationSettings { settings in
                    withAnimation {
                        allowNotification = settings
                            .authorizationStatus == .provisional || settings
                            .authorizationStatus == .authorized
                    }
                }
        }
        .onChange(of: scenePhase) { newValue in
            if newValue == .active {
                UNUserNotificationCenter.current()
                    .getNotificationSettings { settings in
                        withAnimation {
                            allowNotification = settings
                                .authorizationStatus == .provisional || settings
                                .authorizationStatus == .authorized
                        }
                    }
            }
        }
    }
}
