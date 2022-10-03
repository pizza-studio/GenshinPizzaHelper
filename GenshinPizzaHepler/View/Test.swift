//
//  Test.swift
//  GenshinPizzaHepler
//
//  Created by 戴藏龙 on 2022/10/3.
//

import SwiftUI

struct Test: View {
    var body: some View {
        List {
            HStack {
                Image("avatar.tao")
                    .resizable()
                    .scaledToFit()
                    .clipShape(Circle())
                VStack(alignment: .leading) {
                    Text("猫爪与小")
                        .font(.title3)
                        .bold()
                        .padding(.top, 5)
                    Text("鱼抓猫小")
                        .foregroundColor(.secondary)
                        .font(.footnote)
                }
            }
            .frame(height: 50)
        }
    }
}

struct Test_Previews: PreviewProvider {
    static var previews: some View {
        Test()
    }
}
