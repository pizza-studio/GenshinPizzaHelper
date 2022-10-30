//
//  TeamUtilizationData.swift
//  GenshinPizzaHelper
//
//  Created by 戴藏龙 on 2022/10/30.
//

import Foundation

struct TeamUtilizationData: Codable {
    let totalUsers: Int
    let teams: [Avatar]

    struct Avatar: Codable {
        let team: [Int]
        let percentage: Double
    }
}

typealias TeamUtilizationDataFetchModelResult = FetchHomeModelResult<TeamUtilizationData>
typealias TeamUtilizationDataFetchModel = FetchHomeModel<TeamUtilizationData>
