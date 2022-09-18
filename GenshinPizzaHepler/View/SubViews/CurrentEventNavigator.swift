//
//  CurrentEventNavigator.swift
//  GenshinPizzaHelper
//
//  Created by Bill Haku on 2022/9/18.
//

import SwiftUI

struct CurrentEventNavigator: View {
    @State var eventContents: [EventModel] = []
    typealias IntervalDate = (month: Int?, day: Int?, hour: Int?, minute: Int?, second: Int?)

    var body: some View {
        VStack {
            if !eventContents.isEmpty {
                List {
                    Section(header: Text("当前活动").font(.caption)) {
                        ForEach(eventContents.sorted {
                            $0.endAt < $1.endAt
                        }, id: \.id) { content in
                            eventItem(event: content)
                        }
                    }
                }
                .listStyle(.plain)
                .frame(height: 160)
            }
        }
        .onAppear(perform: getCurrentEvent)
        .blurMaterialBackground()
        .padding(.horizontal)
    }

    @ViewBuilder
    func eventItem(event: EventModel) -> some View {
        NavigationLink(destination: eventDetail(event: event)) {
            HStack {
                Text(getLocalizedContent(event.name))
                Spacer()
                if getRemainDays(event.endAt) == nil {
                    Text("Error")
                }
                else if getRemainDays(event.endAt)!.day! > 0 {
                    Text("剩余 \(getRemainDays(event.endAt)!.day!)天")
                }
                else {
                    Text("剩余 \(getRemainDays(event.endAt)!.hour!)小时")
                }
            }
        }
    }

    @ViewBuilder
    func eventDetail(event: EventModel) -> some View {
        HTMLStringView(htmlContent: generateHTMLString(banner: getLocalizedContent(event.banner), nameFull: getLocalizedContent(event.nameFull), description: getLocalizedContent(event.description)))
            .navigationBarTitleDisplayMode(.inline)
            .navigationTitle(getLocalizedContent(event.name))
    }

    func generateHTMLString(banner: String, nameFull: String, description: String) -> String {
        let format = "<head><style>body{ font-size: 50px;}</style></head>"
        return format + "<body><img src=\"\(banner)\" alt=\"Event Banner\">" + "<p>\(nameFull)</p>" + description + "</body>"
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
        switch locale {
        case "zh":
            return content.CHS
        case "en":
            return content.EN
        case "ja":
            return content.JP
        default:
            return content.EN
        }
    }

    func getRemainDays(_ endAt: String) -> IntervalDate? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let endDate = dateFormatter.date(from: endAt)
        guard let endDate = endDate else {
            return nil
        }
        let interval = endDate - Date()
        return interval
    }
}
