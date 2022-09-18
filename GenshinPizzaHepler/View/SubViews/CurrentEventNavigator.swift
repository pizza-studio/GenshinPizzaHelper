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
        if eventContents.isEmpty {
            ProgressView()
                .onAppear(perform: getCurrentEvent)
        } else {
            ForEach(eventContents, id: \.id) { content in
                HStack {
                    Text(content.name.CHS)
                    Spacer()
                    Text(content.endAt)
                }
            }
        }
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
}
