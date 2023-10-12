//
//  NotificationSettingView.swift
//  GenshinPizzaHepler
//
//  Created by 戴藏龙 on 2022/8/20.
//  通知设置View

import Defaults
import SwiftUI

// MARK: - NotificationSettingView

struct NotificationSettingView: View {
    @EnvironmentObject
    var viewModel: ViewModel

    @State
    var showResinSlider: Bool = false
    @State
    var showHomeCoinSlider: Bool = false

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
    @Default(.resinNotificationNum)
    var resinNotificationNum: Double
    @Default(.homeCoinNotificationHourBeforeFull)
    var homeCoinNotificationHourBeforeFull: Double
    @Default(.noticeExpeditionMethodRawValue)
    var noticeExpeditionMethodRawValue: Int
    @Default(.weeklyBossesNotificationTimePointData)
    var weeklyBossesNotificationTimePointData: Data
    @Default(.dailyTaskNotificationTimePointData)
    var dailyTaskNotificationTimePointData: Data

    var noticeExpeditionBy: Binding<ExpeditionNoticeMethod> {
        .init(get: {
            .init(rawValue: noticeExpeditionMethodRawValue)!
        }, set: {
            noticeExpeditionMethodRawValue = $0.rawValue
        })
    }

    var weeklyBossesNotificationTime: Binding<Date> {
        .init(get: {
            let dateComponents = try! JSONDecoder()
                .decode(
                    DateComponents.self,
                    from: weeklyBossesNotificationTimePointData
                )
            return Calendar.current.nextDate(
                after: Date(),
                matching: dateComponents,
                matchingPolicy: .nextTime
            )!
        }, set: {
            do {
                let dateComponents = Calendar.current.dateComponents(
                    [.calendar, .weekday, .hour, .minute],
                    from: $0
                )
                let finishingDatesData = try JSONEncoder()
                    .encode(dateComponents)
                weeklyBossesNotificationTimePointData = finishingDatesData
            } catch {
                print(error)
            }
        })
    }

    var weeklyBossesWeekday: Binding<Int> {
        .init(get: {
            let dateComponents = try! JSONDecoder()
                .decode(
                    DateComponents.self,
                    from: weeklyBossesNotificationTimePointData
                )
            return dateComponents.weekday!
        }, set: {
            do {
                var dateComponents = try JSONDecoder()
                    .decode(
                        DateComponents.self,
                        from: weeklyBossesNotificationTimePointData
                    )
                dateComponents.weekday = $0
                let finishingDatesData = try JSONEncoder()
                    .encode(dateComponents)
                weeklyBossesNotificationTimePointData = finishingDatesData
            } catch {
                print(error)
            }
        })
    }

    var dailyTaskNotificationTime: Binding<Date> {
        .init(get: {
            let dateComponents = try! JSONDecoder()
                .decode(
                    DateComponents.self,
                    from: dailyTaskNotificationTimePointData
                )
            return Calendar.current.nextDate(
                after: Date(),
                matching: dateComponents,
                matchingPolicy: .nextTime
            )!
        }, set: {
            do {
                let dateComponents = Calendar.current.dateComponents(
                    [.calendar, .hour, .minute],
                    from: $0
                )
                let finishingDatesData = try JSONEncoder()
                    .encode(dateComponents)
                dailyTaskNotificationTimePointData = finishingDatesData
            } catch {
                print(error)
            }
        })
    }

    var body: some View {
        List {
            Section {
                Text("settings.notification.disclaimer.onlyWorksWithNewNotifications")
            }
            Section {
                NavigationLink(
                    destination: IgnoreNotificationAccountView()
                        .environmentObject(viewModel)
                ) {
                    Text("settings.notification.accountsReceivingNotifications")
                }
            }
            Section {
                Toggle(isOn: $allowResinNotification.animation()) {
                    Text("settings.notification.type.resin")
                }
                if allowResinNotification {
                    HStack {
                        Text("settings.notification.threshold")
                        Spacer()
                        Button(action: {
                            withAnimation { showResinSlider.toggle() }
                        }) {
                            Text("unit.resin:\(Int(resinNotificationNum))")
                        }
                    }
                    if showResinSlider {
                        Slider(
                            value: $resinNotificationNum,
                            in: 10 ... 150,
                            step: 5.0,
                            label: {
                                Text("settings.notification.threshold".localized + ": \(resinNotificationNum)")
                            }
                        )
                    }
                    Toggle(isOn: $allowFullResinNotification) {
                        Text("settings.notification.resinOverflown")
                    }
                }
            }

            Section {
                Toggle(isOn: $allowHomeCoinNotification.animation()) {
                    Text("settings.notification.type.realmCurrency")
                }
                if allowHomeCoinNotification {
                    HStack {
                        Text("settings.notification.whenToNotify.time")
                        Spacer()
                        Button(action: {
                            withAnimation { showHomeCoinSlider.toggle() }

                        }) {
                            Text(
                                "settings.notification.hrsBeforeFullyFilled:\(Int(homeCoinNotificationHourBeforeFull))"
                            )
                        }
                    }
                    if showHomeCoinSlider {
                        Slider(
                            value: $homeCoinNotificationHourBeforeFull,
                            in: 1 ... 24,
                            step: 1,
                            label: {
                                Text(
                                    "settings.notification.threshold"
                                        .localized + ": \(homeCoinNotificationHourBeforeFull)"
                                )
                            }
                        )
                    }
                }
            }

            Section {
                Toggle(isOn: $allowExpeditionNotification.animation()) {
                    Text("settings.notification.type.expedition")
                }
                if allowExpeditionNotification {
                    Picker("settings.notification.whenToNotify.timing", selection: noticeExpeditionBy) {
                        Text("settings.notification.expedition.condition.allFinished")
                            .tag(ExpeditionNoticeMethod.allCompleted)
                        Text("settings.notification.expedition.condition.anyFinished")
                            .tag(ExpeditionNoticeMethod.nextCompleted)
                    }
                }
            }

            Section {
                Toggle(isOn: $allowDailyTaskNotification.animation()) {
                    Text("settings.notification.type.dailyCommission")
                }
                if allowDailyTaskNotification {
                    DatePicker(
                        "settings.notification.whenToNotify.time",
                        selection: dailyTaskNotificationTime,
                        displayedComponents: .hourAndMinute
                    )
                }
            }

            Section {
                Toggle(isOn: $allowWeeklyBossesNotification.animation()) {
                    Text("settings.notification.type.weeklyBosses")
                }
                if allowWeeklyBossesNotification {
                    DatePicker(
                        "settings.notification.whenToNotify.time",
                        selection: weeklyBossesNotificationTime,
                        displayedComponents: .hourAndMinute
                    )
                    Picker("settings.notification.whenToNotify.date", selection: weeklyBossesWeekday) {
                        Text("week.monday").tag(2)
                        Text("week.tuesday").tag(3)
                        Text("week.wednesday").tag(4)
                        Text("week.thursday").tag(5)
                        Text("week.friday").tag(6)
                        Text("week.saturday").tag(7)
                        Text("week.sunday").tag(1)
                    }
                }
            }

            Toggle(isOn: $allowTransformerNotification.animation()) {
                Text("settings.notification.type.parametricTransformer")
            }
        }
        .sectionSpacing(UIFont.systemFontSize)
        .navigationBarTitle("settings.notification.deliverySettings", displayMode: .inline)
    }
}

// MARK: - IgnoreNotificationAccountView

struct IgnoreNotificationAccountView: View {
    @EnvironmentObject
    var viewModel: ViewModel
    @Default(.notificationIgnoreUidsData)
    var data: Data

    var configs: [AccountConfiguration] { viewModel.accounts.map { $0.config } }

    var ignoreUids: Binding<[String]> {
        .init {
            try! JSONDecoder().decode([String].self, from: data)
        } set: { uids in
            data = try! JSONEncoder().encode(uids)
        }
    }

    var body: some View {
        List {
            ForEach(configs, id: \.uuid) { config in
                IgnoreNotificationAccountItem(
                    isOn: !ignoreUids.wrappedValue.contains(config.uid!),
                    ignoreUids: ignoreUids,
                    config: config
                )
            }
        }
        .sectionSpacing(UIFont.systemFontSize)
    }
}

// MARK: - IgnoreNotificationAccountItem

private struct IgnoreNotificationAccountItem: View {
    @State
    var isOn: Bool
    @Binding
    var ignoreUids: [String]
    var config: AccountConfiguration

    var body: some View {
        Toggle(isOn: $isOn) {
            Text("\(config.name!) (\(config.uid!))")
        }
        .onAppear {
            if !isOn {
                ignoreUids.append(config.uid!)
            } else {
                ignoreUids = ignoreUids.filter { item in
                    item != config.uid!
                }
            }
        }
        .onChange(of: isOn) { newValue in
            if !newValue {
                ignoreUids.append(config.uid!)
                print("Added \(config.uid!) into ignore list")
            } else {
                ignoreUids = ignoreUids.filter { item in
                    item != config.uid!
                }
                print("Removed \(config.uid!) from ignore list")
            }
        }
    }
}
