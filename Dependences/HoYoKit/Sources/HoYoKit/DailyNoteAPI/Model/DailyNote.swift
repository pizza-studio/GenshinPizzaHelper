//
//  File.swift
//
//
//  Created by 戴藏龙 on 2023/10/16.
//

import Foundation

// MARK: - DailyNote

public struct DailyNote {
    public struct DailyTaskInformation {
        public let totalTaskCount: Int
        public let finishedTaskCount: Int
        public let isExtraRewardReceived: Bool

        /// 历练点进度百分比
        public let attendanceRewards: [Double]

        /// 每个每日任务状态
        public let taskRewards: [Bool]

        // MARK: Private
    }

    public struct ExpeditionInformation {
        public struct Expedition {
            public let finishTime: Date
            public let iconURL: URL
        }

        public let maxExpeditionsCount: Int
        public let expeditions: [Expedition]
    }

    public struct HomeCoinInformation {
        let maxHomeCoin: Int
        let currentHomeCoin: Int
        let fullTime: Date
    }

    public struct ResinInformation {
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

extension DailyNote {
    func exampleData() -> DailyNote {
        let exampleURL = Bundle.module.url(forResource: "daily_note_example", withExtension: "json")!
        let exampleData = try! Data(contentsOf: exampleURL)
        return try! DailyNote.decodeFromMiHoYoAPIJSONResult(data: exampleData)
    }
}
