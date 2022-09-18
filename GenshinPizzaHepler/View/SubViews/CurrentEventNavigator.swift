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
            if eventContents.isEmpty {
                HStack {
                    Text("当前活动")
                        .font(.caption)
                        .padding(.top)
                        .padding(.leading, 25)
                    Spacer()
                }
                ProgressView()
            } else {
                NavigationView {
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
                }
                .frame(height: 250)
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
                Text("剩余 \(getRemainDays(event.endAt))天")
            }
        }
    }

    @ViewBuilder
    func eventDetail(event: EventModel) -> some View {
        Text(event.endAt)
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
