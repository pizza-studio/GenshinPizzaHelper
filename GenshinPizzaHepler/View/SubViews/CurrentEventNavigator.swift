//
//  CurrentEventNavigator.swift
//  GenshinPizzaHelper
//
//  Created by Bill Haku on 2022/9/18.
//

import SwiftUI

struct CurrentEventNavigator: View {
    @State var eventContents: [EventModel] = []

    var body: some View {
        VStack {
            HStack {
                Text("当前活动")
                    .font(.caption)
                    .padding(.top)
                    .padding(.leading, 25)
                Spacer()
            }
            if eventContents.isEmpty {
                ProgressView()
            } else {
                ForEach(eventContents.sorted {
                    $0.endAt < $1.endAt
                }, id: \.id) { content in
                    HStack {
                        Text(getLocalizedContent(content.name))
                        Spacer()
                        Text("剩余 \(getRemainDays(content.endAt))天")
                    }
                }
            }
        }
        .onAppear(perform: getCurrentEvent)
        .blurMaterialBackground()
        .padding(.horizontal)
    }

    func getCurrentEvent() -> Void {
        DispatchQueue.global().async {
            API.OpenAPIs.fetchCurrentEvents { result in
                switch result {
                case .success(let events):
                    self.eventContents = [EventModel](events.event.values)
                case .failure(_):
                    break
                }
            }
        }
    }

    func getLocalizedContent(_ content: EventModel.MultiLanguageContents) -> String {
        let locale = Locale.current.languageCode
        print(locale ?? "")
        switch locale {
        case "zh":
            return content.CHS
        case "en-us":
            return content.EN
        case "ja":
            return content.JP
        default:
            return content.EN
        }
    }

    func getRemainDays(_ endAt: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let endDate = dateFormatter.date(from: endAt)
        guard let endDate = endDate else {
            return endAt
        }
        let interval = endDate - Date()
        return String(describing: interval.day ?? -1)
    }
}

extension Date {
    static func -(recent: Date, previous: Date) -> (month: Int?, day: Int?, hour: Int?, minute: Int?, second: Int?) {
        let day = Calendar.current.dateComponents([.day], from: previous, to: recent).day
        let month = Calendar.current.dateComponents([.month], from: previous, to: recent).month
        let hour = Calendar.current.dateComponents([.hour], from: previous, to: recent).hour
        let minute = Calendar.current.dateComponents([.minute], from: previous, to: recent).minute
        let second = Calendar.current.dateComponents([.second], from: previous, to: recent).second

        return (month: month, day: day, hour: hour, minute: minute, second: second)
    }
}
