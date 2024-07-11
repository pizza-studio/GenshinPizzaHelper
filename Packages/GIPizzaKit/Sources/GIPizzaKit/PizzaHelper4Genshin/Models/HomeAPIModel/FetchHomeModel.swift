//
//  File.swift
//  GenshinPizzaHepler
//
//  Created by 戴藏龙 on 2022/10/21.
//

import Foundation
import HBMihoyoAPI

// MARK: - FetchHomeModel

public struct FetchHomeModel<T: Codable>: Codable {
    public let retCode: Int
    public let message: String
    public let data: T
}

// MARK: - FetchHuTaoModel

public struct FetchHuTaoModel: Codable {
    public let retcode: Int
    public let message: String
}

public typealias FetchHomeModelResult<T: Codable> = Result<
    FetchHomeModel<T>,
    PSAServerError
>

public typealias FetchHuTaoModelResult = Result<
    FetchHuTaoModel,
    PSAServerError
>
