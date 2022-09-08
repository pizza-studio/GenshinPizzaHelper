//
//  WatchGameInfoBlock.swift
//  GenshinPizzaHelper
//
//  Created by Bill Haku on 2022/9/8.
//

import SwiftUI

struct WatchGameInfoBlock: View {
    var userData: Result<UserData, FetchError>
    let accountName: String?
    var accountUUIDString: String

//    let viewConfig = WidgetViewConfiguration.defaultConfig

    @State var bindingBool = false

    var body: some View {
        switch userData {
        case .success(let data):
            VStack(alignment: .leading) {
                HStack {
                    Text(accountName ?? "Name Nil")
                        .font(.caption)
                    Spacer()
                    Text(accountUUIDString)
                        .font(.caption)
                }
                Text("\(data.resinInfo.currentResin)")
                    .font(.title)
            }
            .padding()
            .background(AppBlockBackgroundView(background: .randomBackground, darkModeOn: false, bgFadeOutAnimation: $bindingBool))
        case .failure(_):
            Text("Error")
        }
    }
}
