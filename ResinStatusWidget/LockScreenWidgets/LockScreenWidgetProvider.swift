//
//  LockScreenWidgetsProvider.swift
//  GenshinPizzaHelper
//
//  Created by 戴藏龙 on 2022/9/27.
//

import Foundation
import WidgetKit

struct AccountOnlyEntry: TimelineEntry {
    let date: Date
    let result: FetchResult
    var accountName: String? = nil
}

struct LockScreenWidgetProvider: IntentTimelineProvider {
    // 填入在手表上显示的Widget配置内容，例如："的原粹树脂"
    let recommendationsTag: String

    @available(iOSApplicationExtension 16.0, *)
    func recommendations() -> [IntentRecommendation<SelectOnlyAccountIntent>] {
        let configs = AccountConfigurationModel.shared.fetchAccountConfigs()
        return configs.map { config in
            let intent = SelectOnlyAccountIntent()
            intent.account = .init(identifier: config.uuid!.uuidString, display: config.name!+"(\(config.server.rawValue))")
            return IntentRecommendation(intent: intent, description: config.name!+recommendationsTag.localized)
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
        let refreshMinute: Int = Int(UserDefaults(suiteName: "group.GenshinPizzaHelper")?.double(forKey: "lockscreenWidgetRefreshFrequencyInMinute") ?? 30)
        var refreshDate: Date {
            Calendar.current.date(byAdding: .minute, value: refreshMinute, to: currentDate)!
        }

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
//                refreshMinute = 1
                break
            }
            let timeline = Timeline(entries: [entry], policy: .after(refreshDate))
            completion(timeline)
            print("Widget Fetch succeed")
        }
    }
}
