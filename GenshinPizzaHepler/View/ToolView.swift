//
//  ToolView.swift
//  GenshinPizzaHepler
//
//  Created by 戴藏龙 on 2023/12/3.
//

import Foundation
import HoYoKit
import SwiftUI

struct ToolView: View {
    var body: some View {
        NavigationView {
            List {
                Section {
                    NavigationLink {
                        GachaView()
                    } label: {
                        Label {
                            Text("祈愿分析")
                                .foregroundColor(.primary)
                        } icon: {
                            Image("UI_MarkPoint_SummerTimeV2_Dungeon_04").resizable()
                                .scaledToFit()
                        }
                    }
                    NavigationLink {
                        AbyssDataCollectionView()
                    } label: {
                        Label {
                            Text("深渊统计榜单")
                                .foregroundColor(.primary)
                        } icon: {
                            Image("UI_MarkTower_EffigyChallenge_01").resizable()
                                .scaledToFit()
                        }
                    }
                }
                ThirdPartyToolsView()
            }
            .navigationTitle("app.tools.title")
        }
        .alwaysShowSideBar()
    }
}
