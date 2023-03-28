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
    @StateObject
    var gachaViewModel: GachaViewModel = .shared
    var body: some View {
        List {
            Section {
                ForEach(gachaViewModel.filteredGachaItemsWithCount, id: \.0.id) { item, count in
                    VStack {
                        HStack {
                            Text(item.name)
                            Spacer()
                            Text("\(count)")
                        }
                        HStack {
                            Text("\(item.time)")
                            Spacer()
                            Text("\(item.gachaType.localizedDescription())")
                        }
                    }
                }
            }
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                NavigationLink {
                    GetGachaView()
                } label: {
                    Image(systemName: "goforward.plus")
                }
            }
            ToolbarItemGroup(placement: .bottomBar) {

                FilterEditer(filter: $gachaViewModel.filter)
            }
        }
        .environmentObject(gachaViewModel)
        .hideTabBar()
    }
}

private struct FilterEditer: View {
    @Binding var filter: GachaFilter
    var body: some View {
        Menu {
            ForEach(GachaType.allAvaliableGachaType()) { gachaType in
                Button(gachaType.localizedDescription()) {
                    filter.gachaType = gachaType
                }
            }
        } label: {
            Text(filter.gachaType.localizedDescription())

        }
        Spacer()
        Menu {
            ForEach(GachaFilter.Rank.allCases) { rank in
                Button(rank.description) {
                    filter.rank = rank
                }
            }
        } label: {
            Text(filter.rank.description)
        }
    }
}
