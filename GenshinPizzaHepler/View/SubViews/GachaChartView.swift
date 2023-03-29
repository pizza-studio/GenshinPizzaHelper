//
//  GachaChartView.swift
//  GenshinPizzaHepler
//
//  Created by 戴藏龙 on 2023/3/29.
//

import Charts
import SwiftUI

// MARK: - GachaChartView

@available(iOS 16.0, *)
struct GachaChartView: View {
    @StateObject
    var gachaViewModel: GachaViewModel = .shared

    var body: some View {
        List {
            Section {
                GachaItemChart(
                    items: gachaViewModel
                        .filteredGachaItemsWithCount
                )
            } header: {
                HStack {
                    Text(
                        "\(gachaViewModel.filter.gachaType.localizedDescription())五星祈愿抽数"
                    )
                    Spacer()
                    Button("切换卡池") {
                        withAnimation {
                            switch gachaViewModel.filter.gachaType {
                            case .character: gachaViewModel.filter
                                .gachaType = .weapon
                            case .weapon: gachaViewModel.filter
                                .gachaType = .standard
                            case .standard: gachaViewModel.filter
                                .gachaType = .character
                            default: gachaViewModel.filter
                                .gachaType = .character
                            }
                        }
                    }
                    .font(.caption)
                }
            }
            Section {
                GachaTimeChart(
                    type: gachaViewModel.filter.gachaType,
                    items: gachaViewModel.gachaItems
                )
            } header: {
                Text("总抽数分布")
            }
        }
    }
}

// MARK: - GachaItemChart

@available(iOS 16.0, *)
private struct GachaItemChart: View {
    let items: [(GachaItem, count: Int)]

    var fiveStarItems: [(GachaItem, count: Int)] {
        items.filter { $0.0.rankType == .five }
    }

    var body: some View {
        Chart {
            ForEach(fiveStarItems, id: \.0.id) { item in
                BarMark(
                    //                    x: .value("角色", item.0.localizedName),
//                    y: .value("抽数", item.count)
                    x: .value("抽数", item.count),
                    y: .value("角色", item.0.localizedName)
                )
                .annotation(position: .trailing) {
                    Text("\(item.count)").foregroundColor(.gray).font(.caption)
                }
                .foregroundStyle(by: .value("抽数", item.0.id))
            }
            RuleMark(x: .value(
                "平均",
                fiveStarItems.map { $0.count }
                    .reduce(0) { $0 + $1 } / fiveStarItems.count
            ))
            .foregroundStyle(.gray)
            .lineStyle(StrokeStyle(lineWidth: 2, dash: [5]))
            .annotation(alignment: .topLeading) {
                Text(
                    "平均抽数：\(fiveStarItems.map { $0.count }.reduce(0) { $0 + $1 } / fiveStarItems.count)"
                )
                .font(.caption).foregroundColor(.gray)
            }
        }
        .chartYAxis(content: {
            AxisMarks { value in
                AxisValueLabel(content: {
                    if let name = value.as(String.self),
                       let item = fiveStarItems
                       .first(where: { $0.0.name == name })?.0 {
                        HStack {
                            EnkaWebIcon(
                                iconString: item.iconImageName
                            )
                            .scaleEffect(item._itemType == .weapon ? 0.9 : 1)
                            .background(item.backgroundImageName())
                            .frame(width: 30, height: 30)
                            .clipShape(Circle())
                            Text(name)
                        }

                    } else {
                        EmptyView()
                    }
                })
            }
        })
        .frame(height: CGFloat(fiveStarItems.count * 65))
        .chartForegroundStyleScale(range: colors)
        .chartLegend(.hidden)
        .padding(.vertical)
    }

    var colors: [Color] {
        fiveStarItems.map { _, count in
            switch count {
            case 0 ..< 62:
                return .green
            case 62 ..< 80:
                return .yellow
            default:
                return .red
            }
        }
    }
}

// MARK: - GachaTimeChart

@available(iOS 16.0, *)
private struct GachaTimeChart: View {
    let type: GachaType
    let items: [GachaItem]

    let formatter: DateFormatter = {
        let fmt = DateFormatter()
        fmt.dateStyle = .short
        fmt.timeStyle = .none
        return fmt
    }()

    var data: [GachaTypeDateCount] {
        let dates = Set<Date>.init(items.map { $0.time })
        let types = Set<GachaType>.init(items.map { $0.gachaType })
        return types.flatMap { type in
            dates.map { date in
                GachaTypeDateCount(
                    date: date,
                    count: items
                        .filter { ($0.time <= date) && ($0.gachaType == type) }
                        .count,
                    type: type
                )
            }.sorted(by: { $0.date > $1.date })
        }
    }

    var dayDiffOfminMax: Int {
        let times = items.map { $0.time }
        let min = times.min()!
        let max = times.max()!

        let calendar = Calendar.current

        let components = calendar.dateComponents([.day], from: min, to: max)
        return components.day!
    }

    var body: some View {
        Chart(data) {
            LineMark(
                x: .value("日期", $0.date),
                y: .value("抽数", $0.count)
            )
            .foregroundStyle(by: .value("祈愿类型", $0.type.localizedDescription()))
        }
        .chartYAxis(content: {
            AxisMarks(position: .leading)
        })
        .padding(.vertical)
        .frame(height: 600)
        .chartForegroundStyleScale([
            GachaType.standard.localizedDescription(): .green,
            GachaType.character.localizedDescription(): .blue,
            GachaType.weapon.localizedDescription(): .yellow,
        ])
//        ScrollView(.horizontal) {

//            .frame(width: CGFloat(dayDiffOfminMax) * 5, height: CGFloat(items.filter( {$0.gachaType == .character}).count))
//        }
    }
}
