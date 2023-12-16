//
//  AccountBasicInfosView.swift
//  GenshinPizzaHepler
//
//  Created by Bill Haku on 2022/9/13.
//

import HBMihoyoAPI
import HoYoKit
import SwiftUI

// MARK: - AccountBasicInfosView

struct AccountBasicInfosView: View {
    var basicAccountInfo: BasicInfos?

    var body: some View {
        if let basicAccountInfo = basicAccountInfo {
            Section {
                if Locale.isUILanguagePanChinese,
                   !(ThisDevice.isSmallestSlideOverWindowWidth || ThisDevice.isSmallestHDScreenPhone) {
                    HStack(alignment: .top) {
                        VStack(spacing: 5) {
                            InfoPreviewer(
                                title: "app.account.basicInfo.daysActive",
                                content: "\(basicAccountInfo.stats.activeDayNumber)",
                                contentStyle: .capsule
                            )
                            InfoPreviewer(
                                title: "app.account.basicInfo.characters",
                                content: "\(basicAccountInfo.stats.avatarNumber)",
                                contentStyle: .capsule
                            )
                            InfoPreviewer(
                                title: "app.account.basicInfo.abyss",
                                content: basicAccountInfo.stats.spiralAbyss,
                                contentStyle: .capsule
                            )
                            InfoPreviewer(
                                title: "app.account.basicInfo.chest.1",
                                content: "\(basicAccountInfo.stats.commonChestNumber)",
                                contentStyle: .capsule
                            )
                            InfoPreviewer(
                                title: "app.account.basicInfo.chest.3",
                                content: "\(basicAccountInfo.stats.preciousChestNumber)",
                                contentStyle: .capsule
                            )
                            InfoPreviewer(
                                title: "app.account.basicInfo.anemo",
                                content: "\(basicAccountInfo.stats.anemoculusNumber)",
                                contentStyle: .capsule
                            )
                            InfoPreviewer(
                                title: "app.account.basicInfo.electro",
                                content: "\(basicAccountInfo.stats.electroculusNumber)",
                                contentStyle: .capsule
                            )
                            InfoPreviewer(
                                title: "app.account.basicInfo.hydro",
                                content: "\(basicAccountInfo.stats.hydroculusNumber)",
                                contentStyle: .capsule
                            )
                        }
                        VStack(spacing: 5) {
                            InfoPreviewer(
                                title: "app.account.basicInfo.achievements",
                                content: "\(basicAccountInfo.stats.achievementNumber)",
                                contentStyle: .capsule
                            )
                            InfoPreviewer(
                                title: "app.account.basicInfo.waypoints",
                                content: "\(basicAccountInfo.stats.wayPointNumber)",
                                contentStyle: .capsule
                            )
                            InfoPreviewer(
                                title: "app.account.basicInfo.domains",
                                content: "\(basicAccountInfo.stats.domainNumber)",
                                contentStyle: .capsule
                            )
                            InfoPreviewer(
                                title: "app.account.basicInfo.chest.2",
                                content: "\(basicAccountInfo.stats.exquisiteChestNumber)",
                                contentStyle: .capsule
                            )
                            InfoPreviewer(
                                title: "app.account.basicInfo.chest.4",
                                content: "\(basicAccountInfo.stats.luxuriousChestNumber)",
                                contentStyle: .capsule
                            )
                            InfoPreviewer(
                                title: "app.account.basicInfo.geo",
                                content: "\(basicAccountInfo.stats.geoculusNumber)",
                                contentStyle: .capsule
                            )
                            InfoPreviewer(
                                title: "app.account.basicInfo.dendro",
                                content: "\(basicAccountInfo.stats.dendroculusNumber)",
                                contentStyle: .capsule
                            )
                        }
                    }
                } else {
                    VStack(spacing: 5) {
                        Group {
                            InfoPreviewer(
                                title: "app.account.basicInfo.daysActive",
                                content: "\(basicAccountInfo.stats.activeDayNumber)",
                                contentStyle: .capsule
                            )
                            InfoPreviewer(
                                title: "app.account.basicInfo.characters",
                                content: "\(basicAccountInfo.stats.avatarNumber)",
                                contentStyle: .capsule
                            )
                            InfoPreviewer(
                                title: "app.account.basicInfo.abyss",
                                content: basicAccountInfo.stats.spiralAbyss,
                                contentStyle: .capsule
                            )
                            InfoPreviewer(
                                title: "app.account.basicInfo.achievements",
                                content: "\(basicAccountInfo.stats.achievementNumber)",
                                contentStyle: .capsule
                            )
                            InfoPreviewer(
                                title: "app.account.basicInfo.waypoints",
                                content: "\(basicAccountInfo.stats.wayPointNumber)",
                                contentStyle: .capsule
                            )
                            InfoPreviewer(
                                title: "app.account.basicInfo.domains",
                                content: "\(basicAccountInfo.stats.domainNumber)",
                                contentStyle: .capsule
                            )
                        }
                        Group {
                            InfoPreviewer(
                                title: "app.account.basicInfo.chest.1",
                                content: "\(basicAccountInfo.stats.commonChestNumber)",
                                contentStyle: .capsule
                            )
                            InfoPreviewer(
                                title: "app.account.basicInfo.chest.3",
                                content: "\(basicAccountInfo.stats.preciousChestNumber)",
                                contentStyle: .capsule
                            )
                            InfoPreviewer(
                                title: "app.account.basicInfo.chest.2",
                                content: "\(basicAccountInfo.stats.exquisiteChestNumber)",
                                contentStyle: .capsule
                            )
                            InfoPreviewer(
                                title: "app.account.basicInfo.chest.4",
                                content: "\(basicAccountInfo.stats.luxuriousChestNumber)",
                                contentStyle: .capsule
                            )
                        }
                        Group {
                            InfoPreviewer(
                                title: "app.account.basicInfo.anemo",
                                content: "\(basicAccountInfo.stats.anemoculusNumber)",
                                contentStyle: .capsule
                            )
                            InfoPreviewer(
                                title: "app.account.basicInfo.electro",
                                content: "\(basicAccountInfo.stats.electroculusNumber)",
                                contentStyle: .capsule
                            )
                            InfoPreviewer(
                                title: "app.account.basicInfo.geo",
                                content: "\(basicAccountInfo.stats.geoculusNumber)",
                                contentStyle: .capsule
                            )
                            InfoPreviewer(
                                title: "app.account.basicInfo.dendro",
                                content: "\(basicAccountInfo.stats.dendroculusNumber)",
                                contentStyle: .capsule
                            )
                            InfoPreviewer(
                                title: "app.account.basicInfo.hydro",
                                content: "\(basicAccountInfo.stats.hydroculusNumber)",
                                contentStyle: .capsule
                            )
                        }
                    }
                }
            } header: {
                Text("app.account.basicInfo.summary")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .padding(.top)
                    .padding(.bottom, 6.5)
            }
            Section {
                ScrollView(.horizontal) {
                    WorldExplorationsViewAll(basicAccountInfo: basicAccountInfo)
                }
            } header: {
                Text("app.account.basicInfo.exploration")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .padding(.top)
                    .padding(.bottom, 5)
            } footer: {
                HStack {
                    Spacer()
                    HelpTextForScrollingOnDesktopComputer(.horizontal).padding()
                    Spacer()
                }
            }
            // 一段空白区域用于填充底部，垫高整体
            Spacer(minLength: 50)
        } else {
            HStack {
                Spacer()
                ProgressView()
                Spacer()
            }
        }
    }
}

// MARK: - WorldExplorationsView

private struct WorldExplorationsView: View {
    var data: BasicInfos.WorldExploration

    var body: some View {
        VStack {
            WebImage(urlStr: data.icon)
                .frame(width: 70, height: 70)
            Text(data.name)
                .fixedSize()
            Text(calculatePercentage(
                value: Double(data.explorationPercentage) /
                    Double(1000)
            ))
            .fixedSize()
            .font(.footnote)
        }
    }

    func calculatePercentage(value: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .percent
        return formatter.string(from: value as NSNumber) ?? "Error"
    }
}

// MARK: - WorldOfferingsExplorationsView

private struct WorldOfferingsExplorationsView: View {
    var data: BasicInfos.WorldExploration.Offering

    var body: some View {
        VStack(alignment: .center) {
            WebImage(urlStr: data.icon)
                .frame(width: 30, height: 30)
            Text(data.name)
                .fixedSize()
            Text(verbatim: "Lv. \(data.level)")
                .fixedSize()
                .font(.footnote)
        }
    }
}

// MARK: - WorldExplorationsViewAll

private struct WorldExplorationsViewAll: View {
    let basicAccountInfo: BasicInfos

    var body: some View {
        if #available(iOS 16, *) {
            Grid(horizontalSpacing: 20, verticalSpacing: 10) {
                GridRow {
                    ForEach(basicAccountInfo.worldExplorations.sorted {
                        $0.id < $1.id
                    }, id: \.id) { worldData in
                        WorldExplorationsView(data: worldData)
                            .frame(minWidth: 80)
                    }
                }
                GridRow {
                    ForEach(basicAccountInfo.worldExplorations.sorted {
                        $0.id < $1.id
                    }, id: \.id) { worldData in
                        VStack(alignment: .center, spacing: 10) {
                            let offerings = worldData.offerings
                            if worldData.id != 6 { // 取消层岩地上的流明石的显示
                                ForEach(offerings, id: \.name) { offering in
                                    WorldOfferingsExplorationsView(
                                        data: offering
                                    )
                                }
                            }
                        }
                    }
                }
            }
        } else {
            HStack(alignment: .top) {
                ForEach(basicAccountInfo.worldExplorations.sorted {
                    $0.id < $1.id
                }, id: \.id) { worldData in
                    VStack(alignment: .center, spacing: 10) {
                        WorldExplorationsView(data: worldData)
                        let offerings = worldData.offerings
                        if worldData.id != 6 { // 取消层岩地上的流明石的显示
                            ForEach(offerings, id: \.name) { offering in
                                WorldOfferingsExplorationsView(
                                    data: offering
                                )
                            }
                        }
                    }
                    .frame(minWidth: 80)
                }
            }
            .padding(.vertical, 5)
        }
    }
}
