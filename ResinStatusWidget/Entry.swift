//
//  Entry.swift
//  GenshinPizzaHepler
//
//  Created by 戴藏龙 on 2022/9/10.
//

import WidgetKit

struct ResinEntry: TimelineEntry {
    let date: Date
    let result: FetchResult
    let viewConfig: WidgetViewConfiguration
    var accountName: String? = nil
}
