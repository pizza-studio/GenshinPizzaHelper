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
    
    var body: some View {
        switch family {
        case .systemSmall:
            MainInfo(userData: userData)
        case .systemMedium:
            MainInfoWithDetail(userData: userData)
        default:
            MainInfoWithDetail(userData: userData)
        }
    }
}

