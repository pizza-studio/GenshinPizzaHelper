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
    var uid: String

    @State var bindingBool = false

    var body: some View {
        switch userData {
        case .success(let data):
            VStack(alignment: .leading) {
                HStack {
                    Text(accountName ?? "Name Nil")
                        .font(.caption)
                    Spacer()
                    Text(uid)
                        .font(.caption2)
                }
                Text("\(data.resinInfo.currentResin)")
                    .font(.system(size: 50 , design: .rounded))
                    .fontWeight(.medium)
                    .foregroundColor(Color("textColor3"))
                    .shadow(radius: 1)
            }
            .padding()
            .background(AppBlockBackgroundView(background: .randomBackground, darkModeOn: false, bgFadeOutAnimation: $bindingBool))
        case .failure(_):
            Text("Error")
        }
    }
}
