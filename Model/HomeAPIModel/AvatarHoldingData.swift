//
//  AvatarHoldingData.swift
//  GenshinPizzaHepler
//
//  Created by 戴藏龙 on 2022/10/21.
//

import Foundation

typealias AvatarHoldingReceiveDataFetchModel =
    FetchHomeModel<AvatarHoldingReceiveData>
typealias AvatarHoldingReceiveDataFetchModelResult =
    FetchHomeModelResult<AvatarHoldingReceiveData>
typealias PSAServerPostResultModel = FetchHomeModel<String?>
typealias HuTaoServerPostResultModel = FetchHuTaoModel
typealias PSAServerPostResultModelResult = FetchHomeModelResult<String?>
typealias HuTaoServerPostResultModelResult = FetchHuTaoModelResult

typealias AvatarHoldingReceiveData = AvatarPercentageModel
