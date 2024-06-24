//
//  GachaChartView.swift
//  GenshinPizzaHepler
//
//  Created by 戴藏龙 on 2023/3/29.
//

import Charts
import Defaults
import DefaultsKeys
import SFSafeSymbols
import SwiftUI

// MARK: - GachaChartView

@available(iOS 16.0, *)
struct GachaChartView: View {
    // MARK: Internal

    @EnvironmentObject
    var gachaViewModel: GachaViewModel

    @FetchRequest(sortDescriptors: [.init(
        keyPath: \AccountConfiguration.priority,
        ascending: true
    )])
    var accounts: FetchedResults<AccountConfiguration>

    @ViewBuilder
    var listHeader: some View {
        HStack {
            Text(
                gachaViewModel.filter.gachaType.localizedDescription()
            )
            Spacer()
            Button(
                "app.gacha.chart.switch.button:\(gachaViewModel.filter.gachaType.nextOne().localizedDescription())"
            ) {
                withAnimation {
                    gachaViewModel.filter.gachaType = gachaViewModel
                        .filter.gachaType.nextOne()
                }
            }
            .font(.caption)
        }
        .textCase(.none)
    }

    var body: some View {
        List {
            Section {
                GachaItemChart(items: gachaViewModel.filteredGachaItemsWithCount)
                    .environmentObject(gachaViewModel)
            } header: {
                listHeader
            }
        }
        .toolbar {
            ToolbarItem(placement: .principal) {
                Menu {
                    ForEach(
                        gachaViewModel.allAvaliableAccountUID,
                        id: \.self
                    ) { uid in
                        Group {
                            Button(convertUIDtoNameTitleString(uid: uid)) {
                                gachaViewModel.filter.uid = uid
                            }
                        }
                    }
                } label: {
                    HStack {
                        Image(systemSymbol: .arrowLeftArrowRightCircle)
                        if let uid: String = gachaViewModel.filter.uid {
                            Text(convertUIDtoNameTitleString(uid: uid))
                        } else {
                            Text("app.gacha.get.button")
                        }
                    }
                }
                .disabled(gachaViewModel.allAvaliableAccountUID.isEmpty)
            }
        }
    }

    // MARK: Private

    private func convertUIDtoNameTitleString(uid: String) -> String {
        accounts.first(where: { $0.uid == uid })?.name ?? uid
    }
}

extension GachaType {
    fileprivate func nextOne() -> Self {
        switch self {
        case .character:
            return .weapon
        case .weapon:
            return .standard
        case .standard:
            return .chronicled
        case .chronicled:
            return .character
        default:
            return .character
        }
    }
}

// MARK: - GachaItemChart

@available(iOS 16.0, *)
private struct GachaItemChart: View {
    // MARK: Internal

    let items: [(GachaItem, count: Int)]

    var fiveStarItems: [(GachaItem, count: Int)] {
        items.filter { $0.0.rankType == .five }
    }

    var averagePullsCount: Int {
        fiveStarItems.map(\.count).reduce(0, +) / max(fiveStarItems.count, 1)
    }

    var body: some View {
//        subChart(items: fiveStarItems.chunked(into: 60)[1])
        VStack(spacing: -12) {
            ForEach(fiveStarItems.chunked(into: 60), id: \.first!.0.id) { chunked in
                let isFirst = fiveStarItems.first!.0.id == chunked.first!.0.id
                let isLast = fiveStarItems.last!.0.id == chunked.last!.0.id
                if isFirst {
                    subChart(givenItems: chunked, isFirst: isFirst, isLast: isLast).padding(.top)
                } else {
                    subChart(givenItems: chunked, isFirst: isFirst, isLast: isLast)
                }
            }
        }
    }

    var lose5050IconStr: String {
        useGuestGachaEvaluator ? "Pom-Pom_Sticker_32" : "UI_EmotionIcon5"
    }

    func matchedItems(with value: String) -> [GachaItem] {
        items.map(\.0).filter { $0.id == value }
    }

    func colors(items: [(GachaItem, count: Int)]) -> [Color] {
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

    // MARK: Private

    private typealias ItemPair = (GachaItem, count: Int)

    @Default(.useGuestGachaEvaluator)
    private var useGuestGachaEvaluator: Bool

    @ViewBuilder
    private func subChart(
        givenItems: [ItemPair],
        isFirst: Bool,
        isLast: Bool
    )
        -> some View {
        Chart {
            ForEach(items, id: \.0.id) { item in
                drawChartContent(for: item)
            }
            if !fiveStarItems.isEmpty {
                RuleMark(x: .value("平均", averagePullsCount))
                    .foregroundStyle(.gray)
                    .lineStyle(StrokeStyle(lineWidth: 2, dash: [5]))
                    .annotation(alignment: .topLeading) {
                        if isFirst {
                            Text(
                                verbatim:
                                "app.gacha.avg.pull".localized
                                    + averagePullsCount.description
                            )
                            .font(.caption).foregroundColor(.gray)
                        }
                    }
            }
        }
        .chartYAxis {
            axisContentY()
        }
        .chartXAxis {
            axisContentX(isLast: isLast)
        }
        .chartXScale(domain: 0 ... 110)
        .frame(height: CGFloat(items.count * 65))
        .chartForegroundStyleScale(range: colors(items: items))
        .chartLegend(.hidden)
    }

    @ChartContentBuilder
    private func drawChartContent(for item: ItemPair) -> some ChartContent {
        BarMark(
            x: .value("sys.pull", item.count),
            y: .value("角色", item.0.id),
            width: 20
        )
        .annotation(position: .trailing) {
            HStack(spacing: 3) {
                let frame: CGFloat = 35
                Text("\(item.count)").foregroundColor(.gray).font(.caption)
                if item.0.isLose5050() {
                    Image(lose5050IconStr).resizable().scaledToFit()
                        .frame(width: frame, height: frame)
                        .offset(y: -5)
                } else {
                    EmptyView()
                }
            }
        }
        .foregroundStyle(by: .value("sys.pull", item.0.id))
    }

    @AxisContentBuilder
    private func axisContentY() -> some AxisContent {
        AxisMarks(preset: .aligned, position: .leading) { value in
            AxisValueLabel(content: {
                if let id = value.as(String.self),
                   let item = matchedItems(with: id).first {
                    item.decoratedIconView(45, cutTo: .head)
                } else {
                    EmptyView()
                }
            })
        }
        AxisMarks { value in
            AxisValueLabel(content: {
                if let theValue = value.as(String.self),
                   let item = matchedItems(with: theValue).first {
                    Text(item.localizedName)
                        .offset(y: items.count == 1 ? 0 : 8)
                } else {
                    EmptyView()
                }
            })
        }
    }

    @AxisContentBuilder
    private func axisContentX(isLast: Bool) -> some AxisContent {
        AxisMarks(values: [0, 25, 50, 75, 100]) { _ in
            AxisGridLine()
            if isLast {
                AxisValueLabel()
            } else {
                AxisValueLabel {
                    EmptyView()
                }
            }
        }
    }
}

// MARK: - GachaTimeChart

@available(iOS 16.0, *)
private struct GachaTimeChart: View {
    var gachaViewModel: GachaViewModel
    let type: GachaType
    let formatter: DateFormatter = {
        let fmt = DateFormatter()
        fmt.dateStyle = .short
        fmt.timeStyle = .none
        return fmt
    }()

    var items: [GachaItem] { gachaViewModel.gachaItems }

    var itemsFiltered: [GachaItem] {
        items.filter { item in
            item.gachaType == type
        }
    }

    var gachaTypeDateCount: [GachaTypeDateCountAndIfContain5Star] {
        let dates = Set<Date>(itemsFiltered.map(\.time))
        return dates.map { date in
            let count: Int = itemsFiltered.filter { $0.time <= date }.count
            let contains5Star: Bool = !itemsFiltered.filter { $0.time == date && $0.rankType == .five }.isEmpty
            return GachaTypeDateCountAndIfContain5Star(
                date: date,
                count: count,
                type: type,
                contain5Star: contains5Star ? "true" : "false"
            )
        }.sorted(by: { $0.date > $1.date })
    }

    var dayDiffOfminMax: Int {
        let times = items.map { $0.time }
        let min = times.min()!
        let max = times.max()!

        let calendar = Calendar.current

        let components = calendar.dateComponents([.day], from: min, to: max)
        return components.day!
    }

    var color: Color {
        switch type {
        case .character: return .green
        case .standard: return .cyan
        case .weapon: return .mint
        default: return .cyan
        }
    }

    var body: some View {
        Chart(gachaTypeDateCount) {
            LineMark(
                x: .value("sys.date", $0.date),
                y: .value("sys.pull", $0.count)
            )
            .foregroundStyle(color)
//            .foregroundStyle(by: .value("app.gacha.label.gachaType", $0.type.localizedDescription()))
            PointMark(x: .value("sys.date", $0.date), y: .value("sys.pull", $0.count))
                .foregroundStyle(by: .value("是否有五星", $0.contain5Star))
        }
        .chartLegend(.hidden)
//        .chartYAxis(content: {
//            AxisMarks(position: .leading)
//        })
        .padding(.top)
        .frame(height: 200)
        .chartForegroundStyleScale([
            "true": .orange,
            "false": .blue.opacity(0),
        ])
//        .chartForegroundStyleScale([
//            GachaType.standard.localizedDescription(): .green,
//            GachaType.character.localizedDescription(): .blue,
//            GachaType.weapon.localizedDescription(): .yellow,
//        ])
//        ScrollView(.horizontal) {

//            .frame(width: CGFloat(dayDiffOfminMax) * 5, height: CGFloat(items.filter( {$0.gachaType == .character}).count))
//        }
    }
}

// MARK: - GachaTypeDateCountAndIfContain5Star

struct GachaTypeDateCountAndIfContain5Star: Hashable, Identifiable {
    let date: Date
    var count: Int
    let type: GachaType
    let contain5Star: String

    var id: Int {
        hashValue
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(date)
        hasher.combine(type)
    }
}
