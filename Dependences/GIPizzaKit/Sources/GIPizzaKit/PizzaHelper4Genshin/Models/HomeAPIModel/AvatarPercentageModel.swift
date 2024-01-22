//
//  AvatarRateModel.swift
//  GenshinPizzaHepler
//
//  Created by 戴藏龙 on 2022/10/21.
//

import Foundation

public struct AvatarPercentageModel: Codable {
    public struct Avatar: Codable {
        public let charId: Int
        public let percentage: Double?
    }

    public let totalUsers: Int
    public let avatars: [Avatar]
}
