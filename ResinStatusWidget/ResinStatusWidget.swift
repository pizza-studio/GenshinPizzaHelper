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
    var entry: Provider.Entry
    @Environment(\.widgetFamily) var family: WidgetFamily
    @ViewBuilder
    var body: some View {
        let queryResult = entry.queryResult
        let userData: UserData? = entry.queryResult.data
        
       
        
        ZStack {
            WidgetBackgroundView()
            
            if queryResult.isValid {
                switch family {
                case .systemSmall:
                    MainInfo(userData: userData!)
                case .systemMedium:
                    MainInfoWithDetail(userData: userData!)
                default:
                    MainInfo(userData: userData!)
                }
            } else {
                // 未获取到信息显示错误码
                Text("ERROR\n\(queryResult.retcode)")
                    .font(.title2)
                    .foregroundColor(.white)
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
            WidgetViewEntryView(entry: ResinEntry(date: Date(), queryResult: defaultQueryResult))
                .previewContext(WidgetPreviewContext(family: .systemSmall))
                .previewDevice("iPhone 12 Pro")
            WidgetViewEntryView(entry: ResinEntry(date: Date(), queryResult: defaultQueryResult))
                .previewContext(WidgetPreviewContext(family: .systemMedium))
                .previewDevice("iPhone 12 Pro")
        }
    }
}

extension Text {
    public func gradientForeground(colors: [Color]) -> some View {
        self.overlay(LinearGradient(gradient: .init(colors: colors),
                                    startPoint: .top,
                                    endPoint: .bottom))
            .mask(self)
//        self.overlay(RadialGradient(gradient: .init(colors: colors), center: .center, startRadius: 30, endRadius: 0))
//            .mask(self)
    }
}

extension Text {
    public func textWithImage(image: Image, secondImage: Image? = nil) -> some View {
        
        return HStack(alignment: .center ,spacing: 8) {
            image
                .resizable()
                .scaledToFit()
                .frame(width: 25)
                .shadow(color: .white, radius: 1)
            if let secondImage = secondImage {
                secondImage
                    .foregroundColor(Color("textColor3"))
                    .font(.system(size: 14))
            }
            self
                .foregroundColor(Color("textColor3"))
                .font(.system(.body, design: .rounded))
                .minimumScaleFactor(0.2)
            
        }
    }
}

