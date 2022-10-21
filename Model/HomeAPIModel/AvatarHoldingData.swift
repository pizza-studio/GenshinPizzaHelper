//
//  AvatarHoldingData.swift
//  GenshinPizzaHepler
//
//  Created by 戴藏龙 on 2022/10/21.
//

import Foundation

typealias AvatarHoldingReceiveDataFetchModel = FetchHomeModel<AvatarHoldingReceiveData>
typealias AvatarHoldingReceiveDataFetchModelResult = FetchHomeModelResult<AvatarHoldingReceiveData>

struct AvatarHoldingReceiveData {
    let totleUsers: String
    let avatars: [Avatar]

    struct Avatar {
        let charId: Int
        let holdingRate: Double?
    }
}
