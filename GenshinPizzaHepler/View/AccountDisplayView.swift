//
//  AccountDisplayView.swift
//  GenshinPizzaHepler
//
//  Created by Bill Haku on 2022/8/22.
//  弹出的展示账号详细信息的View

import HBMihoyoAPI
import SFSafeSymbols
import SwiftUI

// MARK: - AccountDisplayView

struct AccountDisplayView: View {
    @EnvironmentObject
    var viewModel: ViewModel
    var account: Account
    var animation: Namespace.ID
    var accountName: String { account.config.name! }
    var accountUUIDString: String { account.config.uuid!.uuidString }
    var userData: UserData { switch account.result {
    case let .success(userData):
        return userData
    default:
        return .defaultData
    }}
    var basicAccountInfo: BasicInfos? { account.basicInfo }

    @State
    private var animationDone: Bool = false
    @State
    var scrollOffset: CGPoint = .zero
    @State
    var isAccountInfoShown: Bool = false

    @State
    var isStatusBarHide: Bool = false
    @State
    var fadeOutAnimation: Bool = true
    @State
    var isExpeditionsAppeared: Bool = false
    @State
    var isAnimationLocked: Bool = false

    var body: some View {
        GeometryReader { geo in
            ScrollView(showsIndicators: false) {
                VStack(alignment: .center) {
                    if OS.type != .macOS { Spacer(minLength: 80) }
                    HStack {
                        VStack(alignment: .leading, spacing: 15) {
                            VStack(alignment: .leading, spacing: 10) {
                                HStack(
                                    alignment: .lastTextBaseline,
                                    spacing: 2
                                ) {
                                    Image(systemSymbol: .personFill)
                                    Text(accountName)
                                }
                                .font(.footnote)
                                .foregroundColor(Color("textColor3"))
                                .matchedGeometryEffect(
                                    id: "\(accountUUIDString)name",
                                    in: animation
                                )
                                HStack(
                                    alignment: .firstTextBaseline,
                                    spacing: 2
                                ) {
                                    Text("\(userData.resinInfo.currentResin)")
                                        .font(.system(
                                            size: 50,
                                            design: .rounded
                                        ))
                                        .fontWeight(.medium)
                                        .foregroundColor(Color("textColor3"))
                                        .shadow(radius: 1)
                                        .matchedGeometryEffect(
                                            id: "\(accountUUIDString)curResin",
                                            in: animation
                                        )
                                    Image("树脂")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(maxHeight: 30)
                                        .alignmentGuide(.firstTextBaseline) { context in
                                            context[.bottom] - 0.17 * context
                                                .height
                                        }
                                        .matchedGeometryEffect(
                                            id: "\(accountUUIDString)Resinlogo",
                                            in: animation
                                        )
                                }
                                HStack {
                                    Image(systemSymbol: .hourglassCircle)
                                        .foregroundColor(Color("textColor3"))
                                        .font(.title3)
                                    recoveryTimeText(
                                        resinInfo: userData
                                            .resinInfo
                                    )
                                }
                                .matchedGeometryEffect(
                                    id: "\(accountUUIDString)recovery",
                                    in: animation
                                )
                            }
                            DetailInfo(
                                userData: userData,
                                viewConfig: .defaultConfig
                            )
                            .matchedGeometryEffect(
                                id: "\(accountUUIDString)detail",
                                in: animation
                            )
                        }
                        .frame(maxWidth: 152)
                        Spacer()
                        expeditionsView()
                            .frame(maxWidth: 152)
                            .onAppear {
                                DispatchQueue.main
                                    .asyncAfter(deadline: .now()) {
                                        isExpeditionsAppeared = true
                                    }
                            }
                    }
                    .frame(maxWidth: 310)

                    HelpTextForScrollingOnDesktopComputer(.vertical).padding()
                    if OS.type != .macOS { Spacer() }
                    if !isAccountInfoShown {
                        HStack {
                            Spacer()
                            Text("上滑查看更多基本信息")
                                .font(.footnote)
                                .opacity(fadeOutAnimation ? 0 : 1)
                                .offset(y: fadeOutAnimation ? 15 : 0)
                                .onAppear {
                                    DispatchQueue.main
                                        .asyncAfter(deadline: .now() + 1) {
                                            withAnimation {
                                                fadeOutAnimation.toggle()
                                            }
                                        }
                                }
                                .onChange(of: fadeOutAnimation) { _ in
                                    DispatchQueue.main
                                        .asyncAfter(deadline: .now() + 2.5) {
                                            withAnimation {
                                                fadeOutAnimation.toggle()
                                            }
                                        }
                                }
                            if OS.type != .macOS { Spacer() }
                        }
                    }
                }
                .shouldTakeAllVerticalSpace(
                    !(isAccountInfoShown && OS.type != .macOS),
                    height: geo.size.height,
                    animation: animation
                )
                .readingScrollView(from: "scroll", into: $scrollOffset)
                if isAccountInfoShown || OS.type == .macOS {
                    if OS.type != .macOS {
                        Spacer(minLength: 40)
                    }
                    VStack(alignment: .leading) {
                        HStack(alignment: .lastTextBaseline, spacing: 5) {
                            Image(systemSymbol: .personFill)
                            Text("\(accountName) (\(account.config.uid ?? ""))")
                        }
                        .font(.headline)
                        .foregroundColor(Color("textColor3"))
                        AccountBasicInfosView(
                            basicAccountInfo: basicAccountInfo
                        )
                    }
                    .animation(.easeInOut, value: 200)
                }
            }
            .padding(.horizontal, 25)
            .coordinateSpace(name: "scroll")
            .onChange(of: scrollOffset) { _ in
                print("Offset: \(scrollOffset.y)")
                if scrollOffset.y > 20, !isAccountInfoShown, !isAnimationLocked {
                    simpleTaptic(type: .medium)
                    withAnimation(.interactiveSpring(
                        response: 0.5,
                        dampingFraction: 0.8,
                        blendDuration: 0.8
                    )) {
                        isAccountInfoShown = true
                        isStatusBarHide = true
                        isAnimationLocked = true
                        DispatchQueue.global()
                            .asyncAfter(deadline: .now() + 1) {
                                isAnimationLocked = false
                            }
                    }
                } else if scrollOffset.y < -20, isAccountInfoShown,
                          !isAnimationLocked {
                    simpleTaptic(type: .light)
                    withAnimation(.interactiveSpring(
                        response: 0.5,
                        dampingFraction: 0.8,
                        blendDuration: 0.8
                    )) {
                        isAccountInfoShown = false
                        isStatusBarHide = false
                        isAnimationLocked = true
                        DispatchQueue.global()
                            .asyncAfter(deadline: .now() + 1) {
                                isAnimationLocked = false
                            }
                    }
                }
            }
        }
        .background(
            AppBlockBackgroundView(
                background: account.background,
                darkModeOn: true
            )
            .matchedGeometryEffect(
                id: "\(accountUUIDString)bg",
                in: animation
            )
            .padding(-10)
            .ignoresSafeArea(.all)
            .blurMaterial(),
            alignment: .trailing
        )
        .onTapGesture {
            closeView()
        }
        .statusBarHidden(isStatusBarHide)
    }

    private func closeView() {
        DispatchQueue.main.async {
            // 复位更多信息展示页面
            isAccountInfoShown = false
            isStatusBarHide = false
            scrollOffset = .zero
        }
        simpleTaptic(type: .light)
        withAnimation(.interactiveSpring(
            response: 0.25,
            dampingFraction: 1.0,
            blendDuration: 0
        )) {
            viewModel.showDetailOfAccount = nil
        }
    }

    @ViewBuilder
    func expeditionsView() -> some View {
        VStack(alignment: .leading, spacing: 15) {
            ForEach(
                userData.expeditionInfo.expeditions,
                id: \.charactersEnglishName
            ) { expedition in
                InAppEachExpeditionView(
                    expedition: expedition,
                    useAsyncImage: true,
                    animatedMe: !isExpeditionsAppeared
                )
            }
        }
    }

    @ViewBuilder
    func recoveryTimeText(resinInfo: ResinInfo) -> some View {
        if resinInfo.recoveryTime.second != 0 {
            Text(
                String(localized: "infoBlock.refilledAt:\(resinInfo.recoveryTime.completeTimePointFromNow())")
                    + "\n\(resinInfo.recoveryTime.describeIntervalLong())"
            )
            .font(.caption)
            .lineLimit(3)
            .minimumScaleFactor(0.2)
            .foregroundColor(Color("textColor3"))
            .lineSpacing(1)
            .fixedSize()
        } else {
            Text("infoBlock.resionFullyFilledDescription")
                .font(.caption)
                .lineLimit(2)
                .minimumScaleFactor(0.2)
                .foregroundColor(Color("textColor3"))
                .lineSpacing(1)
                .fixedSize()
        }
    }
}

// MARK: - GameInfoBlockForSave

struct GameInfoBlockForSave: View {
    var userData: UserData
    let accountName: String
    var accountUUIDString: String = UUID().uuidString

    let viewConfig = WidgetViewConfiguration.defaultConfig
    var animation: Namespace.ID

    var widgetBackground: WidgetBackground
    @State
    var bgFadeOutAnimation: Bool = false

    var body: some View {
        HStack {
            Spacer()
            VStack(alignment: .leading, spacing: 5) {
                HStack(alignment: .lastTextBaseline, spacing: 2) {
                    Image(systemSymbol: .personFill)
                    Text(accountName)
                }
                .font(.footnote)
                .foregroundColor(Color("textColor3"))

                HStack(alignment: .firstTextBaseline, spacing: 2) {
                    Text("\(userData.resinInfo.currentResin)")
                        .font(.system(size: 50, design: .rounded))
                        .fontWeight(.medium)
                        .minimumScaleFactor(0.1)
                        .foregroundColor(Color("textColor3"))
                        .shadow(radius: 1)
                    Image("树脂")
                        .resizable()
                        .scaledToFit()
                        .frame(maxHeight: 30)
                        .alignmentGuide(.firstTextBaseline) { context in
                            context[.bottom] - 0.17 * context.height
                        }
                }
                HStack {
                    Image(systemSymbol: .hourglassCircle)
                        .foregroundColor(Color("textColor3"))
                        .font(.title3)
                    RecoveryTimeText(resinInfo: userData.resinInfo)
                }
            }
            .padding()
            Spacer()
            DetailInfo(userData: userData, viewConfig: .defaultConfig)
                .padding(.vertical)
                .frame(maxWidth: UIScreen.main.bounds.width / 8 * 3)
            Spacer()
        }
        .background(AppBlockBackgroundView(
            background: widgetBackground,
            darkModeOn: true
        ))
    }
}

extension View {
    func blurMaterial() -> some View {
        AnyView(
            overlay(.ultraThinMaterial)
                .preferredColorScheme(.dark)
        )
    }

    func shouldTakeAllVerticalSpace(
        _ shouldTake: Bool,
        height: CGFloat,
        animation: Namespace.ID
    )
        -> some View {
        Group {
            if shouldTake {
                self
                    .matchedGeometryEffect(
                        id: "account resin infos",
                        in: animation
                    )
                    .frame(height: height)
            } else {
                self
                    .matchedGeometryEffect(
                        id: "account resin infos",
                        in: animation
                    )
            }
        }
    }
}

// MARK: - InAppEachExpeditionView

private struct InAppEachExpeditionView: View {
    let expedition: Expedition
    let viewConfig: WidgetViewConfiguration = .defaultConfig
    var useAsyncImage: Bool = false
    var animationDelay: Double = 0
    let animatedMe: Bool

    @State
    var percentage: Double = 0.0

    var body: some View {
        HStack {
            webView(url: expedition.avatarSideIconUrl)
            VStack(alignment: .leading) {
                Text(
                    expedition.recoveryTime
                        .describeIntervalLong(
                            finishedTextPlaceholder: "已完成"
                                .localized
                        )
                )
                .lineLimit(1)
                .font(.footnote)
                .minimumScaleFactor(0.4)
                percentageBar(percentage)
                    .environment(\.colorScheme, .light)
            }
        }
        .foregroundColor(Color("textColor3"))
        .onAppear {
            if animatedMe {
                withAnimation(.interactiveSpring(
                    response: pow(expedition.percentage, 1 / 2) * 0.8,
                    dampingFraction: 1,
                    blendDuration: 0
                ).delay(animationDelay)) {
                    percentage = expedition.percentage
                }
            } else {
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
        GeometryReader { g in
            ZStack(alignment: .leading) {
                RoundedRectangle(
                    cornerRadius: cornerRadius,
                    style: .continuous
                )
                .frame(width: g.size.width, height: g.size.height)
                .foregroundStyle(.ultraThinMaterial)
                .opacity(0.6)
                RoundedRectangle(
                    cornerRadius: cornerRadius,
                    style: .continuous
                )
                .frame(
                    width: g.size.width * percentage,
                    height: g.size.height
                )
                .foregroundStyle(.thickMaterial)
            }
            .aspectRatio(30 / 1, contentMode: .fit)
//                .preferredColorScheme(.light)
        }
        .frame(height: 7)
    }
}
