//
//  File.swift
//
//
//  Created by 戴藏龙 on 2023/10/17.
//

import Foundation

// MARK: - GeneralDailyNote + Decodable

extension GeneralDailyNote: Decodable {
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        self.dailyTaskInformation = try container.decode(DailyTaskInformation.self)
        self.resinInformation = try container.decode(ResinInformation.self)
        self.weeklyBossesInformation = try container.decode(WeeklyBossesInformation.self)
        self.expeditionInformation = try container.decode(ExpeditionInformation.self)
        self.transformerInformation = try container.decode(TransformerInformation.self)
        self.homeCoinInformation = try container.decode(HomeCoinInformation.self)
    }
}

// MARK: - GeneralDailyNote + DecodableFromMiHoYoAPIJSONResult

extension GeneralDailyNote: DecodableFromMiHoYoAPIJSONResult {}
