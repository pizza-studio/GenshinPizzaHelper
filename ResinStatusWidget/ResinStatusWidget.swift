//
//  WidgetView.swift
//  WidgetView
//
//  Created by 戴藏龙 on 2022/7/13.
//

import WidgetKit
import SwiftUI

let defaultExpedition: Expedition = Expedition(avatarSideIcon: "https://upload-bbs.mihoyo.com/game_record/genshin/character_side_icon/UI_AvatarIcon_Side_Sara.png", remainedTimeStr: "0", statusStr: "Finished")

let defaultQueryResult = (
    true,
    0,
    UserData(
        currentResin: 90,
        maxResin: 160,
        resinRecoveryTime: "123",

        finishedTaskNum: 3,
        totalTaskNum: 4,
        isExtraTaskRewardReceived: false,

        remainResinDiscountNum: 2,
        resinDiscountNumLimit: 3,

        currentExpeditionNum: 2,
        maxExpeditionNum: 5,
        expeditions: [defaultExpedition],

        currentHomeCoin: 1200,
        maxHomeCoin: 2400,
        homeCoinRecoveryTime: "123",
        
        transformerData: TransformerData(recoveryTime: TransformerData.TransRecoveryTime(day: 4, hour: 3, minute: 0, second: 0), obtained: true)
    )
)


struct WidgetViewEntryView : View {
    var entry: Provider.Entry
    @Environment(\.widgetFamily) var family: WidgetFamily
    @ViewBuilder
    var body: some View {
        let queryResult = entry.queryResult
        let userData: UserData? = entry.queryResult.data
        
        let backgroundColors: [Color] = [
            Color("backgroundColor1"),
            Color("backgroundColor2"),
            Color("backgroundColor3")
        ]
        
        ZStack {
            LinearGradient(colors: backgroundColors, startPoint: .topLeading, endPoint: .bottomTrailing)
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

