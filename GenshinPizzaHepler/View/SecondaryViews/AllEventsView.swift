//
//  AllEventsView.swift
//  GenshinPizzaHepler
//
//  Created by Bill Haku on 2022/9/19.
//

import SwiftUI

//@available (iOS 15, *)
struct AllEventsView: View {
    @Binding var eventContents: [EventModel]
    typealias IntervalDate = (month: Int?, day: Int?, hour: Int?, minute: Int?, second: Int?)
    // MARK: - CARD ANIAMTION PROPERTIES
    @State var expandCards: Bool = false

    // MARK: TRANSACTION LIST PROPERTIES
    @State var currentCard: EventModel?
    @State var showDetailTransaction: Bool = false
    @Namespace var animation

    var body: some View {
        ScrollView {
            VStack {
                ForEach(eventContents, id:\.id) { content in
                    NavigationLink(destination: eventDetail(event: content)) {
                        CardView(content: content)
                    }
                }
            }
        }
        .navigationTitle("当前活动")
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: CARD VIEW
    @ViewBuilder
    func CardView(content: EventModel)->some View {
        VStack {
            ZStack {
                WebImage(urlStr: getLocalizedContent(content.banner))
                    .scaledToFill()
                    .cornerRadius(20)
                    .padding(.horizontal)
                VStack {
                    Spacer()
                    HStack {
                        HStack(spacing: 2) {
                            Image(systemName: "hourglass.circle")
                            if getRemainDays(content.endAt) == nil {
                                Text("Error")
                                    .font(.caption)
                                    .padding(.trailing, 2)
                            }
                            else if getRemainDays(content.endAt)!.day! > 0 {
                                Text("剩余 \(getRemainDays(content.endAt)!.day!)天")
                                    .font(.caption)
                                    .padding(.trailing, 2)
                            }
                            else {
                                Text("剩余 \(getRemainDays(content.endAt)!.hour!)小时")
                                    .font(.caption)
                                    .padding(.trailing, 2)
                            }
                        }
                        .padding(2)
                        .background(Color(UIColor.systemBackground).opacity(0.8).clipShape(Capsule()))
                        Spacer()
                    }
                    .foregroundColor(.primary)
                    .padding(.horizontal)
                }
                .padding()
            }
        }
    }

    @ViewBuilder
    func eventDetail(event: EventModel) -> some View {
        HTMLStringView(htmlContent: generateHTMLString(banner: getLocalizedContent(event.banner), nameFull: getLocalizedContent(event.nameFull), description: getLocalizedContent(event.description)))
            .navigationBarTitleDisplayMode(.inline)
            .navigationTitle(getLocalizedContent(event.name))
    }

    func getIndex(Card: EventModel)-> Int {
        return eventContents.firstIndex { currentCard in
            return currentCard.id == Card.id
        } ?? 0
    }

    func generateHTMLString(banner: String, nameFull: String, description: String) -> String {
        let format = "<head><style>body{ font-size: 50px;}</style></head>"
        return format + "<body><img src=\"\(banner)\" alt=\"Event Banner\">" + "<p>\(nameFull)</p>" + description + "</body>"
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
