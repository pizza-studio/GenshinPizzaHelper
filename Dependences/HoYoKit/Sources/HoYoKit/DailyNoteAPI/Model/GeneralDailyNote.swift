//
//  File.swift
//
//
//  Created by 戴藏龙 on 2023/10/16.
//

import Foundation

// MARK: - GeneralDailyNote

public struct GeneralDailyNote: DailyNote {
    public struct DailyTaskInformation: HoYoKit.DailyTaskInformation {
        public let totalTaskCount: Int
        public let finishedTaskCount: Int
        public let isExtraRewardReceived: Bool

        /// 历练点进度百分比
        public let attendanceRewards: [Double]

        /// 每个每日任务状态
        public let taskRewards: [Bool]

        // MARK: Private
    }

    public struct ExpeditionInformation: HoYoKit.ExpeditionInformation {
        public struct Expedition: HoYoKit.Expedition {
            public let finishTime: Date
            public let iconURL: URL

            public var isFinished: Bool { finishTime <= Date() }
        }

        public let maxExpeditionsCount: Int
        public let expeditions: [Expedition]
    }

    public struct HomeCoinInformation: HoYoKit.HomeCoinInformation {
        public let maxHomeCoin: Int
        public let currentHomeCoin: Int
        public let fullTime: Date
    }

    public struct ResinInformation: HoYoKit.ResinInformation {
        public let maxResin: Int
        public let currentResin: Int
        public let resinRecoveryTime: Date
    }

    public struct TransformerInformation {
        public let obtained: Bool
        public let recoveryTime: Date
    }

    public struct WeeklyBossesInformation {
        public let totalResinDiscount: Int
        public let remainResinDiscount: Int
    }

    public let dailyTaskInformation: DailyTaskInformation
    public let resinInformation: ResinInformation
    public let weeklyBossesInformation: WeeklyBossesInformation
    public let expeditionInformation: ExpeditionInformation
    public let transformerInformation: TransformerInformation
    public let homeCoinInformation: HomeCoinInformation
}

extension GeneralDailyNote {
    func exampleData() -> GeneralDailyNote {
        let exampleURL = Bundle.module.url(forResource: "daily_note_example", withExtension: "json")!
        let exampleData = try! Data(contentsOf: exampleURL)
        return try! GeneralDailyNote.decodeFromMiHoYoAPIJSONResult(data: exampleData)
    }
}
