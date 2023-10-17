//
//  File.swift
//
//
//  Created by 戴藏龙 on 2023/10/17.
//

import Foundation

extension WidgetDailyNote.DailyTaskInformation: Decodable {
    enum CodingKeys: String, CodingKey {
        case totalTaskCount = "total_task_num"
        case finishedTaskCount = "finished_task_num"
        case isExtraRewardReceived = "is_extra_task_reward_received"
    }

    public init(from decoder: Decoder) throws {
        let container: KeyedDecodingContainer<WidgetDailyNote.DailyTaskInformation.CodingKeys> = try decoder
            .container(keyedBy: WidgetDailyNote.DailyTaskInformation.CodingKeys.self)
        self.totalTaskCount = try container.decode(
            Int.self,
            forKey: WidgetDailyNote.DailyTaskInformation.CodingKeys.totalTaskCount
        )
        self.finishedTaskCount = try container.decode(
            Int.self,
            forKey: WidgetDailyNote.DailyTaskInformation.CodingKeys.finishedTaskCount
        )
        self.isExtraRewardReceived = try container.decode(
            Bool.self,
            forKey: WidgetDailyNote.DailyTaskInformation.CodingKeys.isExtraRewardReceived
        )
    }
}
