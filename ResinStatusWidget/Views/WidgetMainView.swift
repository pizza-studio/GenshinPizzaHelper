//
//  WidgetMainView.swift
//  GenshinPizzaHepler
//
//  Created by 戴藏龙 on 2022/8/7.
//

import SwiftUI
import WidgetKit

struct WidgetMainView: View {
    @Environment(\.widgetFamily) var family: WidgetFamily
    let userData: UserData
    let viewConfig: WidgetViewConfiguration
    
    var body: some View {
        switch family {
        case .systemSmall:
            MainInfo(userData: userData, viewConfig: viewConfig)
        case .systemMedium:
            MainInfoWithDetail(userData: userData, viewConfig: viewConfig)
        default:
            MainInfoWithDetail(userData: userData, viewConfig: viewConfig)
        }
    }
}

