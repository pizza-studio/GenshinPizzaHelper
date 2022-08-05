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
    UserData(
        currentResin: 90,
        currentHomeCoin: 1200,
        finishedTaskNum: 3,
        transformer: TransformerData(recoveryTime: RecoveryTime(day: 4, hour: 3, minute: 0, second: 0)),
        expeditions: [defaultExpedition],
        resinRecoveryTime: "57600"
    )
)

let defaultExpedition: Expedition = Expedition(avatarSideIcon: "https://upload-bbs.mihoyo.com/game_record/genshin/character_side_icon/UI_AvatarIcon_Side_Sara.png", remainedTimeStr: "0", statusStr: "Finished")


struct Provider: TimelineProvider {
    typealias QueryResult = (isValid: Bool, retcode: Int, data: UserData?)
    
    
    func placeholder(in context: Context) -> ResinEntry {
        ResinEntry(date: Date(), queryResult: defaultQueryResult)
    }

    func getSnapshot(in context: Context, completion: @escaping (ResinEntry) -> ()) {
        let entry = ResinEntry(date: Date(), queryResult: defaultQueryResult)
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
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
            ResinLoader.fetch(uid: uid!, server_id: server.id, cookie: cookie!) { requestResult in
                let queryResult: QueryResult
                if requestResult == nil {
                    queryResult = (false, 1, nil)
                } else {
                    queryResult = ResinLoader.get_data(from: requestResult)
                }
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

struct MainInfoWithDetail: View {
    let userData: UserData
    
    var body: some View {
        HStack {
            Spacer()
            MainInfo(userData: userData)
                .padding([.trailing])
            Spacer()
            DetailInfo(userData: userData)
                .padding([.top, .bottom])
            Spacer()
        }
    }
}

struct DetailInfo: View {
    let userData: UserData
    
    var body: some View {
        let currentHomeCoin: Int = userData.currentHomeCoin
        let currentExpeditionNum: Int = userData.currentExpeditionNum
        let finishedTaskNum: Int = userData.finishedTaskNum
        let transformerTimeSecondInt: Int = userData.transformerTimeSecondInt
        
        let isExpeditionAllComplete: Image = (currentExpeditionNum == 0) ? Image(systemName: "exclamationmark.circle") : Image(systemName: "clock.arrow.circlepath")
        let isDailyTaskAllComplete: Image = (finishedTaskNum == 4) ? Image(systemName: "checkmark.circle") : Image(systemName: "questionmark.circle")
        let isTransformerComplete: Image = (transformerTimeSecondInt == 0) ? Image(systemName: "exclamationmark.circle") : Image(systemName: "hourglass.circle")
        let isHomeCoinFull: Image = (currentHomeCoin == 2400) ? Image(systemName: "exclamationmark.circle") : Image(systemName: "leaf.arrow.triangle.circlepath")
        
        VStack(alignment: .leading, spacing: 13) {

            Group {
                
                HStack(alignment: .center ,spacing: 8) {
                    Image("洞天宝钱")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 25)
                        .shadow(color: .white, radius: 1)
                    isHomeCoinFull
                        .foregroundColor(Color("textColor3"))
                        .font(.system(size: 14))
                    HStack(alignment: .lastTextBaseline, spacing:1) {
                        Text("\(currentHomeCoin)")
                            .foregroundColor(Color("textColor3"))
                            .font(.system(.body, design: .rounded))
                            .minimumScaleFactor(0.2)
                    }
                }
                
                HStack(alignment: .center ,spacing: 8) {
                    
                    Image("派遣探索")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 25)
                        .shadow(color: .white, radius: 1)
                    isExpeditionAllComplete
                        .foregroundColor(Color("textColor3"))
                        .font(.system(size: 14))
                    HStack(alignment: .lastTextBaseline, spacing:1) {
                        Text("\(currentExpeditionNum)")
                            .foregroundColor(Color("textColor3"))
                            .font(.system(.body, design: .rounded))
                            .minimumScaleFactor(0.2)
                        Text(" / 5")
                            .foregroundColor(Color("textColor3"))
                            .font(.system(.caption, design: .rounded))
                            .minimumScaleFactor(0.2)
                    }
                    
                }
                
                HStack(alignment: .center ,spacing: 8) {
                    
                    Image("每日任务")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 25)
                        .shadow(color: .white, radius: 1)
                    isDailyTaskAllComplete
                        .foregroundColor(Color("textColor3"))
                        .font(.system(size: 14))
                    HStack(alignment: .lastTextBaseline, spacing:1) {
                        Text("\(finishedTaskNum)")
                            .foregroundColor(Color("textColor3"))
                            .font(.system(.body, design: .rounded))
                            .minimumScaleFactor(0.2)
                        Text(" / 4")
                            .foregroundColor(Color("textColor3"))
                            .font(.system(.caption, design: .rounded))
                            .minimumScaleFactor(0.2)
                    }
                    
                }
                HStack(alignment: .center ,spacing: 8) {
                    
                    Image("参量质变仪")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 25)
                        .shadow(color: .white, radius: 1)
                    isTransformerComplete
                        .foregroundColor(Color("textColor3"))
                        .font(.system(size: 14))
                    HStack(alignment: .lastTextBaseline, spacing:1) {
                        Text("\(secondsToHrOrDay(transformerTimeSecondInt))")
                            .foregroundColor(Color("textColor3"))
                            .font(.system(.body, design: .rounded))
                            .minimumScaleFactor(0.2)
                    }
                    
                }
            }
        }
        .padding(.trailing)
    }
}



struct MainInfo: View {
    let userData: UserData
    
    
    var body: some View {
        let resinFull: Bool = userData.currentResin == 160
        let homeCoinFull: Bool = userData.currentHomeCoin == 2400
        let allExpeditionComplete: Bool = userData.currentExpeditionNum == 0
        let transformerCompleted: Bool = userData.transformerTimeSecondInt == 0
        let anyToNotice: Bool = (resinFull || homeCoinFull || allExpeditionComplete || transformerCompleted)
        
        VStack(spacing: 4){
            ResinView(currentResin: userData.currentResin)

            HStack {
                if anyToNotice {
                    Image(systemName: "exclamationmark.circle")
                        .foregroundColor(Color("textColor3"))
                        .font(.title3)
                } else {
                    Image(systemName: "hourglass.circle")
                        .foregroundColor(Color("textColor3"))
                        .font(.title3)
                    
                }
                RecoveryTimeText(recoveryTimeDeltaInt: userData.resinRecoveryTimeInt)
            }
            .frame(maxWidth: 130)
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




struct RecoveryTimeText: View {
    let recoveryTimeDeltaInt: Int
    var recoveryTime: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .short
        dateFormatter.timeStyle = .short
        dateFormatter.doesRelativeDateFormatting = true
        dateFormatter.locale = Locale(identifier: "zh_CN")

        let date = Date().adding(seconds: recoveryTimeDeltaInt)

        return dateFormatter.string(from: date)
    }
    
    var body: some View {
        
        VStack(alignment: .leading, spacing: 1) {
            Group{
                Text("\(secondsToHoursMinutesSeconds(recoveryTimeDeltaInt))\n\(recoveryTime) 回满")
            }
            .font(.caption)
            .lineLimit(2)
            .minimumScaleFactor(0.2)
            .foregroundColor(Color("textColor3"))
            .lineSpacing(1)
        }

    }
}

struct ResinView: View {
    let currentResin: Int
    var condensedResin: Int { currentResin/40 }
    
    
    
    let textColors: [Color] = [
        Color("textColor1"),
        Color("textColor2"),
        Color("textColor3")
    ]
    
    var body: some View {
        
        
        VStack(spacing: 0) {
            if condensedResin > 0 {
                HStack(spacing: 0) {
                    ForEach(1...condensedResin, id: \.self) { _ in
                        Image("浓缩树脂")
                            .resizable()
                            .scaledToFit()
                    }
                }
                .frame(maxWidth: 100, maxHeight: 30)
            } else {
                Image("树脂")
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: 100, maxHeight: 30)
            }
            
            Text("\(currentResin)")
                .font(.system(size: 50 , design: .rounded))
                .fontWeight(.medium)
//                .gradientForeground(colors: textColors)
                .foregroundColor(Color("textColor3"))
                .shadow(radius: 1)


        }
        
    }
}








enum Server: String, CaseIterable, Identifiable {
    case china = "官服"
    case bilibili = "B服"
    
    var id: String {
        switch self {
        case .china:
            return "cn_gf01"
        case .bilibili:
            return "cn_qd01"
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

func secondsToHoursMinutesSeconds(_ seconds: Int) -> String {
    if seconds / 3600 > 24 {
        return "\(seconds / (3600 * 24))天"
    }
    return "\(seconds / 3600)小时\((seconds % 3600) / 60)分钟"
}

func secondsToHrOrDay(_ seconds: Int) -> String {
    if seconds / 3600 > 24 {
        return "\(seconds / (3600 * 24))天"
    } else if seconds / 3600 > 0 {
        return "\(seconds / 3600)小时"
    } else {
        return "\((seconds % 3600) / 60)分钟"
    }
}

extension Date {
    func adding(seconds: Int) -> Date {
        return Calendar.current.date(byAdding: .second, value: seconds, to: self)!
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
