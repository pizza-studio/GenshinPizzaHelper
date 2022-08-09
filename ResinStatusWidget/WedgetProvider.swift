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
//        let userDefaults = UserDefaults(suiteName: "group.GenshinPizzaHelper")!
//        let uid = userDefaults.string(forKey: "uid")
//        let cookie = userDefaults.string(forKey: "cookie")
//        var server_name = userDefaults.string(forKey: "server") ?? "天空岛"
        func noFetchInfoResult () {
            let entry = ResinEntry(date: currentDate, result: .failure(.noFetchInfo))
            let timeline = Timeline(entries: [entry], policy: .after(refreshDate))
            completion(timeline)
            print("Config is empty")
            return
        }
        
        
        // Generate a timeline consisting of five entries an hour apart, starting from the current date.
        let currentDate = Date()
        let refreshDate = Calendar.current.date(byAdding: .minute, value: 8, to: currentDate)!
        
        let configs = AccountConfigurationModel.shared.fetchAccountConfigs()
        if configs.isEmpty || (configuration.accountIntent == nil) {
            noFetchInfoResult()
        }
        
        if configuration.accountIntent == nil {
            noFetchInfoResult()
        }
        
        let selectedAccountUUID = UUID(uuidString: configuration.accountIntent!.identifier!)
        
        print(configs.first!.uuid!, configuration)
        
        if let config = configs.first(where: { $0.uuid == selectedAccountUUID }) {
            config.fetchResult { result in
                let entry = ResinEntry(date: currentDate, result: result)
                let timeline = Timeline(entries: [entry], policy: .after(refreshDate))
                completion(timeline)
                print("Widget Fetch succeed")
            }
        } else {
            noFetchInfoResult()
        }
    }
}
