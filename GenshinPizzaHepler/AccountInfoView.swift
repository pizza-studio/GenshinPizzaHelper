//
//  AccountInfoView.swift
//  GenshinPizzaHepler
//
//  Created by Bill Haku on 2022/8/7.
//

import SwiftUI

struct AccountInfoView: View {
    var accountName:String
    var uid: String
    var serverName: String

    var body: some View {
        VStack(alignment: .leading) {
            Text(accountName)
                .bold()
                .padding(.vertical)
            HStack {
                Text("UID: \(uid)")
                Spacer()
                Text("服务器: \(serverName)")
            }
            .font(.caption)
        }
        .padding(5)
    }
}
