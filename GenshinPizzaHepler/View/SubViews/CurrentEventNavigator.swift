//
//  CurrentEventNavigator.swift
//  GenshinPizzaHelper
//
//  Created by Bill Haku on 2022/9/18.
//

import Defaults
import HBMihoyoAPI
import HoYoKit
import SFSafeSymbols
import SwiftUI

struct CurrentEventNavigator: View {
    typealias IntervalDate = (
        month: Int?,
        day: Int?,
        hour: Int?,
        minute: Int?,
        second: Int?
    )

    @Environment(\.colorScheme)
    var colorScheme

    @Binding
    var eventContents: [EventModel]

    var viewBackgroundColor: UIColor {
        colorScheme == .light ? UIColor.secondarySystemBackground : UIColor.systemBackground
    }

    var sectionBackgroundColor: UIColor {
        colorScheme == .dark ? UIColor.secondarySystemBackground : UIColor.systemBackground
    }

    var validEventContents: [EventModel] {
        eventContents.filter {
            (getRemainDays($0.endAt)?.day ?? 0) >= 0
                && (getRemainDays($0.endAt)?.hour ?? 0) >= 0
                && (getRemainDays($0.endAt)?.minute ?? 0) >= 0
        }
    }

    var body: some View {
        if !eventContents.isEmpty {
            Section {
                HStack(spacing: 3) {
                    Rectangle()
                        .foregroundColor(.secondary)
                        .frame(width: 4, height: 60)
                    VStack(spacing: 7) {
                        let eventContentsValid = validEventContents.prefix(3)
                        if eventContentsValid.isEmpty {
                            HStack {
                                Spacer()
                                Text("gameEvents.noCurrentEventInfo")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                Spacer()
                            }
                        } else {
                            ForEach(eventContentsValid, id: \.id) { content in
                                eventItem(event: content)
                            }
                        }
                    }
                }
                .contentShape(Rectangle())
            } header: {
                NavigationLinkSheetable {
                    AllEventsView(eventContents: $eventContents)
                } label: {
                    HStack(spacing: 2) {
                        Text("currentEventNavigator.pendingEvents.title")
                            .foregroundColor(.primary)
                            .font(.headline)
                        Spacer()
                        if OS.type != .macOS {
                            Text("currentEventNavigator.viewAll.title")
                                .foregroundColor(.secondary)
                            Image(systemSymbol: .chevronForward)
                                .padding(.leading, 5)
                                .foregroundColor(.secondary)
                        } else {
                            Text("currentEventNavigator.tapToViewAll.title")
                                .foregroundColor(.secondary)
                        }
                    }
                    .font(.caption)
                }
            }
            .background {
                NavigationLinkSheetable {
                    AllEventsView(eventContents: $eventContents)
                } label: {
                    Rectangle()
                }.opacity(0)
            }
        }
    }

    @ViewBuilder
    func eventItem(event: EventModel) -> some View {
        HStack {
            Text(" \(getLocalizedContent(event.name))")
                .lineLimit(1)
            Spacer()
            if getRemainDays(event.endAt) == nil {
                Text(event.endAt)
            } else if getRemainDays(event.endAt)!.day! > 0 {
                HStack(spacing: 0) {
                    Text("剩余 \(getRemainDays(event.endAt)!.day!)天")
                }
            } else {
                HStack(spacing: 0) {
                    Text("剩余 \(getRemainDays(event.endAt)!.hour!)小时")
                }
            }
        }
        .font(.caption)
        .foregroundColor(.primary)
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

    func getCurrentEvent() {
        DispatchQueue.global().async {
            API.OpenAPIs.fetchCurrentEvents { result in
                switch result {
                case let .success(events):
                    withAnimation {
                        eventContents = [EventModel](events.event.values)
                        eventContents = eventContents.sorted {
                            $0.endAt < $1.endAt
                        }
                    }
                case .failure:
                    break
                }
            }
        }
    }
}
