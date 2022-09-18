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
                        Text(content.endAt)
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
}
