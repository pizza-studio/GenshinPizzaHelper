//
//  File.swift
//  GenshinPizzaHepler
//
//  Created by 戴藏龙 on 2022/10/21.
//

import Foundation
import HBMihoyoAPI

// MARK: - FetchHomeModel

struct FetchHomeModel<T: Codable>: Codable {
    let retCode: Int
    let message: String
    let data: T
}

// MARK: - FetchHuTaoModel

struct FetchHuTaoModel: Codable {
    let retcode: Int
    let message: String
}

typealias FetchHomeModelResult<T: Codable> = Result<
    FetchHomeModel<T>,
    PSAServerError
>

typealias FetchHuTaoModelResult = Result<
    FetchHuTaoModel,
    PSAServerError
>
