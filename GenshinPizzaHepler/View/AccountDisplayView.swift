//
//  AccountDisplayView.swift
//  GenshinPizzaHepler
//
//  Created by Bill Haku on 2022/8/22.
//

import SwiftUI

struct AccountDisplayView: View {
    @ObservedObject var detail: DisplayContentModel
    var animation: Namespace.ID
    var accountName: String { detail.accountName }
    var accountUUIDString: String { detail.accountUUIDString }

    var body: some View {
        VStack {
            HStack {
                Image(systemName: "xmark")
                    .resizable()
                    .frame(width: 15, height: 15, alignment: .center)
                    .onTapGesture {
                        withAnimation(.interactiveSpring(response: 0.5, dampingFraction: 0.8, blendDuration: 0.8)) {
                            detail.show.toggle()
                        }
                    }
                Spacer()
            }
            Text("")
                .frame(height: 25)
            HStack {
                VStack(alignment: .leading, spacing: 5) {
                    if let accountName = detail.accountName {
                        HStack(alignment: .lastTextBaseline, spacing: 2) {
                            Image(systemName: "person.fill")
                            Text(accountName)
                        }
                        .font(.footnote)
                        .foregroundColor(Color("textColor3"))
                        .matchedGeometryEffect(id: "\(accountUUIDString)name", in: animation)
                    }
                    HStack(alignment: .firstTextBaseline, spacing: 2) {

                        Text("\(detail.userData.resinInfo.currentResin)")
                            .font(.system(size: 50 , design: .rounded))
                            .fontWeight(.medium)
                            .foregroundColor(Color("textColor3"))
                            .shadow(radius: 1)
                            .matchedGeometryEffect(id: "\(accountUUIDString)curResin", in: animation)
                        Image("树脂")
                            .resizable()
                            .scaledToFit()
                            .frame(maxHeight: 30)
                            .alignmentGuide(.firstTextBaseline) { context in
                                context[.bottom] - 0.17 * context.height
                            }
                            .matchedGeometryEffect(id: "\(accountUUIDString)Resinlogo", in: animation)
                    }
                    HStack {
                        Image(systemName: "hourglass.circle")
                            .foregroundColor(Color("textColor3"))
                            .font(.title3)
                        RecoveryTimeText(resinInfo: detail.userData.resinInfo)
                    }
                    .matchedGeometryEffect(id: "\(accountUUIDString)recovery", in: animation)
                }
                Spacer()
            }
            HStack {
                DetailInfo(userData: detail.userData, viewConfig: detail.viewConfig)
                    .padding(.vertical)
                    .matchedGeometryEffect(id: "\(accountUUIDString)detail", in: animation)
                Spacer()
            }
            Spacer()
        }
        .padding(.horizontal, 25)
//        .background(Color(UIColor.secondarySystemBackground))
        .background(AppBlockBackgroundView(background: detail.widgetBackground, darkModeOn: true)
            .matchedGeometryEffect(id: "\(accountUUIDString)bg", in: animation)
            .padding(.vertical, -10)
            .ignoresSafeArea(.all)
            .blur(radius: 5)
        )
    }
}


