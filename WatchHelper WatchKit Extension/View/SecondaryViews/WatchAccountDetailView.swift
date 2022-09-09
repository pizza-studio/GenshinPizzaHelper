//
//  WatchAccountDetailView.swift
//  WatchHelper WatchKit Extension
//
//  Created by Bill Haku on 2022/9/9.
//

import SwiftUI

struct WatchAccountDetailView: View {
    var userData: Result<UserData, FetchError>
    let accountName: String?
    var uid: String?
    
    var body: some View {
        switch userData {
        case .success(let data):
            ScrollView {
                VStack(alignment: .leading) {
                    Group {
                        WatchAccountDetailItemView(title: "UID", value: uid ?? "0")
                        Divider()
                        WatchAccountDetailItemView(title: "当前树脂", value: "\(data.resinInfo.currentResin)")
                        Divider()
                        WatchAccountDetailItemView(title: "回满时间", value: recoveryTimeText(resinInfo: data.resinInfo))
                        Divider()
                        WatchAccountDetailItemView(title: "洞天宝钱", value: "\(data.homeCoinInfo.currentHomeCoin)")
                        Divider()
                        WatchAccountDetailItemView(title: "每日委托", value: "\(data.dailyTaskInfo.finishedTaskNum) / \(data.dailyTaskInfo.totalTaskNum)")
                        Divider()
                    }
                    Group {
                        WatchAccountDetailItemView(title: "探索派遣", value: "\(data.expeditionInfo.currentOngoingTask) / \(data.expeditionInfo.maxExpedition)")
                        Divider()
                        WatchAccountDetailItemView(title: "参量质变仪", value: "\(data.transformerInfo.recoveryTime.completeTimePointFromNow ?? "已完成")")
                        Divider()
                        WatchAccountDetailItemView(title: "周本", value: "\(data.weeklyBossesInfo.hasUsedResinDiscountNum) / \(data.weeklyBossesInfo.resinDiscountNumLimit)")
                    }
                }
            }
            .navigationTitle(accountName ?? "")
        case .failure(_):
            Text("Error")
        }
    }

    func recoveryTimeText(resinInfo: ResinInfo) -> String {
        if resinInfo.recoveryTime.second != 0 {
            let localizedStr = NSLocalizedString("%@ 回满", comment: "resin replenished")
            return String(format: localizedStr, resinInfo.recoveryTime.completeTimePointFromNow!)
        } else {
            return "0小时0分钟\n树脂已全部回满".localized
        }
    }
}
