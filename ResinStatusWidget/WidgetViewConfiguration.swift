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
    let weeklyBossesShowingMethod: WeeklyBossesShowingMethod
    var noticeMessage: String?
    
    let isDarkModeOn: Bool
    
//    let colorHandler: ColorHandler
    var backgroundColor: WidgetBackgroundColor
//    { colorHandler.colors }
    var backgroundColors: [Color] { backgroundColor.colors }
    var backgroundIconName: String? { backgroundColor.iconName }
    var backgroundImageName: String? { backgroundColor.imageName }
    
    mutating func addMessage(_ msg: String) {
        self.noticeMessage = msg
    }
    
    
    static let defaultConfig = Self()
    init() {
        showAccountName = true
        showTransformer = true
        expeditionViewConfig = ExpeditionViewConfiguration(noticeExpeditionWhenAllCompleted: true, expeditionShowingMethod: .byNum)
        weeklyBossesShowingMethod = .alwaysShow
        backgroundColor = .purple
        isDarkModeOn = true
    }
    
    init(showAccountName: Bool, showTransformer: Bool, noticeExpeditionWhenAllCompleted: Bool, showExpeditionCompleteTime: Bool, showWeeklyBosses: Bool, noticeMessage: String?) {
        self.showAccountName  = showAccountName
        self.showTransformer = showTransformer
        self.expeditionViewConfig = ExpeditionViewConfiguration(noticeExpeditionWhenAllCompleted: noticeExpeditionWhenAllCompleted, expeditionShowingMethod: .byNum)
        self.weeklyBossesShowingMethod = .disappearAfterCompleted
        backgroundColor = .purple
        isDarkModeOn = true
    }
}

struct ExpeditionViewConfiguration {
    let noticeExpeditionWhenAllCompleted: Bool
    let expeditionShowingMethod: ExpeditionShowingMethod
}

