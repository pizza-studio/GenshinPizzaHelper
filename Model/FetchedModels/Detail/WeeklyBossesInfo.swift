//
//  WeeklyBossesInfo.swift
//  GenshinPizzaHepler
//
//  Created by 戴藏龙 on 2022/8/7.
//

import Foundation

struct WeeklyBossesInfo {
    let remainResinDiscountNum: Int
    let resinDiscountNumLimit: Int
    var hasUsedResinDiscountNum: Int { resinDiscountNumLimit - remainResinDiscountNum }
    
    var isComplete: Bool { remainResinDiscountNum == 0 }
}
