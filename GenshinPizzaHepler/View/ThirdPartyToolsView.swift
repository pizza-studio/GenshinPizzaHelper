//
//  ThirdPartyToolsView.swift
//  GenshinPizzaHepler
//
//  Created by ShikiSuen on 2023/9/26.
//

import Foundation
import HBMihoyoAPI
import SwiftUI

// MARK: - ThirdPartyToolsView

// 因应群内多数用户的要求，将「小工具」由 ToolsView 挪到这里。
// 因为无法知道当前玩家固定了哪个账号，所以会根据当前登入账号数量来显示多个原神计算器入口。

public struct ThirdPartyToolsView: View {
    // MARK: Public

    public var body: some View {
        List {
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
        .frame(maxWidth: 550)
        .sectionSpacing(UIFont.systemFontSize)
    }

    // MARK: Internal

    @EnvironmentObject
    var viewModel: ViewModel

    var availableRegions: [Region] {
        [Region](Set<Region>(accounts.compactMap { $0.config.server.region }))
    }

    var accounts: [Account] { viewModel.accounts }
}

extension ThirdPartyToolsView {
    /// 如果同时登入了多个账号的话，就给每个账号显示对应的计算器入口、
    /// 且会同时给每个入口显示 UID 脚注。
    /// - Returns: View()
    @ViewBuilder
    func genshinCalculatorLink() -> some View {
        let installed = isInstallation(urlString: "aliceworkshop://")
        if accounts.isEmpty {
            Link(
                destination: URL(string: "https://apps.apple.com/us/app/id1620751192")!
            ) {
                VStack(alignment: .leading) {
                    Text("原神计算器")
                        .foregroundColor(.primary)
                    Text(installed ? "由爱丽丝工坊提供" : "由爱丽丝工坊提供（未安装）")
                        .font(.footnote)
                        .foregroundColor(.secondary)
                }
            }
        } else {
            ForEach(accounts, id: \.config.uid) { account in
                Link(
                    destination: installed ?
                        URL(
                            string: "aliceworkshop://app/import?uid=\(account.config.uid ?? "")"
                        )! :
                        URL(string: "https://apps.apple.com/us/app/id1620751192")!
                ) {
                    VStack(alignment: .leading) {
                        Text("原神计算器")
                            .foregroundColor(.primary)
                        if accounts.count > 1 {
                            Text("UID: \(account.config.uid ?? "")")
                                .font(.footnote)
                                .foregroundColor(.secondary)
                        }
                        Text(installed ? "由爱丽丝工坊提供" : "由爱丽丝工坊提供（未安装）")
                            .font(.footnote)
                            .foregroundColor(.secondary)
                    }
                }
            }
        }
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
            case .cn: NavigationLink(
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

    func isInstallation(urlString: String?) -> Bool {
        let url = URL(string: urlString!)
        if url == nil {
            return false
        }
        if UIApplication.shared.canOpenURL(url!) {
            return true
        }
        return false
    }
}
