//
//  File.swift
//
//
//  Created by 戴藏龙 on 2023/10/17.
//

import Foundation

// MARK: - WidgetDailyNote.ExpeditionInformation.Expedition + Decodable

extension WidgetDailyNote.ExpeditionInformation.Expedition: Decodable {
    enum CodingKeys: String, CodingKey {
        case status
        case iconURL = "avatar_side_icon"
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        if try container.decode(String.self, forKey: CodingKeys.status) == "Finished" {
            self.isFinished = true
        } else {
            self.isFinished = false
        }
        self.iconURL = try container.decode(URL.self, forKey: CodingKeys.iconURL)
    }
}

// MARK: - WidgetDailyNote.ExpeditionInformation + Decodable

extension WidgetDailyNote.ExpeditionInformation: Decodable {
    enum CodingKeys: String, CodingKey {
        case maxExpeditionsCount = "max_expedition_num"
        case expeditions
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.maxExpeditionsCount = try container.decode(Int.self, forKey: CodingKeys.maxExpeditionsCount)
        self.expeditions = try container.decode(
            [WidgetDailyNote.ExpeditionInformation.Expedition].self,
            forKey: CodingKeys.expeditions
        )
    }
}
