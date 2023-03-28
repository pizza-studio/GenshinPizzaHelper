//
//  GachaView.swift
//  GenshinPizzaHepler
//
//  Created by 戴藏龙 on 2023/3/28.
//

import HBMihoyoAPI
import SwiftUI

struct GachaView: View {
    @EnvironmentObject
    var viewModel: ViewModel
    let gachaViewModel: GachaViewModel = .shared
    var body: some View {
        List {
            Section {
                NavigationLink("Get Gacha View") {
                    GetGachaView()
                }
            }
            Section {
                ForEach(gachaViewModel.gachaItems) { item in
                    VStack {
                        HStack {
                            Text(item.name)
                            Spacer()
                            Text(item.gachaType.localizedDescription())
                        }
                        Text(item.id)
                    }
                }
            }
//            TestGenGachaKey()
        }
        .environmentObject(gachaViewModel)
    }
}
