//
//  GachaView.swift
//  GenshinPizzaHepler
//
//  Created by 戴藏龙 on 2023/3/28.
//

import Charts
import CoreData
import Defaults
import HBMihoyoAPI
import SFSafeSymbols
import SwiftUI

// MARK: - GachaView

@available(iOS 15.0, *)
struct GachaView: View {
    @FetchRequest(sortDescriptors: [.init(
        keyPath: \AccountConfiguration.priority,
        ascending: true
    )])
    var accounts: FetchedResults<AccountConfiguration>

    @StateObject
    var gachaViewModel: GachaViewModel = .shared

    @State
    var showTime: Bool = false

    @State
    var isHelpSheetShow: Bool = false

    var body: some View {
        Group {
            if #available(iOS 16.0, *) {
                mainView()
                    .toolbar {
                        ToolbarItem(placement: .bottomBar) {
                            Menu {
                                ForEach(
                                    GachaType
                                        .allAvaliableGachaType()
                                ) { gachaType in
                                    Button(gachaType.localizedDescription()) {
                                        withAnimation {
                                            gachaViewModel.filter
                                                .gachaType = gachaType
                                        }
                                    }
                                }
                            } label: {
                                Text(
                                    gachaViewModel.filter.gachaType
                                        .localizedDescription()
                                )
                            }
                        }
                    }
            } else {
                mainView()
                    .toolbar {
                        ToolbarItemGroup(placement: .bottomBar) {
                            FilterEditor(
                                filter: $gachaViewModel.filter,
                                showTime: $showTime
                            )
                        }
                    }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                GetGachaNavigationMenu(
                    showByAPI: accounts
                        .first(where: { $0.server.region == .mainlandChina }) !=
                        nil,
                    isHelpSheetShow: $isHelpSheetShow
                )
            }

            ToolbarItem(placement: .principal) {
                Menu {
                    ForEach(
                        gachaViewModel.allAvaliableAccountUID,
                        id: \.self
                    ) { uid in
                        Group {
                            if let name: String = accounts
                                .first(where: { $0.uid == uid })?
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
                        Image(systemSymbol: .arrowLeftArrowRightCircle)
                        if let uid: String = gachaViewModel.filter.uid {
                            if let name: String = accounts
                                .first(where: { $0.uid == uid })?
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
    }

    @ViewBuilder
    func mainView() -> some View {
        List {
            if !gachaViewModel.filteredGachaItemsWithCount.isEmpty {
                if #available(iOS 16.0, *) {
                    Section {
                        VStack(alignment: .leading) {
                            GachaChart(
                                items: gachaViewModel
                                    .filteredGachaItemsWithCount
                            )
                            HelpTextForScrollingOnDesktopComputer(.horizontal)
                        }
                        NavigationLink {
                            GachaChartView()
                                .navigationBarTitleDisplayMode(.inline)
                                .environmentObject(gachaViewModel)
                        } label: {
                            Label("更多图表", systemSymbol: .chartBarXaxis)
                        }
                    }
                }
                GachaStatisticSectionView()
            } else {
                Text("gacha.records.noQuintapleStarRecordsFound").foregroundColor(.gray)
            }
            if #available(iOS 16.0, *) {
                Section {
                    NavigationLink("详细记录") {
                        GachaDetailView()
                    }
                }
            } else {
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
                }
            }
        }
        .sheet(isPresented: $isHelpSheetShow, content: {
            HelpSheet(isShow: $isHelpSheetShow)
        })
    }
}

// MARK: - GachaStatisticSectionView

private struct GachaStatisticSectionView: View {
    // MARK: Internal

    enum Rank: Int, CaseIterable {
        case one
        case two
        case three
        case four
        case five
    }

    @StateObject
    var gachaViewModel: GachaViewModel = .shared

    var reviewIconSize: CGFloat {
        (ThisDevice.isSmallestHDScreenPhone || ThisDevice.isThinnestSplitOnPad) ? 30 : 50
    }

    var body: some View {
        let items = gachaViewModel.sortedAndFilteredGachaItem
        let fiveStarItemsWithCount = gachaViewModel
            .filteredGachaItemsWithCount
            .filter { item, _ in
                item.rankType == .five
            }
        let fiveStars = items.filter { item in
            item.rankType == .five
        }
        let fiveStarsNotLose = fiveStars.filter { item in
            !item.isLose5050()
        }
        let limitedNumber = fiveStarItemsWithCount
            .map(\.count)
            .reduce(0, +) /
            max(
                fiveStarItemsWithCount
                    .filter { item, _ in
                        !item.isLose5050()
                    }.count,
                1
            )
        Section {
            HStack {
                Label("当前已垫", systemSymbol: .flagFill)
                Spacer()
                Text(
                    "\(gachaViewModel.sortedAndFilteredGachaItem.firstIndex(where: { $0.rankType == .five }) ?? gachaViewModel.sortedAndFilteredGachaItem.count)抽"
                )
            }
            HStack {
                Label(
                    showDrawingNumber ? "总抽数" : "总消耗原石数",
                    systemSymbol: .handTapFill
                )
                Spacer()
                let total = gachaViewModel.sortedAndFilteredGachaItem
                    .filter { item in
                        item.gachaType == gachaViewModel.filter
                            .gachaType
                    }.count
                Text("\(showDrawingNumber ? total : total * 160)")
            }
            HStack {
                Label(
                    showDrawingNumber ? "五星平均抽数" : "五星平均消耗原石数",
                    systemSymbol: .star
                )
                Spacer()
                let number = fiveStarItemsWithCount.map { $0.count }
                    .reduce(0) { $0 + $1 } /
                    max(fiveStarItemsWithCount.count, 1)
                Text("\(showDrawingNumber ? number : number * 160)")
            }
            if gachaViewModel.filter.gachaType != .standard {
                HStack {
                    Label(
                        showDrawingNumber ? "限定五星平均抽数" : "限定五星平均消耗原石数",
                        systemSymbol: .starFill
                    )
                    Spacer()
                    Text(
                        "\(showDrawingNumber ? limitedNumber : limitedNumber * 160)"
                    )
                }
                HStack {
                    let fmt: NumberFormatter = {
                        let fmt = NumberFormatter()
                        fmt.maximumFractionDigits = 2
                        fmt.numberStyle = .percent
                        return fmt
                    }()
                    // 如果获得的第一个五星是限定，默认其不歪
                    let pct = 1.0 -
                        Double(
                            fiveStars.count - fiveStarsNotLose
                                .count // 歪次数 = 非限定五星数量
                        ) /
                        Double(
                            fiveStarsNotLose
                                .count +
                                ((fiveStars.last?.isLose5050() ?? false) ? 1 : 0)
                        ) // 小保底次数 = 限定五星数量（如果抽的第一个是非限定，则多一次小保底）
                    Label("不歪率", systemSymbol: .chartPieFill)
                    Spacer()
                    Text(
                        "\(fmt.string(from: pct as NSNumber)!)"
                    )
                }
            }
            if gachaViewModel.filter.gachaType != .standard {
                VStack {
                    HStack {
                        Text(Defaults[.useGuestGachaEvaluator] ? "帕姆的评价" : "派蒙的评价")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Spacer()
                    }
                    HStack {
                        Spacer()
                        let judgedRank = Rank.judge(
                            limitedDrawNumber: limitedNumber,
                            gachaType: gachaViewModel.filter.gachaType
                        )
                        ForEach(Rank.allCases, id: \.rawValue) { rank in
                            Group {
                                if judgedRank == rank {
                                    rank.image(neighborGame: Defaults[.useGuestGachaEvaluator]).resizable()
                                        .scaledToFit()
                                } else {
                                    rank.image(neighborGame: Defaults[.useGuestGachaEvaluator]).resizable()
                                        .scaledToFit()
                                        .opacity(0.25)
                                }
                            }
                            .frame(width: reviewIconSize, height: reviewIconSize)
                            Spacer()
                        }
                    }
                }
            }
        } header: {
            Text("统计数据")
                .textCase(.none)
        }
        .onTapGesture {
            simpleTaptic(type: .light)
            if gachaViewModel.filter.gachaType != .standard {
                withAnimation(.easeInOut(duration: 0.1)) {
                    showDrawingNumber.toggle()
                }
            }
        }
        .onReceive(gachaViewModel.objectWillChange) {
            if gachaViewModel.filter.gachaType == .standard {
                showDrawingNumber = true
            }
        }
    }

    // MARK: Private

    /// 展示原石或抽数
    @State
    private var showDrawingNumber: Bool = true
}

extension GachaStatisticSectionView.Rank {
    func image(neighborGame: Bool = false) -> Image {
        switch self {
        case .one:
            return !neighborGame ? Image("UI_EmotionIcon5") : Image("Pom-Pom_Sticker_21")
        case .two:
            return !neighborGame ? Image("UI_EmotionIcon4") : Image("Pom-Pom_Sticker_32")
        case .three:
            return !neighborGame ? Image("UI_EmotionIcon3") : Image("Pom-Pom_Sticker_18")
        case .four:
            return !neighborGame ? Image("UI_EmotionIcon2") : Image("Pom-Pom_Sticker_24")
        case .five:
            return !neighborGame ? Image("UI_EmotionIcon1") : Image("Pom-Pom_Sticker_30")
        }
    }

    fileprivate static func judge(
        limitedDrawNumber: Int,
        gachaType: GachaType
    )
        -> Self {
        switch gachaType {
        case .character:
            switch limitedDrawNumber {
            case ...80:
                return .five
            case 80 ..< 90:
                return .four
            case 90 ..< 100:
                return .three
            case 100 ..< 110:
                return .two
            case 110...:
                return .one
            default:
                return .one
            }
        case .weapon:
            switch limitedDrawNumber {
            case ...80:
                return .five
            case 80 ..< 90:
                return .four
            case 90 ..< 100:
                return .three
            case 100 ..< 110:
                return .two
            case 110...:
                return .one
            default:
                return .one
            }
        default:
            return .one
        }
    }
}

// MARK: - FilterEditor

private struct FilterEditor: View {
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
                item.decoratedIconView(width, cutTo: .face)
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
                                item.decoratedIconView(30, cutTo: .face)
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
            .padding(.leading, 1)
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

@available(iOS 15.0, *)
private struct GetGachaNavigationMenu: View {
    // MARK: Internal

    let showByAPI: Bool

    @Binding
    var isHelpSheetShow: Bool

    var body: some View {
        Menu {
            Button {
                isHelpSheetShow.toggle()
            } label: {
                Label("我该选哪个？", systemSymbol: .questionmarkDiamond)
            }

            if showByAPI {
                Button {
                    showView1.toggle()
                } label: {
                    Label("通过API获取", systemSymbol: .network)
                }
            }
            Button {
                showView3.toggle()
            } label: {
                Label("通过粘贴祈愿页面URL获取", systemSymbol: .docOnClipboard)
            }
            Button {
                showView4.toggle()
            } label: {
                Label(
                    "导入UIGF祈愿记录",
                    systemSymbol: .squareAndArrowDownOnSquare
                )
            }
        } label: {
            Image(systemSymbol: .goforwardPlus)
        }
        .background(
            Group {
                NavigationLink(
                    destination: APIGetGachaView(),
                    isActive: $showView1
                ) {
                    EmptyView()
                }
                NavigationLink(
                    destination: GetGachaClipboardView(),
                    isActive: $showView3
                ) {
                    EmptyView()
                }
                NavigationLink(
                    destination: ImportGachaView(),
                    isActive: $showView4
                ) {
                    EmptyView()
                }
            }
        )
    }

    // MARK: Private

    @State
    private var showView1 = false
    @State
    private var showView2 = false
    @State
    private var showView3 = false
    @State
    private var showView4 = false
}

// MARK: - HelpSheet

private struct HelpSheet: View {
    @Binding
    var isShow: Bool

    var body: some View {
        NavigationView {
            List {
                Section {
                    Label(
                        "无论选择哪种方式，我们都为您提供了详细的操作教程",
                        systemSymbol: .personFillQuestionmark
                    )
                    // TODO: not completed gacha tutorial video
//                    Label(
//                        "您也可以选择参考我们的视频完成相关操作",
//                        systemSymbol: .handThumbsupFill
//                    )
//                    GachaHelpVideoLink()
                }
                Section {
                    Label("如果您的账号所在服务器位于中国大陆", systemSymbol: .textBubble)
                    Label("请优先选择「通过API」一键获取", systemSymbol: .network)
                } footer: {
                    Text("仅适用于中国大陆服务器")
                        .bold()
                }
                Section {
                    Label("国际服务器玩家该怎么办", systemSymbol: .textBubble)
                    Label(
                        "建议使用「通过粘贴祈愿页面URL」获取，我们亦内附了教程",
                        systemSymbol: .docOnClipboard
                    )
                } footer: {
                    Text("适用于所有服务器")
                }
                Section {
                    Label(
                        "如果您之前使用其他软件获取过祈愿记录，且该软件支持导出UIGF（统一可交换祈愿记录标准）格式的文件，您可以将其导入",
                        systemSymbol: .squareAndArrowDownOnSquare
                    )
                    if Bundle.main.preferredLocalizations.first?.prefix(2) == "zh" {
                        Link(
                            destination: URL(
                                string: "https://uigf.org/zh/partnership.html"
                            )!
                        ) {
                            Label(
                                "支持UIGF的软件",
                                systemSymbol: .appBadgeCheckmark
                            )
                        }
                    } else {
                        Link(
                            destination: URL(
                                string: "https://uigf.org/en/partnership.html"
                            )!
                        ) {
                            Label(
                                "支持UIGF的软件",
                                systemSymbol: .appBadgeCheckmark
                            )
                        }
                    }
                } footer: {
                    Text("适用于所有服务器")
                }
            }
            .navigationTitle("抽卡记录获取帮助")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("完成") {
                        isShow.toggle()
                    }
                }
            }
        }
    }
}

// MARK: - GachaHelpVideoLink

private struct GachaHelpVideoLink: View {
    var body: some View {
        Link(destination: URL(
            string: "https://www.bilibili.com/video/BV1Lg411S7wa"
        )!) {
            Label {
                Text("打开Bilibili观看")
            } icon: {
                Image("bilibili")
                    .resizable()
                    .foregroundColor(.blue)
                    .scaledToFit()
            }
        }
        Link(
            destination: URL(
                string: "https://www.youtube.com/watch?v=k9G2N8XYFm4"
            )!
        ) {
            Label {
                Text("打开YouTube观看")
            } icon: {
                Image("youtube")
                    .resizable()
                    .foregroundColor(.blue)
                    .scaledToFit()
            }
        }
    }
}

extension GachaItem {
    /// 是否歪了
    func isLose5050() -> Bool {
        guard gachaType != .standard else { return false }
        guard ![
            "阿莫斯之弓",
            "天空之翼",
            "四风原典",
            "天空之卷",
            "和璞鸢",
            "天空之脊",
            "狼的末路",
            "天空之傲",
            "风鹰剑",
            "天空之刃",
            "迪卢克",
            "琴",
            "七七",
            "莫娜"
        ].contains(name) else {
            return true
        }
        let calendar = Calendar(identifier: .gregorian)
        if name == "刻晴",
           !(
               calendar.date(
                   from: DateComponents(year: 2021, month: 2, day: 17)
               )! ... calendar.date(from: DateComponents(
                   year: 2021,
                   month: 3,
                   day: 2
               ))!
           ).contains(time) {
            return true
        } else if name == "提纳里",
                  !(
                      calendar
                          .date(
                              from: DateComponents(
                                  year: 2022,
                                  month: 8,
                                  day: 24
                              )
                          )! ... calendar.date(from: DateComponents(
                              year: 2022,
                              month: 9,
                              day: 9
                          ))!
                  ).contains(time) {
            return true
        } else if name == "迪希雅",
                  !(
                      calendar
                          .date(
                              from: DateComponents(year: 2023, month: 3, day: 1)
                          )! ... calendar.date(from: DateComponents(
                              year: 2023,
                              month: 3,
                              day: 21
                          ))!
                  ).contains(time) {
            return true
        } else {
            return false
        }
    }
}

// MARK: - GachaDetailView

private struct GachaDetailView: View {
    @FetchRequest(sortDescriptors: [.init(
        keyPath: \AccountConfiguration.priority,
        ascending: true
    )])
    var accounts: FetchedResults<AccountConfiguration>

    @StateObject
    var gachaViewModel: GachaViewModel = .shared

    @State
    var showTime: Bool = false

    var body: some View {
        List {
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
        }
        .navigationTitle("抽取记录")
        .toolbar {
            ToolbarItemGroup(placement: .bottomBar) {
                FilterEditor(
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
                            if let name: String = accounts
                                .first(where: { $0.uid == uid })?
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
                        Image(systemSymbol: .arrowLeftArrowRightCircle)
                        if let uid: String = gachaViewModel.filter.uid {
                            if let name: String = accounts
                                .first(where: { $0.uid == uid })?
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
    }
}
