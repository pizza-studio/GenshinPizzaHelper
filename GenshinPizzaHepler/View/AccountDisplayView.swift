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
    @State private var animationDone: Bool = false
    

    fileprivate var mainContent: AccountDisplayContentView { AccountDisplayContentView(detail: detail, animation: animation)}
    fileprivate var gameInfoBlock: some View {
        GameInfoBlockForSave(userData: detail.userData, accountName: detail.accountName, accountUUIDString: detail.accountUUIDString, animation: animation, widgetBackground: detail.widgetBackground)
            .padding()
            .animation(.linear)
    }

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            VStack(alignment: .leading) {
                Spacer()
                HStack {
                    VStack(alignment: .leading, spacing: 15) {
                        VStack(alignment: .leading, spacing: 10) {
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
                                recoveryTimeText(resinInfo: detail.userData.resinInfo)
                            }
                            .matchedGeometryEffect(id: "\(accountUUIDString)recovery", in: animation)
                        }
                        .padding(.horizontal)
                        DetailInfo(userData: detail.userData, viewConfig: detail.viewConfig)
                            .padding(.horizontal)
                            .matchedGeometryEffect(id: "\(accountUUIDString)detail", in: animation)
                    }
                    expeditionsView()
                }
                Spacer()
            }
//            Menu {
//                Button {
//                    let image = mainContent.asUiImage()
//                    UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
//                    print("save image success")
//                } label: {
//                    Label("保存本页面至相册", systemImage: "arrow.turn.up.forward.iphone.fill")
//                }
//                Button {
//                    let image = gameInfoBlock.asUiImage()
//                    UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
//                    print("save image success")
//                } label: {
//                    Label("保存卡片至相册", systemImage: "platter.2.filled.iphone")
//                }
//
//
//            } label: {
//                Image(systemName: "square.and.arrow.up.circle.fill")
//                    .font(.title)
//            }

        }
        .padding(.horizontal, 25)
        .background(
            AppBlockBackgroundView(background: detail.widgetBackground, darkModeOn: true)
                .matchedGeometryEffect(id: "\(accountUUIDString)bg", in: animation)
                .padding(-10)
                .ignoresSafeArea(.all)
                .blurMaterial(),
            alignment: .trailing
        )
        .onTapGesture {
            closeView()
        }
    }

    private func closeView() -> Void {
        withAnimation(.interactiveSpring(response: 0.25, dampingFraction: 1.0, blendDuration: 0)) {
            simpleTaptic(type: .light)
            detail.show.toggle()
        }
    }

    @ViewBuilder
    func expeditionsView() -> some View {
        VStack(alignment: .leading, spacing: 15) {
            ForEach(detail.userData.expeditionInfo.expeditions, id: \.charactersEnglishName) { expedition in
                InAppEachExpeditionView(expedition: expedition, useAsyncImage: true)
            }
        }
    }

    @ViewBuilder
    func recoveryTimeText(resinInfo: ResinInfo) -> some View {
        if resinInfo.recoveryTime.second != 0 {
            Text(LocalizedStringKey("\(resinInfo.recoveryTime.describeIntervalLong!)\n\(resinInfo.recoveryTime.completeTimePointFromNow!) 回满"))
                .font(.caption)
                .lineLimit(2)
                .minimumScaleFactor(0.2)
                .foregroundColor(Color("textColor3"))
                .lineSpacing(1)
                .fixedSize()
        } else {
            Text("0小时0分钟\n树脂已全部回满")
                .font(.caption)
                .lineLimit(2)
                .minimumScaleFactor(0.2)
                .foregroundColor(Color("textColor3"))
                .lineSpacing(1)
                .fixedSize()
        }
    }

}

struct GameInfoBlockForSave: View {
    var userData: UserData
    let accountName: String
    var accountUUIDString: String = UUID().uuidString

    let viewConfig = WidgetViewConfiguration.defaultConfig
    var animation: Namespace.ID

    var widgetBackground: WidgetBackground

    var body: some View {
        HStack {
            Spacer()
            VStack(alignment: .leading, spacing: 5) {
                if let accountName = accountName {
                    HStack(alignment: .lastTextBaseline, spacing: 2) {
                        Image(systemName: "person.fill")
                        Text(accountName)
                    }
                    .font(.footnote)
                    .foregroundColor(Color("textColor3"))
                    .matchedGeometryEffect(id: "\(accountUUIDString)name", in: animation)
                }
                HStack(alignment: .firstTextBaseline, spacing: 2) {

                    Text("\(userData.resinInfo.currentResin)")
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
                    RecoveryTimeText(resinInfo: userData.resinInfo)
                }
                .matchedGeometryEffect(id: "\(accountUUIDString)recovery", in: animation)
            }
            .padding()
            Spacer()
            DetailInfo(userData: userData, viewConfig: viewConfig)
                .padding(.vertical)
                .frame(maxWidth: UIScreen.main.bounds.width / 8 * 3)
                .matchedGeometryEffect(id: "\(accountUUIDString)detail", in: animation)
            Spacer()
        }
        .background(AppBlockBackgroundView(background: widgetBackground, darkModeOn: true)
            .matchedGeometryEffect(id: "\(accountUUIDString)bg", in: animation))
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
    }
}


private struct AccountDisplayContentView: View {
    @ObservedObject var detail: DisplayContentModel
    var animation: Namespace.ID
    var accountName: String { detail.accountName }
    var accountUUIDString: String { detail.accountUUIDString }

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
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
            Image("AppIconHD")
                .resizable()
                .scaledToFit()
                .frame(width: 25, height: 25)
                .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                .padding()

        }

        .background(
            AppBlockBackgroundView(background: detail.widgetBackground, darkModeOn: true)
                .matchedGeometryEffect(id: "\(accountUUIDString)bg", in: animation)
                .padding(-10)
                .ignoresSafeArea(.all)
                .blurMaterial(),
            alignment: .trailing
        )
    }
}


extension View {
    func blurMaterial() -> some View {
        if #available(iOS 15.0, *) {
            return AnyView(self.overlay(.ultraThinMaterial).preferredColorScheme(.dark))
        } else {
            return AnyView(self.blur(radius: 10))
        }
    }
}

private struct InAppEachExpeditionView: View {
    let expedition: Expedition
    let viewConfig: WidgetViewConfiguration = .defaultConfig
    var useAsyncImage: Bool = false
    var animationDelay: Double = 0

    @State var percentage: Double = 0.0

    var body: some View {
        HStack {
            webView(url: expedition.avatarSideIconUrl)
            VStack(alignment: .leading) {
                Text(expedition.recoveryTime.describeIntervalLong ?? "已完成".localized)
                    .lineLimit(1)
                    .font(.footnote)
                    .minimumScaleFactor(0.4)
                percentageBar(percentage)
                    .environment(\.colorScheme, .light)
            }
        }
        .foregroundColor(Color("textColor3"))
        .onAppear {
            withAnimation(.interactiveSpring(response: pow(expedition.percentage, 1/2)*0.8, dampingFraction: 1, blendDuration: 0).delay(animationDelay)) {
                percentage = expedition.percentage
            }

        }

//        webView(url: expedition.avatarSideIconUrl)
//            .border(.black, width: 3)
//        .frame(maxWidth: UIScreen.main.bounds.width / 8 * 3)
//        .background(WidgetBackgroundView(background: .randomNamecardBackground, darkModeOn: true))
    }

    @ViewBuilder
    func webView(url: URL) -> some View {
        GeometryReader { g in
            if useAsyncImage {
                WebImage(urlStr: expedition.avatarSideIcon)
                    .scaleEffect(1.5)
                    .scaledToFit()
                    .offset(x: -g.size.width * 0.06, y: -g.size.height * 0.25)
            } else {
                NetworkImage(url: expedition.avatarSideIconUrl)
                    .scaleEffect(1.5)
                    .scaledToFit()
                    .offset(x: -g.size.width * 0.06, y: -g.size.height * 0.25)
            }
        }
        .frame(maxWidth: 50, maxHeight: 50)
    }

    @ViewBuilder
    func percentageBar(_ percentage: Double) -> some View {

        let cornerRadius: CGFloat = 3
        if #available(iOS 15.0, iOSApplicationExtension 15.0, *) {
            GeometryReader { g in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                        .frame(width: g.size.width, height: g.size.height)
                        .foregroundStyle(.ultraThinMaterial)
                        .opacity(0.6)
                    RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                        .frame(width: g.size.width * percentage, height: g.size.height)
                        .foregroundStyle(.thickMaterial)
                }
                .aspectRatio(30/1, contentMode: .fit)
//                .preferredColorScheme(.light)
            }
            .frame(height: 7)
        } else {
            GeometryReader { g in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                        .opacity(0.3)
                        .frame(width: g.size.width, height: g.size.height)
                    RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                        .frame(width: g.size.width * percentage, height: g.size.height)
                }
                .aspectRatio(30/1, contentMode: .fit)
            }
            .frame(height: 7)
        }



    }
}


