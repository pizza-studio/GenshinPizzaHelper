//
//  Result.swift
//  原神披萨小助手
//
//  Created by 戴藏龙 on 2022/8/8.
//

import Foundation
import GIPizzaKit
import HBMihoyoAPI

#if !os(watchOS)
typealias PlayerDetailsFetchResult = Result<
    Enka.PlayerDetailFetchModel,
    RequestError
>
typealias PlayerDetailResult = Result<
    PlayerDetail,
    PlayerDetail.PlayerDetailError
>
#endif
