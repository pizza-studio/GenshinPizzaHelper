//
//  AccountInfoView.swift
//  GenshinPizzaHepler
//
//  Created by Bill Haku on 2022/8/7.
//

import SwiftUI

struct AccountInfoView: View {
    @Binding var accountConfig: AccountConfiguration

    var body: some View {
        VStack(alignment: .leading) {
            Text(accountConfig.name!)
                .bold()
                .padding(.vertical)
            HStack {
                Text("UID: \(accountConfig.uid!)")
//                Spacer()
//                Text("地区: \(accountConfig.server.region.value)")
                Spacer()
                Text("服务器: \(accountConfig.server.rawValue)")
            }
            .font(.caption)
        }
        .padding(5)
    }
}
