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
    // MARK: Internal

    @FetchRequest(sortDescriptors: [.init(
        keyPath: \Account.priority,
        ascending: true
    )])
    var accounts: FetchedResults<Account>

    @StateObject
    var gachaViewModel: GachaViewModel = .shared

    @State
    var showTime: Bool = false

    @State
    var isHelpSheetShow: Bool = false

    var body: some View {
        mainView()
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    GetGachaNavigationMenu(
                        showByAPI: mainlandChinaAccountDetected,
                        isHelpSheetShow: $isHelpSheetShow
                    )
                }

                if !gachaViewModel.allAvaliableAccountUID.isEmpty {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        ExportGachaView(compactLayout: true, uid: gachaViewModel.filter.uid)
                    }
                }

                ToolbarItem(placement: .principal) {
                    Menu {
                        ForEach(
                            gachaViewModel.allAvaliableAccountUID,
                            id: \.self
                        ) { uid in
                            Group {
                                if let name: String = firstAccount(uid: uid)?.name {
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
                                if let name: String = firstAccount(uid: uid)?.name {
                                    Text(name)
                                } else {
                                    Text(uid)
                                }
                            } else {
                                Text("app.gacha.get.button")
                            }
                        }
                    }
                    .disabled(gachaViewModel.allAvaliableAccountUID.isEmpty)
                }
            }
            .environmentObject(gachaViewModel)
            .navigationBarTitleDisplayMode(.inline)
    }

    @ViewBuilder
    func mainView() -> some View {
        List {
            if !gachaViewModel.filteredGachaItemsWithCount.isEmpty {
                Section {
                    LabeledContent("gacha.account_detail.gacha_type") {
                        Menu {
                            ForEach(
                                GachaType.allAvailableCases
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
                        Label("app.gacha.chart.more.button", systemSymbol: .chartBarXaxis)
                    }
                }
                GachaStatisticSectionView()
            } else {
                Text("gacha.records.noQuintapleStarRecordsFound").foregroundColor(.gray)
            }
            Section {
                NavigationLink("app.gacha.details.button") {
                    GachaDetailView()
                }
            }
        }
        .sheet(isPresented: $isHelpSheetShow, content: {
            HelpSheet(isShow: $isHelpSheetShow)
        })
    }

    // MARK: Private

    private var mainlandChinaAccountDetected: Bool {
        accounts.first(where: { $0.server.region == .mainlandChina }) != nil
    }

    private func firstAccount(uid: String) -> Account? {
        accounts.first(where: { $0.uid == uid })
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
                Label("app.gacha.afterLast5Star", systemSymbol: .flagFill)
                Spacer()
                let pull: Int = gachaViewModel.sortedAndFilteredGachaItem
                    .firstIndex(where: { $0.rankType == .five }) ?? gachaViewModel.sortedAndFilteredGachaItem.count
                Text("app.gacha.pull:\(pull)")
            }
            HStack {
                Label(
                    showDrawingNumber ? "app.gacha.allPull" : "app.gacha.total.primogems",
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
                    showDrawingNumber ? "app.gacha.avg.5star.pull" : "app.gacha.avg.5star.primogems",
                    systemSymbol: .star
                )
                Spacer()
                let number = fiveStarItemsWithCount.map { $0.count }
                    .reduce(0, +) /
                    max(fiveStarItemsWithCount.count, 1)
                Text("\(showDrawingNumber ? number : number * 160)")
            }
            if ![GachaType]([.standard, .chronicled]).contains(gachaViewModel.filter.gachaType) {
                HStack {
                    Label(
                        showDrawingNumber ? "app.gacha.avg.5starLimited.pull" : "app.gacha.avg.5starLimited.primogems",
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
                    Label("app.gacha.won50-50", systemSymbol: .chartPieFill)
                    Spacer()
                    Text(
                        "\(fmt.string(from: pct as NSNumber)!)"
                    )
                }
            }
            if ![GachaType]([.standard, .chronicled]).contains(gachaViewModel.filter.gachaType) {
                VStack {
                    HStack {
                        Text(Defaults[.useGuestGachaEvaluator] ? "app.gacha.review.pom-pom" : "app.gacha.review.paimon")
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
            Text("app.gacha.stat.title")
                .textCase(.none)
        }
        .onTapGesture {
            simpleTaptic(type: .light)
            if ![GachaType]([.standard, .chronicled]).contains(gachaViewModel.filter.gachaType) {
                withAnimation(.easeInOut(duration: 0.1)) {
                    showDrawingNumber.toggle()
                }
            }
        }
        .onReceive(gachaViewModel.objectWillChange) {
            if ![GachaType]([.standard, .chronicled]).contains(gachaViewModel.filter.gachaType) {
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

// MARK: - GachaItemBar

private struct GachaItemBar: View {
    let item: GachaItem
    let count: Int
    let showTime: Bool
    let showingType: GachaFilter.Rank

    var isItemIDMissing: Bool {
        item.itemId.isEmpty
    }

    @MainActor
    var itemIDText: Text {
        if showTime {
            Text(verbatim: isItemIDMissing ? "  !! Item ID Missing" : "  (ID: \(item.itemId))")
                .font(.caption).foregroundColor(isItemIDMissing ? .red : .secondary)
        } else {
            Text(verbatim: "")
        }
    }

    var width: CGFloat { showingType == .five ? 35 : 30 }
    var body: some View {
        HStack {
            Label {
                Text(item.localizedName) + itemIDText
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
        let averageValue = fiveStarItems.map(\.count).reduce(0, +) / max(fiveStarItems.count, 1)
        ScrollView(.horizontal) {
            Chart {
                ForEach(fiveStarItems, id: \.0.id) { item in
                    BarMark(
                        x: .value("角色", item.0.id),
                        y: .value("sys.pull", item.count)
                    )
                    .annotation(position: .top) {
                        Text("\(item.count)").foregroundColor(.gray)
                            .font(.caption)
                    }
                    .foregroundStyle(by: .value("sys.pull", item.0.id))
                }
                if !fiveStarItems.isEmpty {
                    RuleMark(y: .value("平均", averageValue))
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
    let showByAPI: Bool

    @Binding
    var isHelpSheetShow: Bool

    var body: some View {
        Menu {
            Button {
                isHelpSheetShow.toggle()
            } label: {
                Label("app.gacha.import.which", systemSymbol: .questionmarkDiamond)
            }

            if showByAPI {
                NavigationLink(
                    destination: APIGetGachaView()
                ) {
                    Label("app.gacha.import.api", systemSymbol: .network)
                }
            }
            NavigationLink(
                destination: GetGachaClipboardView()
            ) {
                Label("app.gacha.import.url", systemSymbol: .docOnClipboard)
            }
            NavigationLink(
                destination: ImportGachaView()
            ) {
                Label("app.gacha.import.uigf", systemSymbol: .squareAndArrowDownOnSquare)
            }
        } label: {
            Image(systemSymbol: .goforwardPlus)
        }
    }
}

// MARK: - HelpSheet

private struct HelpSheet: View {
    @Binding
    var isShow: Bool

    var body: some View {
        NavigationStack {
            List {
                Section {
                    Label(
                        "app.gacha.import.help.1",
                        systemSymbol: .personFillQuestionmark
                    )
                    // TODO: not completed gacha tutorial video
//                    Label(
//                        "app.gacha.import.help.2",
//                        systemSymbol: .handThumbsupFill
//                    )
//                    GachaHelpVideoLink()
                }
                Section {
                    Label("app.gacha.import.help.3", systemSymbol: .textBubble)
                    Label("app.gacha.import.help.4", systemSymbol: .network)
                } footer: {
                    Text("app.gacha.import.server.cn")
                        .bold()
                }
                Section {
                    Label("app.gacha.import.help.5", systemSymbol: .textBubble)
                    Label(
                        "app.gacha.import.help.6",
                        systemSymbol: .docOnClipboard
                    )
                } footer: {
                    Text("app.gacha.import.server.all")
                }
                Section {
                    Label(
                        "app.gacha.import.help.7",
                        systemSymbol: .squareAndArrowDownOnSquare
                    )
                    if Bundle.main.preferredLocalizations.first?.prefix(2) == "zh" {
                        Link(
                            destination: URL(
                                string: "https://uigf.org/zh/partnership.html"
                            )!
                        ) {
                            Label(
                                "app.gacha.import.help.uigf.button",
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
                                "app.gacha.import.help.uigf.button",
                                systemSymbol: .appBadgeCheckmark
                            )
                        }
                    }
                } footer: {
                    Text("app.gacha.import.server.all")
                }
            }
            .navigationTitle("app.gacha.import.help.title")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("sys.done") {
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
                Text("app.open.bilibili")
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
                Text("app.open.youtube")
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
        guard ![GachaType]([.standard, .chronicled]).contains(gachaType) else { return false }
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
        keyPath: \Account.priority,
        ascending: true
    )])
    var accounts: FetchedResults<Account>

    @StateObject
    var gachaViewModel: GachaViewModel = .shared

    @State
    var showTime: Bool = false

    var body: some View {
        List {
            Section {
                LabeledContent("gacha.account_detail.detail.filter.gacha_type") {
                    Menu {
                        ForEach(GachaType.allAvailableCases) { gachaType in
                            Button(gachaType.localizedDescription()) {
                                withAnimation {
                                    gachaViewModel.filter.gachaType = gachaType
                                }
                            }
                        }
                    } label: {
                        Text(gachaViewModel.filter.gachaType.localizedDescription())
                    }
                }

                LabeledContent("gacha.account_detail.detail.filter.rank") {
                    Menu {
                        ForEach(GachaFilter.Rank.allCases) { rank in
                            Button(rank.description) {
                                withAnimation {
                                    gachaViewModel.filter.rank = rank
                                }
                            }
                        }
                    } label: {
                        Text(gachaViewModel.filter.rank.description)
                    }
                }

                Toggle(
                    "gacha.account_detail.detail.filter.display_option.show_time",
                    isOn: $showTime.animation()
                )
            } header: {
                Text("gacha.account_detail.detail.filter.display_option.title")
            }

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
                            Text("app.gacha.get.button")
                        }
                    }
                }
                .disabled(gachaViewModel.allAvaliableAccountUID.isEmpty)
            }
        }
    }
}
