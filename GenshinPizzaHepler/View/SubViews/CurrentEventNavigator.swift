//
//  CurrentEventNavigator.swift
//  GenshinPizzaHelper
//
//  Created by Bill Haku on 2022/9/18.
//

import SwiftUI

struct CurrentEventNavigator: View {
    @Binding var eventContents: [EventModel]
    typealias IntervalDate = (month: Int?, day: Int?, hour: Int?, minute: Int?, second: Int?)

    var body: some View {
        if !eventContents.isEmpty {
            NavigationLink {
                AllEventsView(eventContents: $eventContents)
            } label: {
                VStack(spacing: 0) {
                    HStack {
                        Text("即将结束的活动")
                            .foregroundColor(.primary)
                        Spacer()
                        Text("查看全部活动")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .font(.caption)
                    .padding(.top)
                    .padding(.horizontal, 25)
                    .padding(.bottom, 13)
                    HStack(spacing: 0) {
                        Rectangle()
                            .foregroundColor(.secondary)
                            .frame(width: 4)
                        VStack(spacing: 7) {
                            ForEach(eventContents.prefix(3), id: \.id) { content in
                                eventItem(event: content)
                            }
                        }
                    }
                    .padding(.bottom)
                    // padding horizontal = 25 + (rectangle width/2)
                    .padding(.horizontal, 27)
                }
                .blurMaterialBackground()
                .padding(.horizontal)
            }
        }
    }

    @ViewBuilder
    func eventItem(event: EventModel) -> some View {
        HStack {
            Text(" \(getLocalizedContent(event.name))")
            Spacer()
            if getRemainDays(event.endAt) == nil {
                Text("Error")
            }
            else if getRemainDays(event.endAt)!.day! > 0 {
                HStack(spacing: 0) {
                    Text("剩余 \(getRemainDays(event.endAt)!.day!)天")
                }
            }
            else {
                HStack(spacing: 0) {
                    Text("剩余 \(getRemainDays(event.endAt)!.hour!)小时")
                }
            }
        }
        .font(.caption)
        .foregroundColor(.primary)
    }

    @ViewBuilder
    func eventDetail(event: EventModel) -> some View {
        HTMLStringView(htmlContent: generateHTMLString(banner: getLocalizedContent(event.banner), nameFull: getLocalizedContent(event.nameFull), description: getLocalizedContent(event.description)))
            .navigationBarTitleDisplayMode(.inline)
            .navigationTitle(getLocalizedContent(event.name))
    }

    func generateHTMLString(banner: String, nameFull: String, description: String) -> String {
        let format = "<head><style>body{ font-size: 40px; } img{ max-width: 100%; }</style></head>"
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
