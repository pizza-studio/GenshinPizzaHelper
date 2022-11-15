//
//  NotificationSettingNavigator.swift
//  GenshinPizzaHepler
//
//  Created by 戴藏龙 on 2022/8/21.
//  通知设置部分

import SwiftUI

struct NotificationSettingNavigator: View {
    @AppStorage("allowResinNotification", store: UserDefaults(suiteName: "group.GenshinPizzaHelper")) var allowResinNotification: Bool = true
    @AppStorage("allowHomeCoinNotification", store: UserDefaults(suiteName: "group.GenshinPizzaHelper")) var allowHomeCoinNotification: Bool = true
    @AppStorage("allowExpeditionNotification", store: UserDefaults(suiteName: "group.GenshinPizzaHelper")) var allowExpeditionNotification: Bool = true
    @AppStorage("allowWeeklyBossesNotification", store: UserDefaults(suiteName: "group.GenshinPizzaHelper")) var allowWeeklyBossesNotification: Bool = true
    @AppStorage("allowTransformerNotification", store: UserDefaults(suiteName: "group.GenshinPizzaHelper")) var allowTransformerNotification: Bool = true
    @AppStorage("allowDailyTaskNotification", store: UserDefaults(suiteName: "group.GenshinPizzaHelper")) var allowDailyTaskNotification: Bool = true

    @State var isNotificationHintShow: Bool = false
    
    var masterSwitch: Binding<Bool> {
        .init(get: {
            return (allowResinNotification || allowHomeCoinNotification || allowExpeditionNotification || allowWeeklyBossesNotification || allowDailyTaskNotification || allowTransformerNotification)
        }, set: { newValue in
            withAnimation {
                allowResinNotification = newValue
                allowHomeCoinNotification = newValue
                allowExpeditionNotification = newValue
                allowWeeklyBossesNotification = newValue
                allowDailyTaskNotification = newValue
                allowTransformerNotification = newValue
            }
        })
    }
    
    var body: some View {
        Section {
            Toggle(isOn: masterSwitch.animation()) {
                Text("通知推送")
            }
            if masterSwitch.wrappedValue {
                NavigationLink(destination: NotificationSettingView()) {
                    Text("通知推送设置")
                }
                .animation(.easeInOut, value: masterSwitch.wrappedValue)
            }
        } footer: {
            if masterSwitch.wrappedValue {
                Button("通知使用提示") {
                    isNotificationHintShow = true
                }
                .font(.footnote)
            }
        }
        .alert(isPresented: $isNotificationHintShow) {
            Alert(title: Text("您的通知均在本地创建，并在小组件自动刷新时，或您主动打开App时自动更新。\n长时间未打开App或未使用小组件可能会导致通知不准确。\n小组件若处于简洁模式下，部分通知可能仅能通过打开App刷新。"))
        }
    }
}
