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
    
    @ViewBuilder
    var body: some View {
        
        ZStack {
            WidgetBackgroundView()
            
            switch result {
            case .success(let userData):
                WidgetMainView(userData: userData)
            case .failure(let error):
                WidgetErrorView(error: error)
            }
        }
    }
}

@main
struct WidgetView: Widget {
    let kind: String = "WidgetView"
    
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            WidgetViewEntryView(entry: entry)
        }
        .configurationDisplayName("原神状态")
        .description("查询树脂恢复状态")
        .supportedFamilies([.systemSmall, .systemMedium])
        
    }
}

struct WidgetView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            WidgetViewEntryView(entry: ResinEntry(date: Date(), result: FetchResult.defaultFetchResult))
                .previewContext(WidgetPreviewContext(family: .systemSmall))
                .previewDevice("iPhone 12 Pro")
            WidgetViewEntryView(entry: ResinEntry(date: Date(), result: FetchResult.defaultFetchResult))
                .previewContext(WidgetPreviewContext(family: .systemMedium))
                .previewDevice("iPhone 12 Pro")
        }
    }
}

