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
    var userData: UserData
    let viewConfig: WidgetViewConfiguration
    let accountName: String?
    
    var body: some View {
        switch family {
        case .systemSmall:
            MainInfo(userData: userData, viewConfig: viewConfig, accountName: accountName)
        case .systemMedium:
            MainInfoWithDetail(userData: userData, viewConfig: viewConfig, accountName: accountName)
        default:
            MainInfoWithDetail(userData: userData, viewConfig: viewConfig, accountName: accountName)
        }
    }
}

