//
//  File.swift
//
//
//  Created by 戴藏龙 on 2023/10/17.
//

import Foundation

// MARK: - HomeCoinInformation

// MARK: Decodable

extension DailyNote.HomeCoinInformation: Decodable {
    private enum CodingKeys: String, CodingKey {
        case maxHomeCoin = "max_home_coin"
        case currentHomeCoin = "current_home_coin"
        case homeCoinRecoveryTime = "home_coin_recovery_time"
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.maxHomeCoin = try container.decode(Int.self, forKey: .maxHomeCoin)
        self.currentHomeCoin = try container.decode(Int.self, forKey: .currentHomeCoin)
        if let recoveryTimeInterval = TimeInterval(try container.decode(String.self, forKey: .homeCoinRecoveryTime)) {
            self.fullTime = Date(timeIntervalSinceNow: recoveryTimeInterval)
        } else {
            throw DecodingError.typeMismatch(
                TimeInterval.self,
                .init(
                    codingPath: decoder.codingPath,
                    debugDescription: "Unable to parse home coint recovery time interval"
                )
            )
        }
    }
}
