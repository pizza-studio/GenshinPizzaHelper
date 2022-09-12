//
//  AlternativeWatchCornerResinWidget.swift
//  GenshinPizzaHelper
//
//  Created by 戴藏龙 on 2022/9/12.
//

import SwiftUI
import WidgetKit

@available(iOSApplicationExtension 16.0, *)
struct LockScreenAllInfoWidget: Widget {
    let kind: String = "LockScreenAllInfoWidget"

    var body: some WidgetConfiguration {
        IntentConfiguration(kind: kind, intent: SelectOnlyAccountIntent.self, provider: LockScreenAllInfoWidgetProvider()) { entry in
            LockScreenAllInfoWidgetView(entry: entry)
        }
        .configurationDisplayName("综合信息")
        .description("所有信息，一网打尽")
        .supportedFamilies([.accessoryRectangular])
    }
}

@available (iOS 16.0, *)
struct LockScreenAllInfoWidgetView: View {
    @Environment(\.widgetFamily) var family: WidgetFamily
    let entry: LockScreenResinWidgetProvider.Entry
    var result: FetchResult { entry.result }
    var accountName: String? { entry.accountName }

    var body: some View {
        switch result {
        case .success(let data):
            Grid(alignment: .leadingFirstTextBaseline, horizontalSpacing: 3, verticalSpacing: 2) {
                GridRow(alignment: .lastTextBaseline) {
                    Text("\(Image("icon.resin"))")
                        .widgetAccentable()
                    Text("\(data.resinInfo.currentResin)")
                    Spacer()
                    Text("\(Image("icon.expedition"))")
                        .widgetAccentable()
                    HStack(alignment: .lastTextBaseline, spacing: 0) {
                        Text("\(data.expeditionInfo.currentOngoingTask)")
                        Text(" / \(data.expeditionInfo.maxExpedition)")
                            .font(.caption)
                    }
                    Spacer()
                }
                GridRow(alignment: .lastTextBaseline) {
                    Text("\(Image("icon.homeCoin"))")
                        .widgetAccentable()
                    Text("\(data.homeCoinInfo.currentHomeCoin)")
                    Spacer()
                    Text("\(Image("icon.dailyTask"))")
                        .widgetAccentable()
                    HStack(alignment: .lastTextBaseline, spacing: 0) {
                        Text("\(data.dailyTaskInfo.finishedTaskNum)")
                        Text(" / \(data.dailyTaskInfo.totalTaskNum)")
                            .font(.caption)
                    }
                }
                GridRow(alignment: .lastTextBaseline) {
                    Text("\(Image("icon.transformer"))")
                        .widgetAccentable()
                    Text(data.transformerInfo.recoveryTime.describeIntervalShort(finishedTextPlaceholder: "可使用"))
                    Spacer()
                    Text("\(Image("icon.weeklyBosses"))")
                        .widgetAccentable()
                    HStack(alignment: .lastTextBaseline, spacing: 0) {
                        Text("\(data.weeklyBossesInfo.hasUsedResinDiscountNum)")
                        Text(" / \(data.weeklyBossesInfo.resinDiscountNumLimit)")
                            .font(.caption)
                    }
                    Spacer()
                }
            }
        case .failure(_):
            Grid(alignment: .leadingFirstTextBaseline, horizontalSpacing: 3, verticalSpacing: 2) {
                GridRow(alignment: .lastTextBaseline) {
                    Text("\(Image("icon.resin"))")
                        .widgetAccentable()
                    Text(Image(systemName: "ellipsis"))
                    Spacer()
                    Text("\(Image("icon.expedition"))")
                        .widgetAccentable()
                    HStack(alignment: .lastTextBaseline, spacing: 0) {
                        Text(Image(systemName: "ellipsis"))
                    }
                    Spacer()
                }
                GridRow(alignment: .lastTextBaseline) {
                    Text("\(Image("icon.homeCoin"))")
                        .widgetAccentable()
                    Text("\(Image(systemName: "ellipsis"))")
                    Spacer()
                    Text("\(Image("icon.dailyTask"))")
                        .widgetAccentable()
                    HStack(alignment: .lastTextBaseline, spacing: 0) {
                        Text(Image(systemName: "ellipsis"))
                    }
                }
                GridRow(alignment: .lastTextBaseline) {
                    Text("\(Image("icon.transformer"))")
                        .widgetAccentable()
                    Text(Image(systemName: "ellipsis"))
                    Spacer()
                    Text("\(Image("icon.weeklyBosses"))")
                        .widgetAccentable()
                    HStack(alignment: .lastTextBaseline, spacing: 0) {
                        Text(Image(systemName: "ellipsis"))
                    }
                    Spacer()
                }
            }
        }
    }
}

struct LockScreenAllInfoWidgetProvider: IntentTimelineProvider {
    @available(iOSApplicationExtension 16.0, *)
    func recommendations() -> [IntentRecommendation<SelectOnlyAccountIntent>] {
        let configs = AccountConfigurationModel.shared.fetchAccountConfigs()
        return configs.map { config in
            let intent = SelectOnlyAccountIntent()
            intent.account = .init(identifier: config.uuid!.uuidString, display: config.name!+"(\(config.server.rawValue))")
            return IntentRecommendation(intent: intent, description: config.name!+"的所有信息")
        }
    }

    func placeholder(in context: Context) -> AccountOnlyEntry {
        AccountOnlyEntry(date: Date(), result: FetchResult.defaultFetchResult, accountName: "荧")
    }

    func getSnapshot(for configuration: SelectOnlyAccountIntent, in context: Context, completion: @escaping (AccountOnlyEntry) -> ()) {
        let entry = AccountOnlyEntry(date: Date(), result: FetchResult.defaultFetchResult, accountName: "荧")
        completion(entry)
    }

    func getTimeline(for configuration: SelectOnlyAccountIntent, in context: Context, completion: @escaping (Timeline<AccountOnlyEntry>) -> ()) {

        // Generate a timeline consisting of five entries an hour apart, starting from the current date.
        let currentDate = Date()
        let refreshDate = Calendar.current.date(byAdding: .minute, value: 7, to: currentDate)!

        let accountConfigurationModel = AccountConfigurationModel.shared
        let configs = accountConfigurationModel.fetchAccountConfigs()

        guard !configs.isEmpty else {
            let entry = AccountOnlyEntry(date: currentDate, result: .failure(.noFetchInfo))
            let timeline = Timeline(entries: [entry], policy: .after(refreshDate))
            completion(timeline)
            return
        }

        guard configuration.account != nil else {
            // 如果还未选择账号，默认获取第一个
            configs.first!.fetchResult { result in
                let entry = AccountOnlyEntry(date: currentDate, result: result, accountName: configs.first!.name)
                let timeline = Timeline(entries: [entry], policy: .after(refreshDate))
                completion(timeline)
                print("Widget Fetch succeed")
            }
            return
        }

        let selectedAccountUUID = UUID(uuidString: configuration.account!.identifier!)
        print(configs.first!.uuid!, configuration)

        guard let config = configs.first(where: { $0.uuid == selectedAccountUUID }) else {
            // 有时候删除账号，Intent没更新就会出现这样的情况
            let entry = AccountOnlyEntry(date: currentDate, result: .failure(.noFetchInfo))
            let timeline = Timeline(entries: [entry], policy: .after(refreshDate))
            completion(timeline)
            print("Need to choose account")
            return
        }

        // 正常情况
        config.fetchResult { result in
            let entry = AccountOnlyEntry(date: currentDate, result: result, accountName: config.name)

            switch result {
            case .success(let userData):
                #if !os(watchOS)
                UserNotificationCenter.shared.createAllNotification(for: config.name ?? "", with: userData, uid: config.uid!)
                #endif
            case .failure(_ ):
                break
            }

            let timeline = Timeline(entries: [entry], policy: .after(refreshDate))
            completion(timeline)
            print("Widget Fetch succeed")
        }
    }
}
