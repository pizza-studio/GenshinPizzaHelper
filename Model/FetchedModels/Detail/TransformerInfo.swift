//
//  TransformerDetail.swift
//  GenshinPizzaHepler
//
//  Created by 戴藏龙 on 2022/8/7.
//

import Foundation

struct TransformerInfo {
    let obtained: Bool
    let recoveryTime: RecoveryTime
    
    var isComplete: Bool { recoveryTime.isComplete }
    
    var percentage: Double { Double(recoveryTime.second / 604800) }
    
    init(_ transformerData: TransformerData) {
        self.obtained = transformerData.obtained
        self.recoveryTime = RecoveryTime(transformerData.recoveryTime.day,
                                         transformerData.recoveryTime.hour,
                                         transformerData.recoveryTime.minute,
                                         transformerData.recoveryTime.second)
    }
}
