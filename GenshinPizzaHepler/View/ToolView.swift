//
//  ToolView.swift
//  GenshinPizzaHepler
//
//  Created by 戴藏龙 on 2023/12/3.
//

import Foundation
import HoYoKit
import SwiftUI

// MARK: - ToolView

struct ToolView: View {
    enum Navigation: Hashable {
        case gacha
        case abyss
        case dictionary
        case map(Region)
        case namecardsPreview
    }

    @State
    var navigation: Navigation?

    var body: some View {
        NavigationSplitView {
            List(selection: $navigation) {
                Section {
                    NavigationLink(value: Navigation.gacha) {
                        Label {
                            Text("app.gacha.title")
                                .foregroundColor(.primary)
                        } icon: {
                            Image("UI_MarkPoint_SummerTimeV2_Dungeon_04").resizable()
                                .scaledToFit()
                        }
                    }
                    NavigationLink(value: Navigation.abyss) {
                        Label {
                            Text("app.abyss.rank.title")
                                .foregroundColor(.primary)
                        } icon: {
                            Image("UI_MarkTower_EffigyChallenge_01").resizable()
                                .scaledToFit()
                        }
                    }
                }
                ThirdPartyToolsView()
            }
            .listStyle(.insetGrouped)
            .navigationTitle("app.tools.title")
        } detail: {
            NavigationStack {
                switch navigation {
                case .gacha:
                    GachaView()
                case .abyss:
                    AbyssDataCollectionView()
                case .dictionary:
                    GenshinDictionary()
                case let .map(region):
                    TeyvatMapWebView(region: region)
                case .namecardsPreview:
                    BackgroundsPreviewView()
                case nil:
                    GachaView()
                }
            }
        }
    }
}

// MARK: - ThirdPartyToolsView

public struct ThirdPartyToolsView: View {
    // MARK: Public

    public var body: some View {
        Section {
            NavigationLink(value: ToolView.Navigation.dictionary) {
                Text("tools.dictionary.title")
            }
            mapNavigationLink()
            genshinCalculatorLink()
            NavigationLink(value: ToolView.Navigation.namecardsPreview) {
                Text("settings.travelTools.backgroundNamecardPreview")
            }
        }
    }

    // MARK: Internal

    @FetchRequest(sortDescriptors: [.init(
        keyPath: \AccountConfiguration.priority,
        ascending: true
    )])
    var accounts: FetchedResults<AccountConfiguration>

    var availableRegions: [Region] {
        [Region](Set<Region>(accounts.compactMap { $0.server.region }))
    }
}

// MARK: - GenshinCalculatorLink

struct GenshinCalculatorLink: View {
    // MARK: Public

    public static func isInstallation(urlString: String?) -> Bool {
        guard let url = URL(string: urlString!) else { return false }
        return UIApplication.shared.canOpenURL(url)
    }

    // MARK: Internal

    @FetchRequest(sortDescriptors: [.init(
        keyPath: \AccountConfiguration.priority,
        ascending: true
    )])
    var accounts: FetchedResults<AccountConfiguration>

    @State
    var isAlertShow: Bool = false

    var body: some View {
        let installed = Self.isInstallation(urlString: "aliceworkshop://")
        if !installed {
            Link(
                destination: URL(string: "https://apps.apple.com/us/app/id1620751192")!
            ) {
                VStack(alignment: .leading) {
                    Text("tools.calculator.title")
                        .foregroundColor(.primary)
                    Text("tools.calculator.info.2")
                        .font(.footnote)
                        .foregroundColor(.secondary)
                }
            }
        } else {
            Button {
                isAlertShow.toggle()
            } label: {
                VStack(alignment: .leading) {
                    Text("tools.calculator.title")
                        .foregroundColor(.primary)
                    Text("tools.calculator.info")
                        .font(.footnote)
                        .foregroundColor(.secondary)
                }
            }
            .alert("app.tool.3rdparty.alice.selectAccount", isPresented: $isAlertShow) {
                ForEach(accounts, id: \.safeUid) { account in
                    Link(
                        destination: URL(
                            string: "aliceworkshop://app/import?uid=\(account.safeUid)"
                        )!
                    ) {
                        Text(verbatim: "UID: \(account.safeUid)")
                    }
                }
                Button("sys.cancel", role: .cancel) {
                    isAlertShow.toggle()
                }
            }
        }
    }
}

extension ThirdPartyToolsView {
    /// 如果同时登入了多个账号的话，就给每个账号显示对应的计算器入口、
    /// 且会同时给每个入口显示 UID 脚注。
    /// - Returns: View()
    @ViewBuilder
    func genshinCalculatorLink() -> some View {
        GenshinCalculatorLink()
    }

    /// 检测当前登入的账号数量，做综合统计。
    /// 如果发现同时有登入国服与国际服的话，则同时显示两个不同区服的提瓦特互动地图的入口。
    /// 如果只有一个的话，会按需显示对应的那一个、且不会显示用以区分两者的 Emoji。
    /// - Returns: View()
    @ViewBuilder
    func mapNavigationLink() -> some View {
        let regions = availableRegions.isEmpty ? Region.allCases : availableRegions
        ForEach(regions, id: \.self) { region in
            let emoji = region == .mainlandChina ? " 🇨🇳" : " 🌏"
            let additionalFlag = regions.count > 1 ? emoji : ""
            if OS.type == .macOS, let url = region.teyvatInteractiveMapURL {
                Link(destination: url) {
                    Text("tools.teyvatInteractiveMap".localized + additionalFlag)
                }
            } else {
                NavigationLink(value: ToolView.Navigation.map(region)) {
                    Text("tools.teyvatInteractiveMap".localized + additionalFlag)
                }
            }
        }
    }
}
