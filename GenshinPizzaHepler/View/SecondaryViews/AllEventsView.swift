//
//  AllEventsView.swift
//  GenshinPizzaHepler
//
//  Created by Bill Haku on 2022/9/19.
//

import Defaults
import GIPizzaKit
import HBMihoyoAPI
import HoYoKit
import SFSafeSymbols
import SwiftUI

// MARK: - AllEventsView

// @available (iOS 15, *)
struct AllEventsView: View {
    typealias IntervalDate = (
        month: Int?,
        day: Int?,
        hour: Int?,
        minute: Int?,
        second: Int?
    )

    @Environment(\.colorScheme)
    var colorScheme

    var eventContents: [EventModel]
    @State
    var expandCards: Bool = false
    @State
    var currentCard: EventModel?
    @State
    var showDetailTransaction: Bool = false
    @Namespace
    var animation

    var viewBackgroundColor: UIColor {
        colorScheme == .light ? UIColor.secondarySystemBackground : UIColor.systemBackground
    }

    var sectionBackgroundColor: UIColor {
        colorScheme == .dark ? UIColor.secondarySystemBackground : UIColor.systemBackground
    }

    var body: some View {
        ScrollView {
            VStack {
                if eventContents.filter({
                    getRemainDays($0.endAt)?.second! ?? 0 >= 0
                }).count <= 0 {
                    Spacer(minLength: 50)
                    Text("gameEvents.noCurrentEventInfo")
                        .padding()
                    Text("gameEvents.intelligenceProvider")
                        .font(.caption)
                }
                ForEach(eventContents, id: \.id) { content in
                    if getRemainDays(content.endAt)?.second! ?? 0 >= 0 {
                        NavigationLink(
                            destination: eventDetail(event: content)
                        ) {
                            CardView(content: content)
                        }
                    }
                }
            }
        }
        .scrollContentBackground(.hidden)
        .listContainerBackground()
        .navigationTitle("app.home.ongoingEvents")
        .navigationBarTitleDisplayMode(.inline)
        .background(Color(uiColor: viewBackgroundColor))
    }

    // MARK: CARD VIEW

    @ViewBuilder
    func CardView(content: EventModel) -> some View {
        VStack {
            ZStack {
                HStack {
                    Spacer()
                    Text("\(getLocalizedContent(content.name))")
                        .foregroundColor(.gray)
                        .padding(.horizontal)
                        .font(.caption)
                }
                WebImage(urlStr: getLocalizedContent(content.banner))
                    .scaledToFill()
                    .cornerRadius(20)
                    .padding(.horizontal)
                VStack {
                    Spacer()
                    HStack {
                        HStack(spacing: 2) {
                            Image(systemSymbol: .hourglassCircle)
                                .font(.caption)
                            Group {
                                if getRemainDays(content.endAt) == nil {
                                    Text(content.endAt)
                                } else if getRemainDays(content.endAt)!
                                    .day! > 0 {
                                    Text(
                                        "app.event.daysLeft:\(getRemainDays(content.endAt)!.day!)"
                                    )
                                } else {
                                    Text(
                                        "app.event.hoursLeft:\(getRemainDays(content.endAt)!.hour!)"
                                    )
                                }
                            }
                            .padding(.trailing, 2)
                            .font(.caption)
                        }
                        .padding(2)
                        .opacityMaterial()
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
        let webview = EventDetailWebView(
            banner: getLocalizedContent(event.banner),
            nameFull: getLocalizedContent(event.nameFull),
            content: getLocalizedContent(event.description)
        )
        webview
            .navigationBarTitleDisplayMode(.inline)
            .navigationTitle(getLocalizedContent(event.name))
    }

    func getIndex(Card: EventModel) -> Int {
        eventContents.firstIndex { currentCard in
            currentCard.id == Card.id
        } ?? 0
    }

    func getLocalizedContent(
        _ content: EventModel
            .MultiLanguageContents
    )
        -> String {
        let locale = Bundle.main.preferredLocalizations.first
        switch locale {
        case "zh-Hans":
            return content.CHS
        case "zh-Hant", "zh-HK":
            return content.CHT
        case "en":
            return content.EN
        case "ja":
            return content.JP
        case "ru":
            return content.RU
        default:
            return content.EN
        }
    }

    func getRemainDays(_ endAt: String) -> IntervalDate? {
        let dateFormatter = DateFormatter.Gregorian()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.timeZone = (Server(rawValue: Defaults[.defaultServer]) ?? Server.asia).timeZone()
        let endDate = dateFormatter.date(from: endAt)
        guard let endDate = endDate else {
            return nil
        }
        let interval = endDate - Date()
        return interval
    }
}

extension View {
    fileprivate func opacityMaterial() -> some View {
        background(.thinMaterial, in: Capsule())
    }
}
