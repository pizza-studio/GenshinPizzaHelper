//
//  Model.swift
//  Genshin Resin Checker
//
//  Created by 戴藏龙 on 2022/7/12.
//

import Foundation
import SwiftUI
import WidgetKit

struct ResinEntry: TimelineEntry {
    let date: Date
    let result: FetchResult
}

struct ResinLoader {
    
    static func fetch(uid: String, server_id: String, cookie: String, region: Region, completion: @escaping ( (Result<UserData, FetchError>) -> Void)) {
        API.Features.fetchInfos(region: region,
                                serverID: server_id,
                                uid: uid,
                                cookie: cookie) { result in
            completion(result)
        }
    }
}

struct Provider: IntentTimelineProvider {

    func placeholder(in context: Context) -> ResinEntry {
        ResinEntry(date: Date(), result: FetchResult.defaultFetchResult)
    }

    func getSnapshot(for configuration: SelectAccountIntent, in context: Context, completion: @escaping (ResinEntry) -> ()) {
        let entry = ResinEntry(date: Date(), result: FetchResult.defaultFetchResult)
        completion(entry)
    }

    func getTimeline(for configuration: SelectAccountIntent, in context: Context, completion: @escaping (Timeline<ResinEntry>) -> ()) {
        
        // Generate a timeline consisting of five entries an hour apart, starting from the current date.
        let currentDate = Date()
        let refreshDate = Calendar.current.date(byAdding: .minute, value: 7, to: currentDate)!
        
        let accountConfigurationModel = AccountConfigurationModel.shared
        let configs = accountConfigurationModel.fetchAccountConfigs()
        
        // 如果还没设置账号或者获取不到账号信息，报错并要求选择账号
        if configs.isEmpty {
            let entry = ResinEntry(date: currentDate, result: .failure(.noFetchInfo))
            let timeline = Timeline(entries: [entry], policy: .after(refreshDate))
            completion(timeline)
            print("Config is empty")
        } else if configuration.accountIntent == nil {
            if configs.count == 1 {
                configs.first!.fetchResult { result in
                    let entry = ResinEntry(date: currentDate, result: result)
                    let timeline = Timeline(entries: [entry], policy: .after(refreshDate))
                    completion(timeline)
                    print("Widget Fetch succeed")
                }
            } else {
                let entry = ResinEntry(date: currentDate, result: .failure(.noFetchInfo))
                let timeline = Timeline(entries: [entry], policy: .after(refreshDate))
                completion(timeline)
                print("Config is empty")
            }
        } else {
            let selectedAccountUUID = UUID(uuidString: configuration.accountIntent!.identifier!)
            
            print(configs.first!.uuid!, configuration)
            
            // 正常情况
            if let config = configs.first(where: { $0.uuid == selectedAccountUUID }) {
                config.fetchResult { result in
                    let entry = ResinEntry(date: currentDate, result: result)
                    let timeline = Timeline(entries: [entry], policy: .after(refreshDate))
                    completion(timeline)
                    print("Widget Fetch succeed")
                }
            } else {
                // 有时候删除账号，Intent没更新就会出现这样的情况
                let entry = ResinEntry(date: currentDate, result: .failure(.noFetchInfo))
                let timeline = Timeline(entries: [entry], policy: .after(refreshDate))
                completion(timeline)
                print("Config is empty")
                return
            }
        }
    }
}

