//
//  WatchAccountDetailView.swift
//  WatchHelper WatchKit Extension
//
//  Created by Bill Haku on 2022/9/9.
//

import HoYoKit
import SwiftUI

// MARK: - WatchAccountDetailView

struct WatchAccountDetailView: View {
    var data: any DailyNote
    let accountName: String?
    var uid: String?

    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                Group {
                    Divider()
                    WatchResinDetailView(resinInfo: data.resinInformation)
                    Divider()
                    VStack(alignment: .leading, spacing: 5) {
                        WatchAccountDetailItemView(
                            title: "洞天宝钱",
                            value: "\(data.homeCoinInformation.currentHomeCoin)",
                            icon: Image("洞天宝钱")
                        )
                        Divider()
                        WatchAccountDetailItemView(
                            title: "每日委托",
                            value: "\(data.dailyTaskInformation.finishedTaskCount) / \(data.dailyTaskInformation.totalTaskCount)",
                            icon: Image("每日任务")
                        )
                        if let data = data as? GeneralDailyNote {
                            Group {
                                Divider()
                                WatchAccountDetailItemView(
                                    title: "参量质变仪",
                                    value: intervalFormatter
                                        .string(
                                            from: TimeInterval
                                                .sinceNow(to: data.transformerInformation.recoveryTime)
                                        )!,
                                    icon: Image("参量质变仪")
                                )
                                Divider()
                                WatchAccountDetailItemView(
                                    title: "周本折扣",
                                    value: "\(data.weeklyBossesInformation.remainResinDiscount) / \(data.weeklyBossesInformation.totalResinDiscount)",
                                    icon: Image("征讨领域")
                                )
                            }
                        }
                        Divider()
                        WatchAccountDetailItemView(
                            title: "探索派遣",
                            value: "\(data.expeditionInformation.ongoingExpeditionCount) / \(data.expeditionInformation.maxExpeditionsCount)",
                            icon: Image("派遣探索")
                        )
                    }
                    Divider()
                    VStack(alignment: .leading, spacing: 10) {
                        ForEach(
                            data.expeditionInformation.expeditions,
                            id: \.iconURL
                        ) { expedition in
                            WatchEachExpeditionView(
                                expedition: expedition,
                                useAsyncImage: true
                            )
                            .frame(maxHeight: 40)
                        }
                    }
                }
            }
        }
        .navigationTitle(accountName ?? "")
    }

    func recoveryTimeText(resinInfo: ResinInformation) -> String {
        if resinInfo.resinRecoveryTime >= Date() {
            let localizedStr = NSLocalizedString(
                "infoBlock.refilledAt:%@",
                comment: "resin replenished"
            )
            return String(
                format: localizedStr,
                dateFormatter.string(from: resinInfo.resinRecoveryTime)
            )
        } else {
            return "infoBlock.resionFullyFilledDescription".localized
        }
    }
}

// MARK: - WatchEachExpeditionView

private struct WatchEachExpeditionView: View {
    let expedition: any Expedition
    let viewConfig: WidgetViewConfiguration = .defaultConfig
    var useAsyncImage: Bool = false
    var animationDelay: Double = 0

    var body: some View {
        HStack {
            AsyncImage(url: expedition.iconURL, content: { image in
                GeometryReader { g in
                    image.resizable()
                        .scaledToFit()
                        .scaleEffect(1.5)
                        .offset(x: -g.size.width * 0.06, y: -g.size.height * 0.25)
                }
            }, placeholder: {
                ProgressView()
            })
            .frame(width: 25, height: 25)
            if let expedition = expedition as? GeneralDailyNote.ExpeditionInformation.Expedition {
                VStack(alignment: .leading) {
                    Text(intervalFormatter.string(from: TimeInterval.sinceNow(to: expedition.finishTime))!)
                        .font(.footnote)
                    percentageBar(TimeInterval.sinceNow(to: expedition.finishTime) / Double(20 * 60 * 60))
                }
            } else {
                VStack(alignment: .leading) {
                    Text(expedition.isFinished ? "已完成" : "未完成")
                        .font(.footnote)
                    percentageBar(expedition.isFinished ? 0 : 1)
                }
            }
        }
        .foregroundColor(Color("textColor3"))
        .padding(.trailing)
    }

    @ViewBuilder
    func percentageBar(_ percentage: Double) -> some View {
        let cornerRadius: CGFloat = 3
        GeometryReader { g in
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .opacity(0.3)
                    .frame(width: g.size.width, height: g.size.height)
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .frame(
                        width: g.size.width * percentage,
                        height: g.size.height
                    )
            }
            .aspectRatio(30 / 1, contentMode: .fit)
        }
        .frame(height: 7)
    }
}

private let dateFormatter: DateFormatter = {
    let fmt = DateFormatter()
    fmt.doesRelativeDateFormatting = true
    fmt.dateStyle = .none
    fmt.timeStyle = .short
    return fmt
}()

private let intervalFormatter: DateComponentsFormatter = {
    let dateComponentFormatter = DateComponentsFormatter()
    dateComponentFormatter.allowedUnits = [.hour, .minute]
    dateComponentFormatter.maximumUnitCount = 2
    dateComponentFormatter.unitsStyle = .brief
    return dateComponentFormatter
}()
