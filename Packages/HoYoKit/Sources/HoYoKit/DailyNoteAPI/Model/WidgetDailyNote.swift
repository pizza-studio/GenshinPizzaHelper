//
//  File.swift
//
//
//  Created by 戴藏龙 on 2023/10/17.
//

import Foundation

// MARK: - WidgetDailyNote

public struct WidgetDailyNote: DailyNote {
    public struct DailyTaskInformation: HoYoKit.DailyTaskInformation {
        public let totalTaskCount: Int
        public let finishedTaskCount: Int
        public let isExtraRewardReceived: Bool
    }

    public struct ExpeditionInformation: HoYoKit.ExpeditionInformation {
        public struct Expedition: HoYoKit.Expedition {
            public let isFinished: Bool
            public let iconURL: URL
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

    public let dailyTaskInformation: DailyTaskInformation
    public let expeditionInformation: ExpeditionInformation
    public let homeCoinInformation: HomeCoinInformation
    public let resinInformation: ResinInformation
}

extension WidgetDailyNote {
    func exampleData() -> WidgetDailyNote {
        let exampleURL = Bundle.module.url(forResource: "widget_daily_note_example", withExtension: "json")!
        let exampleData = try! Data(contentsOf: exampleURL)
        return try! WidgetDailyNote.decodeFromMiHoYoAPIJSONResult(data: exampleData)
    }
}
