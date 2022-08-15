//
//  Widget.swift
//  GenshinPizzaHepler
//
//  Created by 戴藏龙 on 2022/8/11.
//

import Foundation
import SwiftUI

struct WidgetViewConfiguration {
    let showAccountName: Bool
    let showTransformer: Bool
    let expeditionViewConfig: ExpeditionViewConfiguration
    let showWeeklyBosses: Bool
    var noticeMessage: String?
    
//    let colorHandler: ColorHandler
    var backgroundColor: WidgetBackgroundColor
//    { colorHandler.colors }
    var backgroundColors: [Color] { backgroundColor.colors }
    
    mutating func addMessage(_ msg: String) {
        self.noticeMessage = msg
    }
    
    
    static let defaultConfig = Self()
    init() {
        showAccountName = true
        showTransformer = true
        expeditionViewConfig = ExpeditionViewConfiguration(noticeExpeditionWhenAllCompleted: true, expeditionShowingMethod: .byNum)
        showWeeklyBosses = true
        backgroundColor = .purple
    }
    
    init(showAccountName: Bool, showTransformer: Bool, noticeExpeditionWhenAllCompleted: Bool, showExpeditionCompleteTime: Bool, showWeeklyBosses: Bool, noticeMessage: String?) {
        self.showAccountName  = showAccountName
        self.showTransformer = showTransformer
        self.expeditionViewConfig = ExpeditionViewConfiguration(noticeExpeditionWhenAllCompleted: noticeExpeditionWhenAllCompleted, expeditionShowingMethod: .byNum)
        self.showWeeklyBosses = showWeeklyBosses
        backgroundColor = .purple
    }
}

struct ExpeditionViewConfiguration {
    let noticeExpeditionWhenAllCompleted: Bool
    let expeditionShowingMethod: ExpeditionShowingMethod
}

