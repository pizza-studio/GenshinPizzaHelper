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
        
        let selectedAccountUUID = UUID(uuidString: configuration.accountIntent!.identifier!)
        
        // Generate a timeline consisting of five entries an hour apart, starting from the current date.
        let currentDate = Date()
        let refreshDate = Calendar.current.date(byAdding: .minute, value: 8, to: currentDate)!
        
        let configs = AccountConfigurationModel.shared.fetchAccountConfigs()
        if configs.isEmpty {
            let entry = ResinEntry(date: currentDate, result: .failure(.noFetchInfo))
            let timeline = Timeline(entries: [entry], policy: .after(refreshDate))
            completion(timeline)
            print("Config is empty")
            return
        }
        
        print(configs.first!.uuid!, configuration)
        
        let config = configs.first { $0.uuid == selectedAccountUUID }!
        

        

        config.fetchResult { result in
            let entry = ResinEntry(date: currentDate, result: result)
            let timeline = Timeline(entries: [entry], policy: .after(refreshDate))
            completion(timeline)
            print("Widget Fetch succeed")
        }
        
//        if hasFetchInfo {
//            ResinLoader.fetch(uid: uid!, server_id: server.id, cookie: cookie!, region: server.region) { result in
//                let entry = ResinEntry(date: currentDate, result: result)
//                let timeline = Timeline(entries: [entry], policy: .after(refreshDate))
//                completion(timeline)
//            }
//        } else {
//            let entry = ResinEntry(date: currentDate, result: .failure(.noFetchInfo))
//            let timeline = Timeline(entries: [entry], policy: .after(refreshDate))
//            completion(timeline)
//        }
    }
}
