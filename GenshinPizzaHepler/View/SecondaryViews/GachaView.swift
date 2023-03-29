//
//  GachaView.swift
//  GenshinPizzaHepler
//
//  Created by 戴藏龙 on 2023/3/28.
//

import HBMihoyoAPI
import SwiftUI
import CoreData

struct GachaView: View {
    @EnvironmentObject
    var viewModel: ViewModel
    @StateObject
    var gachaViewModel: GachaViewModel = .shared

    @State
    var showTime: Bool = false

    var body: some View {
        List {
            #if DEBUG
            Section {
                Button("delete all records") {
                    let context = gachaViewModel.manager.container.viewContext
                    let fetchRequest = GachaItemMO.fetchRequest()
                    do {
                        let models = try context.fetch(fetchRequest)
                        models.forEach { item in
                            context.delete(item)
                        }
                        try context.save()
                    } catch {
                        print(error)
                    }
                    gachaViewModel.refetchGachaItems()
                }
            }
            #endif
            Section {
                ForEach(gachaViewModel.filteredGachaItemsWithCount, id: \.0.id) { item, count in
                    VStack {
                        HStack {
                            Text(item.name)
                            Spacer()
                            if (count != 1) || (item.rankType == .five) {
                                Text("\(count)")
                            }
                        }
                        HStack {
                            Text("\(item.time)")
                            Spacer()
                            Text("\(item.gachaType.localizedDescription())")
                        }
                        Text(item.id)
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
                FilterEditer(filter: $gachaViewModel.filter, showTime: $showTime)
            }
            ToolbarItem(placement: .principal) {
                Menu {
                    ForEach(gachaViewModel.allAvaliableAccountUID(), id: \.self) { uid in
                        Group {
                            if let name: String = viewModel.accounts
                                .first(where: { $0.config.uid == uid })?.config.name {
                                Button(name) {
                                    self.gachaViewModel.filter.uid = uid
                                }
                            } else {
                                Button(uid) {
                                    self.gachaViewModel.filter.uid = uid
                                }
                            }
                        }
                    }
                } label: {
                    HStack {
                        Image(systemName: "arrow.left.arrow.right.circle")
                        if let uid: String = self.gachaViewModel.filter.uid {
                            if let name: String = viewModel.accounts
                                .first(where: { $0.config.uid == uid })?.config.name {
                                Text(name)
                            } else {
                                Text(uid)
                            }
                        } else {
                            Text("请点击右上角获取抽卡记录")
                        }
                    }
                }
                .disabled(gachaViewModel.allAvaliableAccountUID().isEmpty)
            }
        }
        .environmentObject(gachaViewModel)
        .hideTabBar()
    }
}

private struct FilterEditer: View {
    @Binding var filter: GachaFilter
    @Binding var showTime: Bool
    var body: some View {
        Menu {
            ForEach(GachaType.allAvaliableGachaType()) { gachaType in
                Button(gachaType.localizedDescription()) {
                    withAnimation {
                        filter.gachaType = gachaType
                    }
                }
            }
        } label: {
            Text(filter.gachaType.localizedDescription())

        }
        Spacer()
        Menu {
            ForEach(GachaFilter.Rank.allCases) { rank in
                Button(rank.description) {
                    withAnimation {
                        filter.rank = rank
                    }
                }
            }
        } label: {
            Text(filter.rank.description)
        }
        Spacer()
        Button(showTime ? "显示时间" : "隐藏时间") {
            withAnimation {
                showTime.toggle()
            }
        }
    }
}
