//
//  AvatarHoldingData.swift
//  GenshinPizzaHepler
//
//  Created by 戴藏龙 on 2022/10/21.
//

import Foundation

public typealias AvatarHoldingReceiveDataFetchModel =
    FetchHomeModel<AvatarHoldingReceiveData>
public typealias AvatarHoldingReceiveDataFetchModelResult =
    FetchHomeModelResult<AvatarHoldingReceiveData>
public typealias PSAServerPostResultModel = FetchHomeModel<String?>
public typealias HuTaoServerPostResultModel = FetchHuTaoModel
public typealias PSAServerPostResultModelResult = FetchHomeModelResult<String?>
public typealias HuTaoServerPostResultModelResult = FetchHuTaoModelResult

public typealias AvatarHoldingReceiveData = AvatarPercentageModel
