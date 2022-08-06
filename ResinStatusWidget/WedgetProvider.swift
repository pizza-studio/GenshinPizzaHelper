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
    var queryResult: (isValid: Bool, retcode: Int, data: UserData?)
    var userData: UserData? {
        queryResult.data
    }
}

struct ResinLoader {
    typealias QueryResult = (isValid: Bool, retcode: Int, data: UserData?)
    
    static func fetch(uid: String, server_id: String, cookie: String, region: Region, completion: @escaping ((QueryResult) -> Void)) {
        var result: QueryResult = (false, 1, nil)

        API.Features.fetchInfos(region: region,
                                serverID: server_id,
                                uid: uid,
                                cookie: cookie) { retCode, userLoginData, errorInfo in
            if retCode != 0 {
                result = (false, retCode, nil)
            } else {
                result = (true, retCode, userLoginData!.data!)
            }
            completion(result)
        }
    }
}

struct Provider: TimelineProvider {
    typealias QueryResult = (isValid: Bool, retcode: Int, data: UserData?)

    func placeholder(in context: Context) -> ResinEntry {
        ResinEntry(date: Date(), queryResult: defaultQueryResult)
    }

    func getSnapshot(in context: Context, completion: @escaping (ResinEntry) -> ()) {
        let entry = ResinEntry(date: Date(), queryResult: defaultQueryResult)
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<ResinEntry>) -> ()) {
        let userDefaults = UserDefaults(suiteName: "group.GenshinPizzaHelper")!
        let uid = userDefaults.string(forKey: "uid")
        let cookie = userDefaults.string(forKey: "cookie")
        let server_name = userDefaults.string(forKey: "server") ?? "官服"
        let server = Server(rawValue: server_name)!

        // Generate a timeline consisting of five entries an hour apart, starting from the current date.
        let currentDate = Date()
        let refreshDate = Calendar.current.date(byAdding: .minute, value: 8, to: currentDate)!
        var hasFetchInfo: Bool {
            (uid != nil) && (cookie != nil)
        }

        if hasFetchInfo {
            ResinLoader.fetch(uid: uid!, server_id: server.id, cookie: cookie!, region: server.region) { queryResult in
                let entry = ResinEntry(date: currentDate, queryResult: queryResult)
                let timeline = Timeline(entries: [entry], policy: .after(refreshDate))
                completion(timeline)
            }
        } else {
            let entry = ResinEntry(date: currentDate, queryResult: (false, 1, nil))
            let timeline = Timeline(entries: [entry], policy: .after(refreshDate))
            completion(timeline)}
    }
}
