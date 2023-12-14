//
//  AboutView.swift
//  GenshinPizzaHepler
//
//  Created by Bill Haku on 2022/8/8.
//  关于App View

import SwiftUI

struct AboutView: View {
    let appVersion = Bundle.main
        .infoDictionary!["CFBundleShortVersionString"] as! String
    let buildVersion = Bundle.main.infoDictionary!["CFBundleVersion"] as! String

    var body: some View {
        VStack {
            Image("AppIconHD")
                .resizable()
                .frame(width: 75, height: 75, alignment: .center)
                .cornerRadius(10)
                .padding()
                .padding(.top, 50)
            Text("app.title.full")
                .font(.title3)
                .fontWeight(.regular)
                .foregroundColor(.primary)
            Text("\(appVersion) (\(buildVersion))")
                .font(.callout)
                .fontWeight(.regular)
                .foregroundColor(.secondary)
            Spacer()

            NavigationLink(destination: ThanksView()) {
                Text("app.about.thanks.title")
                    .padding()
                    .font(.callout)
            }
            Text("contact.note.1")
                .font(.caption2)
            Text("contact.note.2")
                .font(.caption2)
            Text("桂ICP备2023009538号-2A")
                .font(.caption2)
        }
    }
}
