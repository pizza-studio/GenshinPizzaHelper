//
//  GachaView.swift
//  GenshinPizzaHepler
//
//  Created by 戴藏龙 on 2023/3/28.
//

import Charts
import CoreData
import HBMihoyoAPI
import SwiftUI

// MARK: - GachaView

struct GachaView: View {
    @EnvironmentObject
    var viewModel: ViewModel
    @StateObject
    var gachaViewModel: GachaViewModel = .shared

    @State
    var showTime: Bool = false

    var body: some View {
        List {
            if !gachaViewModel.filteredGachaItemsWithCount.isEmpty {
                if #available(iOS 16.0, *) {
                    Section {
                        GachaChart(
                            items: gachaViewModel
                                .filteredGachaItemsWithCount
                        )
                        NavigationLink {
                            GachaChartView()
                                .environmentObject(gachaViewModel)
                        } label: {
                            Label(
                                "更多数据",
                                systemImage: "chart.bar.doc.horizontal"
                            )
                        }
                    }
                }

                Section {
                    Text(
                        "当前已垫：\(gachaViewModel.sortedAndFilteredGachaItem.firstIndex(where: { $0.rankType == .five }) ?? gachaViewModel.sortedAndFilteredGachaItem.count)抽"
                    )
                }
            }

            Section {
                ForEach(
                    gachaViewModel.filteredGachaItemsWithCount,
                    id: \.0.id
                ) { item, count in
                    VStack(spacing: 1) {
                        GachaItemBar(
                            item: item,
                            count: count,
                            showTime: showTime,
                            showingType: gachaViewModel.filter.rank
                        )
                    }
                }
            } header: {
                Text("抽取记录")
            }
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                GetGachaNavigationMenu()
            }
            ToolbarItemGroup(placement: .bottomBar) {
                FilterEditer(
                    filter: $gachaViewModel.filter,
                    showTime: $showTime
                )
            }
            ToolbarItem(placement: .principal) {
                Menu {
                    ForEach(
                        gachaViewModel.allAvaliableAccountUID,
                        id: \.self
                    ) { uid in
                        Group {
                            if let name: String = viewModel.accounts
                                .first(where: { $0.config.uid == uid })?.config
                                .name {
                                Button(name) {
                                    gachaViewModel.filter.uid = uid
                                }
                            } else {
                                Button(uid) {
                                    gachaViewModel.filter.uid = uid
                                }
                            }
                        }
                    }
                } label: {
                    HStack {
                        Image(systemName: "arrow.left.arrow.right.circle")
                        if let uid: String = gachaViewModel.filter.uid {
                            if let name: String = viewModel.accounts
                                .first(where: { $0.config.uid == uid })?.config
                                .name {
                                Text(name)
                            } else {
                                Text(uid)
                            }
                        } else {
                            Text("请点击右上角获取抽卡记录")
                        }
                    }
                }
                .disabled(gachaViewModel.allAvaliableAccountUID.isEmpty)
            }
        }
        .environmentObject(gachaViewModel)
        .hideTabBar()
    }
}

// MARK: - FilterEditer

private struct FilterEditer: View {
    @Binding
    var filter: GachaFilter
    @Binding
    var showTime: Bool

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
            Image(
                systemName: showTime ? "calendar.circle.fill" :
                    "calendar.circle"
            )
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

// MARK: - GachaItemBar

private struct GachaItemBar: View {
    let item: GachaItem
    let count: Int
    let showTime: Bool
    let showingType: GachaFilter.Rank

    var width: CGFloat { showingType == .five ? 35 : 30 }
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

// MARK: - GachaChart

@available(iOS 16.0, *)
private struct GachaChart: View {
    let items: [(GachaItem, count: Int)]

    var fiveStarItems: [(GachaItem, count: Int)] {
        items.filter { $0.0.rankType == .five }
    }

    var body: some View {
        ScrollView(.horizontal) {
            Chart {
                ForEach(fiveStarItems, id: \.0.id) { item in
                    BarMark(
                        x: .value("角色", item.0.id),
                        y: .value("抽数", item.count)
                    )
                    .annotation(position: .top) {
                        Text("\(item.count)").foregroundColor(.gray)
                            .font(.caption)
                    }
                    .foregroundStyle(by: .value("抽数", item.0.id))
                }
                if !fiveStarItems.isEmpty {
                    RuleMark(y: .value(
                        "平均",
                        fiveStarItems.map { $0.count }
                            .reduce(0) { $0 + $1 } / max(fiveStarItems.count, 1)
                    ))
                    .foregroundStyle(.gray)
                    .lineStyle(StrokeStyle(lineWidth: 2, dash: [5]))
                }
            }
            .chartXAxis(content: {
                AxisMarks { value in
                    AxisValueLabel(content: {
                        if let id = value.as(String.self),
                           let item = fiveStarItems
                           .first(where: { $0.0.id == id })?.0 {
                            VStack {
                                EnkaWebIcon(
                                    iconString: item.iconImageName
                                )
                                .scaleEffect(
                                    item
                                        ._itemType == .weapon ? 0.9 : 1
                                )
                                .background(item.backgroundImageName())
                                .frame(width: 30, height: 30)
                                .clipShape(Circle())
                            }

                        } else {
                            EmptyView()
                        }
                    })
                }
            })
            .chartLegend(position: .top)
            .chartYAxis(content: {
                AxisMarks(position: .leading)
            })
            .chartForegroundStyleScale(range: colors)
            .chartLegend(.hidden)
            .frame(width: CGFloat(fiveStarItems.count * 50))
            .padding(.top)
            .padding(.bottom, 5)
        }
    }

    var colors: [Color] {
        fiveStarItems.map { _, count in
            switch count {
            case 0 ..< 60:
                return .green
            case 60 ..< 80:
                return .yellow
            default:
                return .red
            }
        }
    }
}

// MARK: - GetGachaNavigationMenu

private struct GetGachaNavigationMenu: View {
    // MARK: Internal

    var body: some View {
        Menu {
            Button("通过API获取\n（仅国服，优先选用）") {
                showView1.toggle()
            }
            #if canImport(GachaMIMTServer)
            Button("通过抓包或URL获取\n（所有服务器）") {
                showView2.toggle()
            }
            #endif
        } label: {
            Image(systemName: "goforward.plus")
        }
        .background(
            Group {
                NavigationLink(
                    destination: GetGachaView(),
                    isActive: $showView1
                ) {
                    EmptyView()
                }
                #if canImport(GachaMIMTServer)
                NavigationLink(
                    destination: MIMTGetGachaView(),
                    isActive: $showView2
                ) {
                    EmptyView()
                }
                #endif
            }
        )
    }

    // MARK: Private

    @State
    private var showView1 = false
    @State
    private var showView2 = false
}
