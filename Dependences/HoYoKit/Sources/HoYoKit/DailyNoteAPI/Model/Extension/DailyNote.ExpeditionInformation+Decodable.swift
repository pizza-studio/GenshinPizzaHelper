//
//  File.swift
//
//
//  Created by 戴藏龙 on 2023/10/17.
//

import Foundation

// MARK: - DailyNote.ExpeditionInformation + Decodable

extension DailyNote.ExpeditionInformation: Decodable {
    // MARK: Private

    private enum CodingKeys: String, CodingKey {
        case maxExpeditionsCount = "max_expedition_num"
        case expeditions
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.maxExpeditionsCount = try container.decode(Int.self, forKey: .maxExpeditionsCount)
        self.expeditions = try container.decode([DailyNote.ExpeditionInformation.Expedition].self, forKey: .expeditions)
    }
}

// MARK: - DailyNote.ExpeditionInformation.Expedition + Decodable

extension DailyNote.ExpeditionInformation.Expedition: Decodable {
    public init(from decoder: Decoder) throws {
        let container: KeyedDecodingContainer<DailyNote.ExpeditionInformation.Expedition.CodingKeys> = try decoder
            .container(keyedBy: DailyNote.ExpeditionInformation.Expedition.CodingKeys.self)
        if let timeIntervalUntilFinish = TimeInterval(try container.decode(
            String.self,
            forKey: DailyNote.ExpeditionInformation.Expedition.CodingKeys.finishTime
        )) {
            self.finishTime = Date(timeIntervalSinceNow: timeIntervalUntilFinish)
        } else {
            throw DecodingError.typeMismatch(
                Double.self,
                .init(
                    codingPath: decoder.codingPath,
                    debugDescription: "Unable to parse time interval until finished expedition"
                )
            )
        }
        self.iconURL = try container.decode(
            URL.self,
            forKey: DailyNote.ExpeditionInformation.Expedition.CodingKeys.iconURL
        )
    }

    private enum CodingKeys: String, CodingKey {
        case finishTime = "remained_time"
        case iconURL = "avatar_side_icon"
    }
}
