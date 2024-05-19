//
//  CharacterDetailView.swift
//  GenshinPizzaHepler
//
//  Created by 戴藏龙 on 2022/10/3.
//

import GIPizzaKit
import SwiftUI

// MARK: - CharacterDetailView

struct CharacterDetailView: View {
    // MARK: Internal

    var account: AccountConfiguration

    @State
    var showingCharacterName: String

    @State
    var showTabViewIndex: Bool = false
    @State
    var showWaterMark: Bool = true

    var playerDetail: PlayerDetail

    let closeView: () -> ()

    var avatar: PlayerDetail.Avatar? {
        playerDetail.avatars.first(where: { avatar in
            avatar.name == showingCharacterName
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
    func coreBody(detail playerDetail: PlayerDetail) -> some View {
        TabView(selection: $showingCharacterName.animation()) {
            // TabView 以 Name 为依据，不能仅依赖资料本身的 Identifiable 特性。
            ForEach(playerDetail.avatars, id: \.name) { avatar in
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
        .clipped()
        .addWaterMark(showWaterMark)
        .onChange(of: showingCharacterName) { _ in
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
        _ avatar: PlayerDetail
            .Avatar
    )
        -> some View {
        VStack {
            Spacer().frame(width: 25, height: 10)
            EachCharacterDetailDataView(
                avatar: avatar
            ).frame(minWidth: 620, maxWidth: 830) // For iPad
                .frame(width: condenseHorizontally ? 620 : nil)
                .fixedSize(
                    horizontal: condenseHorizontally,
                    vertical: true
                )
                .scaleEffect(scaleRatioCompatible)
                .contextMenu {
                    Group {
                        if let textSummary = playerDetail.summariesText[avatar.enkaID] {
                            Button("app.detailPortal.avatar.summarzeToClipboard.asText") {
                                UIPasteboard.general.string = textSummary
                            }
                        }
                        if let mdSummary = playerDetail.summariesMarkDown[avatar.enkaID] {
                            Button("app.detailPortal.avatar.summarzeToClipboard.asMD") {
                                UIPasteboard.general.string = mdSummary
                            }
                        }
                    }
                }
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
