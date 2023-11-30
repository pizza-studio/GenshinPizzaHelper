//
//  File.swift
//
//
//  Created by 戴藏龙 on 2023/10/17.
//

import Foundation

// MARK: - TransformerInformation

// MARK: Decodable

extension GeneralDailyNote.TransformerInformation: Decodable {
    public init(from decoder: Decoder) throws {
        let basicContainer = try decoder.container(keyedBy: BasicCodingKeys.self)
        let container = try basicContainer.nestedContainer(keyedBy: CodingKeys.self, forKey: .transformer)
        self.obtained = try container.decode(Bool.self, forKey: .obtained)

        let recoveryTimeContainer = try container.nestedContainer(
            keyedBy: RecoveryTimeCodingKeys.self,
            forKey: .recoveryTime
        )
        let reached = try recoveryTimeContainer.decode(Bool.self, forKey: .reached)
        if reached {
            self.recoveryTime = .now
        } else {
            let day = try recoveryTimeContainer.decode(Int.self, forKey: .day)
            let minute = try recoveryTimeContainer.decode(Int.self, forKey: .minute)
            let hour = try recoveryTimeContainer.decode(Int.self, forKey: .hour)
            let second = try recoveryTimeContainer.decode(Int.self, forKey: .second)
            let timeInterval = TimeInterval() + Double(day * 24 * 60 * 60) + Double(minute * 60) +
                Double(hour * 60 * 60) + Double(second)
            self.recoveryTime = Date(timeIntervalSinceNow: timeInterval)
        }
    }

    private enum BasicCodingKeys: String, CodingKey {
        case transformer
    }

    private enum CodingKeys: String, CodingKey {
        case obtained
        case recoveryTime = "recovery_time"
    }

    private enum RecoveryTimeCodingKeys: String, CodingKey {
        case day = "Day"
        case minute = "Minute"
        case second = "Second"
        case hour = "Hour"
        case reached
    }
}
