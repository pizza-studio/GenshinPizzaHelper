//
//  AboutView.swift
//  GenshinPizzaHepler
//
//  Created by Bill Haku on 2022/8/8.
//

import SwiftUI

struct AboutView: View {
    let appVersion = Bundle.main.infoDictionary!["CFBundleShortVersionString"] as! String
    let buildVersion = Bundle.main.infoDictionary!["CFBundleVersion"] as! String

    var body: some View {
        VStack {
            Image("AppIconHD")
                .resizable()
                .frame(width: 75, height: 75, alignment: .center)
                .cornerRadius(10)
                .padding()
                .padding(.top, 50)
            Text("原神披萨小助手")
                .font(.title3)
                .fontWeight(.regular)
                .foregroundColor(.primary)
            Text("\(appVersion) (\(buildVersion))")
                .font(.callout)
                .fontWeight(.regular)
                .foregroundColor(.secondary)
            Spacer()
            Text("开发者")
                .font(.callout)
            HStack {
                Link(destination: URL(string: "https://space.bilibili.com/13079935")!) {
                    Text("Lava丨")
                        .padding(.horizontal)
                        .font(.callout)
                }
                Link(destination: URL(string: "https://hakubill.tech")!) {
                    Text("Bill Haku")
                        .padding(.horizontal)
                        .font(.callout)
                }
            }
            Text("交流群：813912474")
                .font(.callout)
                .padding(.bottom)
        }
    }
}
