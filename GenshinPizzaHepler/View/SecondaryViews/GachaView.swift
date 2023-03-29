//
//  GachaView.swift
//  GenshinPizzaHepler
//
//  Created by 戴藏龙 on 2023/3/28.
//

import HBMihoyoAPI
import SwiftUI
import CoreData
import Charts

struct GachaView: View {
    @EnvironmentObject
    var viewModel: ViewModel
    @StateObject
    var gachaViewModel: GachaViewModel = .shared

    @State
    var showTime: Bool = false

    var body: some View {
        List {
            if #available(iOS 16.0, *) {
                GachaChart(items: gachaViewModel.filteredGachaItemsWithCount)
            }
            Section {
                ForEach(gachaViewModel.filteredGachaItemsWithCount, id: \.0.id) { item, count in
                    VStack(spacing: 1) {
                        GachaItemBar(item: item, count: count, showTime: showTime, showingType: gachaViewModel.filter.rank)
                    }
                }
            } header: {
                Text("已垫\(gachaViewModel.sortedAndFilteredGachaItem.firstIndex(where: { $0.rankType == .five }) ?? gachaViewModel.sortedAndFilteredGachaItem.count)抽")
            }
            #if DEBUG
            Section {
                Button("delete all records (DEBUG ONLY)") {
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
        Button {
            withAnimation {
                showTime.toggle()
            }
        } label: {
            Image(systemName: showTime ? "calendar.circle.fill" : "calendar.circle")
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
    }
}

private struct GachaItemBar: View {
    let item: GachaItem
    let count: Int
    let showTime: Bool
    let showingType: GachaFilter.Rank
    var width: CGFloat { showingType == .five ? 40 : 30 }
    var body: some View {
        HStack {
            Label {
                Text(item.localizedName)
            } icon: {
                EnkaWebIcon(
                    iconString: item.iconImageName
                )
                .scaleEffect(item._itemType == .weapon ? 0.9 : 1)
                .background(
                    AnyView(item.backgroundImageName())
                )
                .frame(width: width, height: width)
                .clipShape(Circle())
            }
            Spacer()
            VStack(alignment: .trailing, spacing: 1) {
                if (count != 1) || (item.rankType != .three) {
                    Text("\(count)")
                        .font(!showTime ? .body : .caption)
                }
                if showTime {
                    Text(item.formattedTime)
                        .font(.caption2)
                        .foregroundColor(.gray)
                }
            }

        }
    }
}

@available(iOS 16.0, *)
private struct GachaChart: View {
    let items: [(GachaItem, count: Int)]
    var body: some View {
        Chart {
            ForEach(items.filter({ $0.0.rankType == .five }), id: \.0.id) { item in
                BarMark(
                    x: .value("角色", item.0.name),
                    y: .value("抽数", item.count)
                )
            }
        }
    }
}
