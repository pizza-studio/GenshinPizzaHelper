//
//  WidgetView.swift
//  WidgetView
//
//  Created by 戴藏龙 on 2022/7/13.
//

import WidgetKit
import SwiftUI

let defaultQueryResult = (
    true,
    0,
    UserData.defaultData
)

struct WidgetViewEntryView : View {
    let entry: Provider.Entry
    var result: FetchResult { entry.result }
    var viewConfig: WidgetViewConfiguration { entry.viewConfig }
    var accountName: String? { entry.accountName }
    
    @ViewBuilder
    var body: some View {
        
        ZStack {
            
            WidgetBackgroundView(background: viewConfig.background, darkModeOn: viewConfig.isDarkModeOn)
            
            switch result {
            case .success(let userData):
                WidgetMainView(userData: userData, viewConfig: viewConfig, accountName: accountName)
            case .failure(let error):
                WidgetErrorView(error: error, message: viewConfig.noticeMessage ?? "")
            }
        }
    }
}

@main
struct WidgetView: Widget {
    let kind: String = "WidgetView"
//    let kind: String = "com.Canglong.GenshinPizzaHepler.MainWidget"
    
    var body: some WidgetConfiguration {
        IntentConfiguration(kind: kind, intent: SelectAccountIntent.self, provider: Provider()) { entry in
            WidgetViewEntryView(entry: entry)
        }
        .configurationDisplayName("原神状态")
        .description("查询树脂恢复状态")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
        
    }
}



