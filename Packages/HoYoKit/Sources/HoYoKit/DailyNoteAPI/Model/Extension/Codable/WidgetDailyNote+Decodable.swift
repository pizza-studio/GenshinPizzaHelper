//
//  File.swift
//
//
//  Created by 戴藏龙 on 2023/10/17.
//

import Foundation

// MARK: - WidgetDailyNote + Decodable

extension WidgetDailyNote: Decodable {
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        self.dailyTaskInformation = try container.decode(WidgetDailyNote.DailyTaskInformation.self)
        self.expeditionInformation = try container.decode(WidgetDailyNote.ExpeditionInformation.self)
        self.homeCoinInformation = try container.decode(WidgetDailyNote.HomeCoinInformation.self)
        self.resinInformation = try container.decode(WidgetDailyNote.ResinInformation.self)
    }
}

// MARK: - WidgetDailyNote + DecodableFromMiHoYoAPIJSONResult

extension WidgetDailyNote: DecodableFromMiHoYoAPIJSONResult {}
