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
    @State private var isToolbarShow: Bool = false
    @State private var viewState = CGSize.zero

    fileprivate var mainContent: AccountDisplayContentView { AccountDisplayContentView(detail: detail, animation: animation)}

    var body: some View {
        VStack {
            Text("")
                .frame(height: 50)
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

            if isToolbarShow {
                HStack {
                    Image(systemName: "xmark")
                        .onTapGesture {
                            closeView()
                        }
                    Spacer()
                    // TODO: Share Button
                    Menu {
                        Button("保存到相册") {
                            let image = mainContent.asUiImage()
                            UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
                            print("save image success")
                        }
                    } label: {
                        Image(systemName: "square.and.arrow.up")
                    }
                }
                .ignoresSafeArea()
                .background(Color(UIColor.secondarySystemBackground).opacity(0.6).padding([.horizontal, .bottom], -50).padding(.top, -20))
            }
        }
        .padding(.horizontal, 25)
        .background(AppBlockBackgroundView(background: detail.widgetBackground, darkModeOn: true)
            .matchedGeometryEffect(id: "\(accountUUIDString)bg", in: animation)
            .padding(.vertical, -10)
            .ignoresSafeArea(.all)
            .blur(radius: 5)
            .onTapGesture {
                withAnimation(.interactiveSpring(response: 0.5, dampingFraction: 0.8, blendDuration: 0.8)) {
                    isToolbarShow.toggle()
                }
            }
        )
        .offset(x: viewState.width, y: viewState.height)
        .gesture (
            DragGesture()
                .onChanged { value in
                    if value.translation.height > 0 {
                        self.viewState = value.translation
                    }
                }
                .onEnded { value in
                    self.viewState = CGSize.zero
                    if value.translation.height > 75 {
                        closeView()
                    }
            }
        )
    }

    private func closeView() -> Void {
        withAnimation(.interactiveSpring(response: 0.5, dampingFraction: 0.8, blendDuration: 0.8)) {
            detail.show.toggle()
        }
    }
}

private struct AccountDisplayContentView: View {
    @ObservedObject var detail: DisplayContentModel
    var animation: Namespace.ID
    var accountName: String { detail.accountName }
    var accountUUIDString: String { detail.accountUUIDString }

    var body: some View {
        VStack {
            Text("")
                .frame(height: 50)
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
            Text("")
                .frame(height: 75)
        }
        .padding(.horizontal, 25)
        .background(AppBlockBackgroundView(background: detail.widgetBackground, darkModeOn: true)
            .matchedGeometryEffect(id: "\(accountUUIDString)bg", in: animation)
            .padding(.vertical, -10)
            .ignoresSafeArea(.all)
            .blur(radius: 5)
        )
    }
}
