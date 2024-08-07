//
//  AvatarShowCaseView.swift
//  GenshinPizzaHepler
//
//  Created by 戴藏龙 on 2022/10/3.
//

import GIPizzaKit
import SwiftUI

// MARK: - AvatarShowCaseView

struct AvatarShowCaseView: View {
    // MARK: Internal

    var account: Account

    @State
    var showingCharacterIdentifier: Int

    @State
    var showTabViewIndex: Bool = false
    @State
    var showWaterMark: Bool = true

    var playerDetail: EnkaGI.QueryRelated.ProfileTranslated

    let closeView: () -> ()

    var avatar: EnkaGI.QueryRelated.Avatar? {
        playerDetail.avatars.first(where: { avatar in
            avatar.enkaID == showingCharacterIdentifier
        })
    }

    var body: some View {
        GeometryReader { geometry in
            coreBody(detail: playerDetail)
                .environmentObject(orientation)
                .overlay(alignment: .top) {
                    HelpTextForScrollingOnDesktopComputer(.horizontal).padding()
                }.onChange(of: geometry.size) { _ in
                    showTabViewIndex = $showTabViewIndex.wrappedValue // 强制重新渲染整个画面。
                }
        }
    }

    var bottomSpacerHeight: CGFloat {
        ThisDevice.isSmallestHDScreenPhone ? 50 : 20
    }

    @ViewBuilder
    func coreBody(detail playerDetail: EnkaGI.QueryRelated.ProfileTranslated) -> some View {
        TabView(selection: $showingCharacterIdentifier.animation()) {
            // TabView 以 EnkaID 为依据。
            ForEach(playerDetail.avatars, id: \.enkaID) { avatar in
                framedCoreView(avatar)
            }
        }
        .tabViewStyle(
            .page(
                indexDisplayMode: showTabViewIndex ? .automatic :
                    .never
            )
        )
        .onTapGesture {
            closeView()
        }
        .background {
            if let avatar = avatar {
                EnkaWebIcon(iconString: avatar.characterAsset.namecard.fileName)
                    .scaledToFill()
                    .scaleEffect(1.2)
                    .ignoresSafeArea(.all)
                    .blur(radius: 30)
                    .overlay(Color(UIColor.systemGray6).opacity(0.5))
            }
        }
        .contextMenu {
            if let avatar = avatar {
                Group {
                    Button("app.detailPortal.avatar.summarzeToClipboard.asText") {
                        UIPasteboard.general.string = avatar.summaryAsText
                    }
                    Button("app.detailPortal.avatar.summarzeToClipboard.asMD") {
                        UIPasteboard.general.string = avatar.summaryAsMarkdown
                    }
                    Divider()
                    ForEach(playerDetail.avatars) { theAvatar in
                        Button(theAvatar.nameCorrected) {
                            withAnimation {
                                showingCharacterIdentifier = theAvatar.enkaID
                            }
                        }
                    }
                }
            }
        }
        .clipped()
        .compositingGroup()
        .addWaterMark(showWaterMark)
        .onChange(of: showingCharacterIdentifier) { _ in
            simpleTaptic(type: .selection)
            withAnimation(.easeIn(duration: 0.1)) {
                showTabViewIndex = true
                showWaterMark = false
            }
        }
        .ignoresSafeArea()
        .statusBarHidden(true)
        .onAppear {
            showTabViewIndex = true
            showWaterMark = false
        }
        .onChange(of: showTabViewIndex) { newValue in
            if newValue == true {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.7) {
                    withAnimation {
                        showTabViewIndex = false
                    }
                }
            }
        }
        .onChange(of: showWaterMark) { newValue in
            if newValue == false {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.7) {
                    withAnimation(.easeIn(duration: 0.1)) {
                        showWaterMark = true
                    }
                }
            }
        }
    }

    @ViewBuilder
    func framedCoreView(
        _ avatar: EnkaGI.QueryRelated.Avatar
    )
        -> some View {
        VStack {
            Spacer().frame(width: 25, height: 10)
            EachAvatarStatView(
                avatar: avatar
            ).frame(minWidth: 620, maxWidth: 830) // For iPad
                .frame(width: condenseHorizontally ? 620 : nil)
                .fixedSize(
                    horizontal: condenseHorizontally,
                    vertical: true
                )
                .scaleEffect(scaleRatioCompatible)
            Spacer().frame(width: 25, height: bottomSpacerHeight)
        }
    }

    // MARK: Private

    @StateObject
    private var orientation = ThisDevice.DeviceOrientation()

    private var scaleRatioCompatible: CGFloat {
        ThisDevice.scaleRatioCompatible
    }

    private var condenseHorizontally: Bool {
        guard OS.type != .iPhoneOS else { return true }
        guard ThisDevice.useAdaptiveSpacing else { return true }
        // iPad and macOS.
        return ThisDevice.isSplitOrSlideOver && orientation.orientation == .portrait
    }
}
