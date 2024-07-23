//
//  AccountInfoView.swift
//  GenshinPizzaHepler
//
//  Created by Bill Haku on 2022/8/7.
//  设置页的账号信息Block

import SwiftUI

struct AccountInfoView: View {
    var account: Account

    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text(account.safeName)
                    .bold()
                    .padding(.vertical)
            }

            HStack {
                Text(verbatim: "UID: \(account.safeUid)")
                Spacer()
                Text("account.server".localized + ": " + account.server.localized)
            }
            .font(.caption)
        }
        .padding(5)
    }
}
