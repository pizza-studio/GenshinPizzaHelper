//
//  File.swift
//
//
//  Created by 戴藏龙 on 2023/10/17.
//

import Foundation

// MARK: - GeneralDailyNote.ExpeditionInformation + Decodable

extension GeneralDailyNote.ExpeditionInformation: Decodable {
    // MARK: Private

    private enum CodingKeys: String, CodingKey {
        case maxExpeditionsCount = "max_expedition_num"
        case expeditions
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.maxExpeditionsCount = try container.decode(Int.self, forKey: .maxExpeditionsCount)
        self.expeditions = try container.decode(
            [GeneralDailyNote.ExpeditionInformation.Expedition].self,
            forKey: .expeditions
        )
    }
}

// MARK: - GeneralDailyNote.ExpeditionInformation.Expedition + Decodable

extension GeneralDailyNote.ExpeditionInformation.Expedition: Decodable {
    public init(from decoder: Decoder) throws {
        let container: KeyedDecodingContainer<GeneralDailyNote.ExpeditionInformation.Expedition.CodingKeys> =
            try decoder
                .container(keyedBy: GeneralDailyNote.ExpeditionInformation.Expedition.CodingKeys.self)
        if let timeIntervalUntilFinish = TimeInterval(try container.decode(
            String.self,
            forKey: GeneralDailyNote.ExpeditionInformation.Expedition.CodingKeys.finishTime
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
            forKey: GeneralDailyNote.ExpeditionInformation.Expedition.CodingKeys.iconURL
        )
    }

    private enum CodingKeys: String, CodingKey {
        case finishTime = "remained_time"
        case iconURL = "avatar_side_icon"
    }
}
