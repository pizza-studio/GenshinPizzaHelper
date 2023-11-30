//
//  File.swift
//
//
//  Created by 戴藏龙 on 2023/10/17.
//

import Foundation

extension GeneralDailyNote.WeeklyBossesInformation: Decodable {
    private enum CodingKeys: String, CodingKey {
        case totalResinDiscount = "resin_discount_num_limit"
        case remainResinDiscount = "remain_resin_discount_num"
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.totalResinDiscount = try container.decode(Int.self, forKey: .totalResinDiscount)
        self.remainResinDiscount = try container.decode(Int.self, forKey: .remainResinDiscount)
    }
}
