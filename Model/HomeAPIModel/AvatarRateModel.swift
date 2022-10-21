//
//  AvatarRateModel.swift
//  GenshinPizzaHepler
//
//  Created by 戴藏龙 on 2022/10/21.
//

import Foundation

struct AvatarPercentageModel {
    let totleUsers: String
    let avatars: [Avatar]

    struct Avatar {
        let charId: Int
        let percentage: Double?
    }
}
