//
//  NotificationSettingNavigator.swift
//  GenshinPizzaHepler
//
//  Created by 戴藏龙 on 2022/8/21.
//

import SwiftUI

struct NotificationSettingNavigator: View {
    @AppStorage("allowResinNotification", store: UserDefaults(suiteName: "group.GenshinPizzaHelper")) var allowResinNotification: Bool = true
    @AppStorage("allowHomeCoinNotification", store: UserDefaults(suiteName: "group.GenshinPizzaHelper")) var allowHomeCoinNotification: Bool = true
    @AppStorage("allowExpeditionNotification", store: UserDefaults(suiteName: "group.GenshinPizzaHelper")) var allowExpeditionNotification: Bool = true
    @AppStorage("allowWeeklyBossesNotification", store: UserDefaults(suiteName: "group.GenshinPizzaHelper")) var allowWeeklyBossesNotification: Bool = true
    @AppStorage("allowTransformerNotification", store: UserDefaults(suiteName: "group.GenshinPizzaHelper")) var allowTransformerNotification: Bool = true
    @AppStorage("allowDailyTaskNotification", store: UserDefaults(suiteName: "group.GenshinPizzaHelper")) var allowDailyTaskNotification: Bool = true
    
    var masterSwitch: Binding<Bool> {
        .init(get: {
            return (allowResinNotification || allowHomeCoinNotification || allowExpeditionNotification || allowWeeklyBossesNotification || allowDailyTaskNotification)
        }, set: { newValue in
            withAnimation {
                allowResinNotification = newValue
                allowHomeCoinNotification = newValue
                allowExpeditionNotification = newValue
                allowWeeklyBossesNotification = newValue
                allowDailyTaskNotification = newValue
            }
        })
    }
    
    var body: some View {
        Section {
            Toggle(isOn: masterSwitch.animation()) {
                Text("开启通知")
            }
            if masterSwitch.wrappedValue {
                NavigationLink(destination: NotificationSettingView()) {
                    Text("通知设置")
                }
                .animation(.easeInOut, value: masterSwitch.wrappedValue)
            }
        }
    }
}

