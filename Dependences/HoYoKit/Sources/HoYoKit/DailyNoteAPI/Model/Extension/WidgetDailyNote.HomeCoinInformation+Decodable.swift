//
//  File.swift
//
//
//  Created by 戴藏龙 on 2023/10/17.
//

import Foundation

extension WidgetDailyNote.HomeCoinInformation: Decodable {
    private enum CodingKeys: String, CodingKey {
        case maxHomeCoin = "max_home_coin"
        case currentHomeCoin = "current_home_coin"
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.maxHomeCoin = try container.decode(Int.self, forKey: .maxHomeCoin)
        self.currentHomeCoin = try container.decode(Int.self, forKey: .currentHomeCoin)
        self.fullTime = Date(timeIntervalSinceNow: TimeInterval((maxHomeCoin - currentHomeCoin) * 120))
    }
}
