//
//  UtilizationData.swift
//  GenshinPizzaHepler
//
//  Created by 戴藏龙 on 2022/10/21.
//

import Foundation

typealias UltilizationDataFetchModel = FetchHomeModel<UltilizationData>
typealias UltilizationDataFetchModelResult = FetchHomeModelResult<UltilizationData>

struct UltilizationData {
    let totleUsers: String
    let avatars: [Avatar]

    struct Avatar {
        let charId: Int
        let ultilization: Double?
    }
}

