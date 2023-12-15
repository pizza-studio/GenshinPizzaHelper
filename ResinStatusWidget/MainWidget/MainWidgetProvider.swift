//
//  Model.swift
//  Genshin Resin Checker
//
//  Created by 戴藏龙 on 2022/7/12.
//  Widget功能提供

import Defaults
import Foundation
import HoYoKit
import SwiftUI

import GIPizzaKit
import WidgetKit

// MARK: - ResinEntry

struct ResinEntry: TimelineEntry {
    let date: Date
    let result: Result<any DailyNote, any Error>
    let viewConfig: WidgetViewConfiguration
    var accountName: String?
    var relevance: TimelineEntryRelevance? = .init(score: 0)
    let accountUUIDString: String?
}

// MARK: - MainWidgetProvider

struct MainWidgetProvider: IntentTimelineProvider {
    func placeholder(in context: Context) -> ResinEntry {
        ResinEntry(
            date: Date(),
            result: .success(GeneralDailyNote.exampleData()),
            viewConfig: .defaultConfig,
            accountName: "荧",
            accountUUIDString: ""
        )
    }

    func getSnapshot(
        for configuration: SelectAccountIntent,
        in context: Context,
        completion: @escaping (ResinEntry) -> ()
    ) {
        let entry = ResinEntry(
            date: Date(),
            result: .success(GeneralDailyNote.exampleData()),
            viewConfig: .defaultConfig,
            accountName: "荧",
            accountUUIDString: ""
        )
        completion(entry)
    }

    func getTimeline(
        for configuration: SelectAccountIntent,
        in context: Context,
        completion: @escaping (Timeline<ResinEntry>) -> ()
    ) {
        // Generate a timeline consisting of five entries an hour apart, starting from the current date.
//        var syncFrequencyInMinute = Int(Defaults[.mainWidgetSyncFrequencyInMinute])
//        if syncFrequencyInMinute == 0 { syncFrequencyInMinute = 60 }
        let syncFrequencyInMinute = widgetRefreshByMinute
        let currentDate = Date()
        let refreshDate = Calendar.current.date(
            byAdding: .minute,
            value: syncFrequencyInMinute,
            to: currentDate
        )!

        let accountConfigurationModel = AccountConfigurationModel.shared
        let configs = accountConfigurationModel.fetchAccountConfigs()

        var viewConfig: WidgetViewConfiguration = .defaultConfig

        guard !configs.isEmpty else {
            // 如果还没设置账号，要求进入App获取账号
            viewConfig.addMessage("请进入App设置账号信息")
            let entry = ResinEntry(
                date: currentDate,
                result: .failure(FetchError.noFetchInfo),
                viewConfig: viewConfig,
                accountUUIDString: nil
            )
            let timeline = Timeline(
                entries: [entry],
                policy: .after(refreshDate)
            )
            completion(timeline)
            print("Config is empty")
            return
        }

        guard configuration.accountIntent != nil else {
            print("no account intent got")
            if configs.count == 1 {
                viewConfig = WidgetViewConfiguration(configuration, nil)
                // 如果还未选择账号且只有一个账号，默认获取第一个
                getTimelineEntries(config: configs.first!, viewConfig: viewConfig)
            } else {
                // 如果还没设置账号，要求进入App获取账号
                viewConfig.addMessage("请长按进入settings.widget.title账号信息")
                let entry = ResinEntry(
                    date: currentDate,
                    result: .failure(FetchError.noFetchInfo),
                    viewConfig: viewConfig,
                    accountUUIDString: nil
                )
                let timeline = Timeline(
                    entries: [entry],
                    policy: .after(refreshDate)
                )
                completion(timeline)
                print("Need to choose account")
            }
            return
        }

        let selectedAccountUUID = UUID(
            uuidString: configuration.accountIntent!
                .identifier!
        )
        viewConfig = WidgetViewConfiguration(configuration, nil)
        print(configs.first!.uuid!, configuration)

        guard let config = configs
            .first(where: { $0.uuid == selectedAccountUUID }) else {
            // 有时候删除账号，Intent没更新就会出现这样的情况
            viewConfig.addMessage("请长按进入小组件重新设置账号信息")
            let entry = ResinEntry(
                date: currentDate,
                result: .failure(FetchError.noFetchInfo),
                viewConfig: viewConfig,
                accountUUIDString: nil
            )
            let timeline = Timeline(
                entries: [entry],
                policy: .after(refreshDate)
            )
            completion(timeline)
            print("Need to choose account")
            return
        }

        getTimelineEntries(config: config, viewConfig: viewConfig)

        func getTimelineEntries(config: AccountConfiguration, viewConfig: WidgetViewConfiguration) {
            Task {
                do {
                    let data = try await config.dailyNote()
                    let entries = (0 ... 40).map { index in
                        let timeInterval = TimeInterval(index * 8 * 60)
                        let entryDate =
                            Date(timeIntervalSinceNow: timeInterval)
                        return ResinEntry(
                            date: entryDate,
                            result: .success(data),
                            viewConfig: viewConfig,
                            accountName: config.safeName,
                            accountUUIDString: config.safeUuid.uuidString
                        )
                    }
                    completion(.init(entries: entries, policy: .after(refreshDate)))
                } catch {
                    let entry = ResinEntry(
                        date: Date(),
                        result: .failure(error),
                        viewConfig: viewConfig,
                        accountUUIDString: config.safeUuid.uuidString
                    )
                    completion(.init(entries: [entry], policy: .after(refreshDate)))
                }
            }
        }
    }
}
