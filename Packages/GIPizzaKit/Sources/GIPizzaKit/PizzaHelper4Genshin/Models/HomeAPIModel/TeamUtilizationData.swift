//
//  TeamUtilizationData.swift
//  GenshinPizzaHelper
//
//  Created by 戴藏龙 on 2022/10/30.
//

import Foundation

// MARK: - TeamUtilizationData

public struct TeamUtilizationData: Codable {
    public struct Team: Codable {
        public let team: [Int]
        public let percentage: Double
    }

    public let totalUsers: Int
    public let teams: [Team]
    public let teamsFH: [Team]
    public let teamsSH: [Team]
}

public typealias TeamUtilizationDataFetchModelResult =
    FetchHomeModelResult<TeamUtilizationData>
public typealias TeamUtilizationDataFetchModel = FetchHomeModel<TeamUtilizationData>
