//
//  File.swift
//
//
//  Created by 戴藏龙 on 2023/10/17.
//

import Foundation

// MARK: - ResinInformation

// MARK: Decodable

extension DailyNote.ResinInformation: Decodable {
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.maxResin = try container.decode(Int.self, forKey: .maxResin)
        self.currentResin = try container.decode(Int.self, forKey: .currentResin)
        if let resinRecoveryTimeInterval = TimeInterval(try container.decode(String.self, forKey: .resinRecoveryTime)) {
            self.resinRecoveryTime = Date(timeInterval: resinRecoveryTimeInterval, since: .now)
        } else {
            throw DecodingError.typeMismatch(
                Double.self,
                .init(
                    codingPath: decoder.codingPath,
                    debugDescription: "Unable to parse time interval of resin recovery time"
                )
            )
        }
    }

    private enum CodingKeys: String, CodingKey {
        case maxResin = "max_resin"
        case currentResin = "current_resin"
        case resinRecoveryTime = "resin_recovery_time"
    }
}
