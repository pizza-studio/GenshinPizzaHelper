//
//  File.swift
//
//
//  Created by 戴藏龙 on 2023/10/17.
//

import Foundation

// MARK: - WidgetDailyNote

public struct WidgetDailyNote {
    // MARK: Public

    public struct DailyTaskInformation {
        public let totalTaskCount: Int
        public let finishedTaskCount: Int
        public let isExtraRewardReceived: Bool
    }

    public struct ExpeditionInformation {
        public struct Expedition {
            public let isFinished: Bool
            public let iconURL: URL
        }

        public let maxExpeditionsCount: Int
        public let expeditions: [Expedition]
    }

    public struct HomeCoinInformation {
        let maxHomeCoin: Int
        let currentHomeCoin: Int
    }

    public struct ResinInformation {
        public let maxResin: Int
        public let currentResin: Int
        public let resinRecoveryTime: Date
    }

    // MARK: Internal

    let dailyTaskInformation: DailyTaskInformation
    let expeditionInformation: ExpeditionInformation
    let homeCoinInformation: HomeCoinInformation
    let resinInformation: ResinInformation
}

extension WidgetDailyNote {
    func exampleData() -> WidgetDailyNote {
        let exampleURL = Bundle.module.url(forResource: "widget_daily_note_example", withExtension: "json")!
        let exampleData = try! Data(contentsOf: exampleURL)
        return try! WidgetDailyNote.decodeFromMiHoYoAPIJSONResult(data: exampleData)
    }
}
