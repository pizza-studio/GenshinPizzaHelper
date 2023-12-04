//
//  ThirdPartyToolsView.swift
//  GenshinPizzaHepler
//
//  Created by ShikiSuen on 2023/9/26.
//

import Foundation
import HBMihoyoAPI
import HoYoKit
import SwiftUI

// MARK: - ThirdPartyToolsView

// TODO: 小工具板块

// 因应群内多数用户的要求，将「小工具」由 ToolsView 挪到这里。
// 因为无法知道当前玩家固定了哪个账号，所以会根据当前登入账号数量来显示多个原神计算器入口。

public struct ThirdPartyToolsView: View {
    // MARK: Public

    public var body: some View {
        Section {
            NavigationLink(destination: GenshinDictionary()) {
                Text("原神中英日辞典")
            }
            mapNavigationLink()
            genshinCalculatorLink()
            NavigationLink(destination: BackgroundsPreviewView()) {
                Text("settings.travelTools.backgroundNamecardPreview")
            }
        }
    }

    // MARK: Internal

    @FetchRequest(sortDescriptors: [.init(
        keyPath: \AccountConfiguration.priority,
        ascending: false
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
        ascending: false
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
                    Text("原神计算器")
                        .foregroundColor(.primary)
                    Text("由爱丽丝工坊提供（未安装）")
                        .font(.footnote)
                        .foregroundColor(.secondary)
                }
            }
        } else {
            Button {
                isAlertShow.toggle()
            } label: {
                VStack(alignment: .leading) {
                    Text("原神计算器")
                        .foregroundColor(.primary)
                    Text("由爱丽丝工坊提供")
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
                        Text("UID: \(account.safeUid)")
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
            switch region {
            case .mainlandChina: NavigationLink(
                    destination:
                    TeyvatMapWebView(isHoYoLAB: false)
                        .navigationTitle("提瓦特大地图")
                        .navigationBarTitleDisplayMode(.inline)
                ) {
                    let additionalFlag = regions.count > 1 ? " 🇨🇳" : ""
                    Text("提瓦特大地图".localized + additionalFlag)
                }
            case .global: NavigationLink(
                    destination:
                    TeyvatMapWebView(isHoYoLAB: true)
                        .navigationTitle("提瓦特大地图")
                        .navigationBarTitleDisplayMode(.inline)
                ) {
                    let additionalFlag = regions.count > 1 ? " 🌏" : ""
                    Text("提瓦特大地图".localized + additionalFlag)
                }
            }
        }
    }
}
