//
//  DetailPortalView.swift
//  GenshinPizzaHepler
//
//  Created by Bill Haku on 2022/9/17.
//

import Combine
import Defaults
import GIPizzaKit
import HBMihoyoAPI
import HoYoKit
import SFSafeSymbols
import SwiftPieChart
import SwiftUI

let detailPortalRefreshSubject: PassthroughSubject<(), Never> = .init()

// MARK: - DetailPortalViewModel

@MainActor
final class DetailPortalViewModel: ObservableObject {
    // MARK: Lifecycle

    init() {
        let request = AccountConfiguration.fetchRequest()
        request.sortDescriptors = [.init(keyPath: \AccountConfiguration.priority, ascending: true)]
        let accounts = try? AccountConfigurationModel.shared.container.viewContext.fetch(request)
        if let accounts, let account = accounts.first {
            self.selectedAccount = account
        } else {
            self.selectedAccount = nil
        }
    }

    // MARK: Internal

    enum Status<T> {
        case progress(Task<(), Never>?)
        case fail(Error)
        case succeed(T)
    }

    @Published
    var playerDetailStatus: Status<(PlayerDetail, nextRefreshableDate: Date)> = .progress(nil)

    @Published
    var basicInfoStatus: Status<BasicInfos> = .progress(nil)

    @Published
    var spiralAbyssDetailStatus: Status<SpiralAbyssDetail> = .progress(nil)

    @Published
    var ledgerDataStatus: Status<LedgerData> = .progress(nil)

    @Published
    var allAvatarInfoStatus: Status<AllAvatarDetailModel> = .progress(nil)

    @Published
    var selectedAccount: AccountConfiguration? {
        didSet { refresh() }
    }

    func refresh() {
        fetchPlayerDetail()
        fetchBasicInfo()
        fetchSpiralAbyssInfo()
        fetchLedgerData()
        fetchAllAvatarInfo()
        detailPortalRefreshSubject.send(())
    }

    func fetchAllAvatarInfo() {
        guard let account = selectedAccount else { return }
        if case let .progress(task) = allAvatarInfoStatus { task?.cancel() }
        let task = Task {
            do {
                let result = try await MiHoYoAPI.allAvatarDetail(
                    server: account.server,
                    uid: account.safeUid,
                    cookie: account.safeCookie,
                    deviceFingerPrint: account.safeDeviceFingerPrint,
                    deviceId: account.safeUuid
                )
                DispatchQueue.main.async {
                    withAnimation {
                        self.allAvatarInfoStatus = .succeed(result)
                    }
                }
            } catch {
                DispatchQueue.main.async {
                    self.allAvatarInfoStatus = .fail(error)
                }
            }
        }
        allAvatarInfoStatus = .progress(task)
    }

    func fetchPlayerDetail() {
        guard let selectedAccount else { return }
        if case let .succeed((_, refreshableDate)) = playerDetailStatus {
            guard Date() > refreshableDate else { return }
        }
        if case let .progress(task) = playerDetailStatus { task?.cancel() }
        let task = Task {
            do {
                async let result = try await API.OpenAPIs.fetchPlayerDetail(
                    selectedAccount.safeUid,
                    dateWhenNextRefreshable: nil
                )
                async let (charLoc, charMap) = try await Enka.Sputnik.shared.getEnkaDataSet()
                let playerDetail = try await PlayerDetail(
                    PlayerDetailFetchModel: result,
                    localizedDictionary: charLoc,
                    characterMap: charMap
                )
                DispatchQueue.main.async {
                    withAnimation {
                        self.playerDetailStatus = .succeed((
                            playerDetail,
                            Date()
                        ))
                    }
                }
            } catch {
                DispatchQueue.main.async {
                    self.playerDetailStatus = .fail(error)
                }
            }
        }
        playerDetailStatus = .progress(task)
    }

    func fetchBasicInfo() {
        guard let account = selectedAccount else { return }
        if case let .progress(task) = basicInfoStatus { task?.cancel() }
        let task = Task {
            do {
                let result = try await MiHoYoAPI.basicInfo(
                    server: account.server,
                    uid: account.safeUid,
                    cookie: account.safeCookie,
                    deviceFingerPrint: account.safeDeviceFingerPrint,
                    deviceId: account.safeUuid
                )
                DispatchQueue.main.async {
                    withAnimation {
                        self.basicInfoStatus = .succeed(result)
                    }
                }
            } catch {
                DispatchQueue.main.async {
                    self.basicInfoStatus = .fail(error)
                }
            }
        }
        basicInfoStatus = .progress(task)
    }

    func fetchSpiralAbyssInfo() {
        guard let account = selectedAccount else { return }
        if case let .progress(task) = spiralAbyssDetailStatus { task?.cancel() }
        let task = Task {
            do {
                let result = try await MiHoYoAPI.abyssData(
                    round: .this,
                    server: account.server,
                    uid: account.safeUid,
                    cookie: account.safeCookie,
                    deviceFingerPrint: account.safeDeviceFingerPrint,
                    deviceId: account.safeUuid
                )
                DispatchQueue.main.async {
                    withAnimation {
                        self.spiralAbyssDetailStatus = .succeed(result)
                    }
                }
            } catch {
                DispatchQueue.main.async {
                    self.spiralAbyssDetailStatus = .fail(error)
                }
            }
        }
        spiralAbyssDetailStatus = .progress(task)
    }

    func fetchLedgerData() {
        guard let account = selectedAccount else { return }
        if case let .progress(task) = ledgerDataStatus { task?.cancel() }
        let task = Task {
            do {
                let month = Calendar.current.dateComponents([.month], from: Date()).month!
                let result = try await MiHoYoAPI.ledgerData(
                    month: month,
                    uid: account.safeUid,
                    server: account.server,
                    cookie: account.safeCookie
                )
                DispatchQueue.main.async {
                    withAnimation {
                        self.ledgerDataStatus = .succeed(result)
                    }
                }
            } catch {
                DispatchQueue.main.async {
                    self.ledgerDataStatus = .fail(error)
                }
            }
        }
        spiralAbyssDetailStatus = .progress(task)
    }
}

// MARK: - DetailPortalView

struct DetailPortalView: View {
    // MARK: Internal

    var body: some View {
        NavigationView {
            List {
                SelectAccountSection(selectedAccount: $detailPortalViewModel.selectedAccount)
                if let account = detailPortalViewModel.selectedAccount {
                    PlayerDetailSection(account: account)
                    Section {
                        AbyssInfoNavigator(account: account, status: detailPortalViewModel.spiralAbyssDetailStatus)
                        LedgerDataNavigator(account: account, status: detailPortalViewModel.ledgerDataStatus)
                        BasicInfoNavigator(account: account, status: detailPortalViewModel.basicInfoStatus)
                    }
                }
            }
            .refreshable {
                detailPortalViewModel.refresh()
            }
        }
        .environmentObject(detailPortalViewModel)
    }

    // MARK: Private

    @StateObject
    private var detailPortalViewModel: DetailPortalViewModel = .init()
}

// MARK: - SelectAccountSection

private struct SelectAccountSection: View {
    @EnvironmentObject
    private var detailPortalViewModel: DetailPortalViewModel

    // MARK: Internal

    @Binding
    var selectedAccount: AccountConfiguration?

    var body: some View {
        if let selectedAccount {
            if case let .succeed((playerDetail, _)) = detailPortalViewModel.playerDetailStatus,
               let basicInfo = playerDetail.basicInfo {
                normalAccountPickerView(
                    playerDetail: playerDetail,
                    basicInfo: basicInfo,
                    selectedAccount: selectedAccount
                )
            } else {
                noBasicInfoFallBackView(selectedAccount: selectedAccount)
            }
        } else {
            noSelectAccountView()
        }
    }

    @ViewBuilder
    func normalAccountPickerView(
        playerDetail: PlayerDetail,
        basicInfo: PlayerDetail.PlayerBasicInfo,
        selectedAccount: AccountConfiguration
    )
        -> some View {
        Section {
            HStack(spacing: 0) {
                HStack {
                    basicInfo.decoratedIcon(64)
                    Spacer()
                }
                .frame(width: 74)
                .corneredTag(
                    "detailPortal.player.adventureRank.short:\(basicInfo.level.description)",
                    alignment: .bottomTrailing,
                    textSize: 12
                )
                VStack(alignment: .leading) {
                    HStack(spacing: 10) {
                        VStack(alignment: .leading) {
                            Text(basicInfo.nickname)
                                .font(.title3)
                                .bold()
                                .padding(.top, 5)
                                .lineLimit(1)
                            Text(basicInfo.signature)
                                .foregroundColor(.secondary)
                                .font(.footnote)
                                .lineLimit(2)
                                .fixedSize(
                                    horizontal: false,
                                    vertical: true
                                )
                        }
                        Spacer()
                        SelectAccountMenu {
                            Image(systemSymbol: .arrowLeftArrowRightCircle)
                        } completion: { account in
                            self.selectedAccount = account
                        }
                    }
                }
            }
        } footer: {
            HStack {
                Text("UID: \(selectedAccount.safeUid)")
                Spacer()
                let worldLevelTitle = "detailPortal.player.worldLevel".localized
                Text("\(worldLevelTitle): \(basicInfo.worldLevel)")
            }
        }
    }

    @ViewBuilder
    func noBasicInfoFallBackView(selectedAccount: AccountConfiguration) -> some View {
        Section {
            HStack(spacing: 0) {
                HStack {
                    CharacterAsset.Paimon.decoratedIcon(64)
                    Spacer()
                }
                .frame(width: 74)
                VStack(alignment: .leading) {
                    HStack(spacing: 10) {
                        VStack(alignment: .leading) {
                            Text(selectedAccount.safeName)
                                .font(.title3)
                                .bold()
                                .padding(.top, 5)
                                .lineLimit(1)
                        }
                        Spacer()
                        SelectAccountMenu {
                            Image(systemSymbol: .arrowLeftArrowRightCircle)
                        } completion: { account in
                            self.selectedAccount = account
                        }
                    }
                }
            }
        } footer: {
            HStack {
                Text("UID: \(selectedAccount.safeUid)")
            }
        }
    }

    @ViewBuilder
    func noSelectAccountView() -> some View {
        Section {
            SelectAccountMenu {
                Label("detailPortal.prompt.pleaseSelectAccount", systemSymbol: .arrowLeftArrowRightCircle)
            } completion: { account in
                selectedAccount = account
            }
        }
    }

    // MARK: Private

    private struct SelectAccountMenu<T: View>: View {
        @FetchRequest(sortDescriptors: [.init(
            keyPath: \AccountConfiguration.priority,
            ascending: true
        )])
        var accounts: FetchedResults<AccountConfiguration>

        let label: () -> T

        let completion: (AccountConfiguration) -> ()

        var body: some View {
            Menu {
                ForEach(accounts, id: \.safeUuid) { account in
                    Button(account.safeName) {
                        completion(account)
                    }
                }
            } label: {
                label()
            }
        }
    }
}

// MARK: - PlayerDetailSection.DataFetchedView.ID + Identifiable

extension PlayerDetailSection.DataFetchedView.ID: Identifiable {
    public var id: String { self }
}

// MARK: - PlayerDetailSection

private struct PlayerDetailSection: View {
    @EnvironmentObject
    private var detailPortalViewModel: DetailPortalViewModel

    struct DataFetchedView: View {
        typealias ID = String

        let playerDetail: PlayerDetail
        let account: AccountConfiguration

        @State
        var showingCharacterName: ID?

        var body: some View {
            VStack {
                if playerDetail.avatars.isEmpty {
                    Text(
                        playerDetail
                            .basicInfo != nil
                            ? "account.playerDetailResult.message.characterShowCaseClassified"
                            : "account.playerDetailResult.message.enkaGotNulledResultFromCelestiaServer"
                    )
                    .foregroundColor(.secondary)
                    if let msg = playerDetail.enkaMessage {
                        Text(msg).foregroundColor(.secondary).controlSize(.small)
                    }
                } else {
                    ScrollView(.horizontal) {
                        HStack {
                            ForEach(
                                playerDetail.avatars,
                                id: \.name
                            ) { avatar in
                                Button {
                                    simpleTaptic(type: .medium)
                                    withAnimation(
                                        .interactiveSpring(
                                            response: 0.25,
                                            dampingFraction: 1.0,
                                            blendDuration: 0
                                        )
                                    ) {
                                        showingCharacterName =
                                            avatar.name
                                    }
                                } label: {
                                    avatar.characterAsset.cardIcon(75)
                                }
                            }
                        }
                    }
                    .padding(.vertical, 4)
                }
                HelpTextForScrollingOnDesktopComputer(.horizontal)
            }
            .fullScreenCover(item: $showingCharacterName) { characterName in
                CharacterDetailView(
                    account: account,
                    showingCharacterName: characterName,
                    playerDetail: playerDetail
                ) {
                    showingCharacterName = nil
                }
                .environment(\.colorScheme, .dark)
            }
        }
    }

    let account: AccountConfiguration

    var playerDetailStatus: DetailPortalViewModel
        .Status<(PlayerDetail, nextRefreshableDate: Date)> { detailPortalViewModel.playerDetailStatus }

    var body: some View {
        Section {
            switch playerDetailStatus {
            case .progress:
                ProgressView().id(UUID())
            case let .fail(error):
                ErrorView(account: account, error: error)
            case let .succeed((playerDetail, _)):
                if playerDetail.avatars.isEmpty {
                    Button(action: {
                        detailPortalViewModel.refresh()
                    }, label: {
                        Label {
                            Text(
                                playerDetail
                                    .basicInfo != nil
                                    ? "account.playerDetailResult.message.characterShowCaseClassified"
                                    : "account.playerDetailResult.message.enkaGotNulledResultFromCelestiaServer"
                            )
                            .foregroundColor(.secondary)
                            if let msg = playerDetail.enkaMessage {
                                Text(msg).foregroundColor(.secondary).controlSize(.small)
                            }
                        } icon: {
                            Image(systemSymbol: .xmarkCircle)
                                .foregroundColor(.red)
                        }
                    })
                } else {
                    DataFetchedView(playerDetail: playerDetail, account: account)
                }
            }
            AllAvatarNavigator(account: account, status: detailPortalViewModel.allAvatarInfoStatus)
        }
    }
}

// MARK: - AllAvatarNavigator

private struct AllAvatarNavigator: View {
    let account: AccountConfiguration
    var status: DetailPortalViewModel.Status<AllAvatarDetailModel>

    var body: some View {
        switch status {
        case .progress:
            VStack(alignment: .leading) {
                Text("app.detailPortal.allAvatar.title").bold()
                ProgressView()
            }
        case let .fail(error):
            VStack(alignment: .leading) {
                Text("app.detailPortal.allAvatar.title").bold()
                ErrorView(account: account, error: error)
            }
        case let .succeed(data):
            NavigationLink {
                AllAvatarListSheetView(status: status)
            } label: {
                VStack(alignment: .leading) {
                    Text("app.detailPortal.allAvatar.title").bold()
                    HStack(spacing: 3) {
                        ForEach(data.avatars.prefix(5), id: \.id) { avatar in
                            if let asset = avatar.asset {
                                asset.decoratedIcon(30)
                            }
                        }
                    }
                }
            }
        }
    }
}

// MARK: - LedgerDataNavigator

private struct LedgerDataNavigator: View {
    // MARK: Internal

    let account: AccountConfiguration
    let status: DetailPortalViewModel.Status<LedgerData>

    var body: some View {
        Group {
            switch status {
            case .progress:
                VStack(alignment: .leading) {
                    Text("app.detailPortal.ledger.title").bold()
                    ProgressView()
                }
            case let .fail(error):
                VStack(alignment: .leading) {
                    Text("app.detailPortal.ledger.title").bold()
                    ErrorView(account: account, error: error)
                }
            case let .succeed(data):
                AbyssInfoView(ledgerData: data)
            }
        }
    }

    // MARK: Private

    private struct AbyssInfoView: View {
        // MARK: Internal

        let ledgerData: LedgerData

        var body: some View {
            NavigationLink {
                LedgerView(data: ledgerData)
            } label: {
                VStack(alignment: .leading) {
                    HStack {
                        Text("app.detailPortal.ledger.title").bold()
                        Spacer()
                    }
                    HStack(spacing: 10) {
                        Image("UI_ItemIcon_Primogem")
                            .resizable()
                            .scaledToFit()
                            .frame(width: iconFrame, height: iconFrame)
                        Text(verbatim: "\(ledgerData.monthData.currentPrimogems)")
                            .font(.title)
                        Spacer()
                    }
                }
            }
        }

        // MARK: Private

        private let iconFrame: CGFloat = 40
    }
}

// MARK: - AbyssInfoNavigator

private struct AbyssInfoNavigator: View {
    // MARK: Internal

    let account: AccountConfiguration
    let status: DetailPortalViewModel.Status<SpiralAbyssDetail>

    var body: some View {
        Group {
            switch status {
            case .progress:
                VStack(alignment: .leading) {
                    Text("app.detailPortal.abyss.title").bold()
                    ProgressView()
                }
            case let .fail(error):
                VStack(alignment: .leading) {
                    Text("app.detailPortal.abyss.title").bold()
                    ErrorView(account: account, error: error)
                }
            case let .succeed(data):
                AbyssInfoView(abyssInfo: data)
            }
        }
    }

    // MARK: Private

    private struct AbyssInfoView: View {
        // MARK: Internal

        let abyssInfo: SpiralAbyssDetail

        var body: some View {
            NavigationLink {
                AbyssDetailDataDisplayView(data: abyssInfo)
            } label: {
                VStack(alignment: .leading) {
                    HStack {
                        Text("app.detailPortal.abyss.title").bold()
                        Spacer()
                    }
                    HStack(spacing: 10) {
                        Image("UI_Icon_Tower")
                            .resizable()
                            .scaledToFit()
                            .frame(width: iconFrame, height: iconFrame)
                        HStack(alignment: .lastTextBaseline, spacing: 0) {
                            Text(verbatim: "\(abyssInfo.maxFloor)")
                                .font(.title)
                            Spacer()
                            Text(verbatim: "✡︎ \(abyssInfo.totalStar)")
                                .font(.title)
                        }
                        Spacer()
                    }
                }
            }
        }

        // MARK: Private

        private let iconFrame: CGFloat = 40
    }
}

// MARK: - LedgerView

private struct LedgerView: View {
    // MARK: Internal

    let data: LedgerData

    var body: some View {
        List {
            Section {
                LabelWithDescription(
                    title: "原石收入",
                    memo: "较昨日",
                    icon: "UI_ItemIcon_Primogem",
                    mainValue: data.dayData.currentPrimogems,
                    previousValue: data.dayData.lastPrimogems
                )
                LabelWithDescription(
                    title: "摩拉收入",
                    memo: "较昨日",
                    icon: "UI_ItemIcon_Mora",
                    mainValue: data.dayData.currentMora,
                    previousValue: data.dayData.lastMora
                )
            } header: {
                HStack {
                    Text("detailPortal.todayAcquisition.title")
                    Spacer()
                    Text("\(data.date ?? "")")
                }
            } footer: {
                Text("仅统计充值途径以外获取的资源。数据存在延迟。")
                    .font(.footnote)
                    .multilineTextAlignment(.leading)
            }

            Section {
                let dayCountThisMonth = Calendar.current.dateComponents(
                    [.day],
                    from: Date()
                ).day
                LabelWithDescription(
                    title: "原石收入",
                    memo: "较上月同期",
                    icon: "UI_ItemIcon_Primogem",
                    mainValue: data.monthData.currentPrimogems,
                    previousValue: data.monthData.lastPrimogems / (dayCountThisMonth ?? 1)
                )
                LabelWithDescription(
                    title: "摩拉收入",
                    memo: "较上月同期",
                    icon: "UI_ItemIcon_Mora",
                    mainValue: data.monthData.currentMora,
                    previousValue: data.monthData.lastMora / (dayCountThisMonth ?? 1)
                )
            } header: {
                Text("本月账单 (\(data.dataMonth)月)")
            } footer: {
                HStack(alignment: .center) {
                    Spacer()
                    PieChartView(
                        values: data.monthData.groupBy.map { Double($0.num) },
                        names: data.monthData.groupBy
                            .map { (LedgerDataActions(rawValue: $0.actionId) ?? .byOther).localized },
                        formatter: { value in String(format: "%.0f", value) },
                        colors: [
                            .blue,
                            .green,
                            .orange,
                            .yellow,
                            .purple,
                            .gray,
                            .brown,
                            .cyan,
                        ],
                        backgroundColor: Color(UIColor.systemGroupedBackground),
                        widthFraction: 1,
                        innerRadiusFraction: 0.6
                    )
                    .frame(minWidth: 280, maxWidth: 280, minHeight: 600, maxHeight: 600)
                    .padding(.vertical)
                    .padding(.top)
                    Spacer()
                }
            }
        }
        .navigationTitle("原石摩拉账簿")
    }

    // MARK: Private

    private struct LabelWithDescription: View {
        let title: LocalizedStringKey
        let memo: LocalizedStringKey
        let icon: String
        let mainValue: Int
        let previousValue: Int?

        var delta: Int { mainValue - (previousValue ?? 0) }

        var body: some View {
            Label {
                VStack(alignment: .leading) {
                    HStack {
                        Text(title)
                        Spacer()
                        Text("\(mainValue)")
                    }
                    if previousValue != nil {
                        HStack {
                            Text(memo).foregroundColor(.secondary)
                            Spacer()
                            switch delta {
                            case 1...: Text("+\(delta)").foregroundStyle(.green)
                            default: Text("\(delta)").foregroundStyle(.red)
                            }
                        }.font(.footnote).opacity(0.8)
                    }
                }
            } icon: {
                Image(icon)
                    .resizable()
                    .scaledToFit()
            }
        }
    }
}

// MARK: - BasicInfoNavigator

private struct BasicInfoNavigator: View {
    // MARK: Internal

    let account: AccountConfiguration
    let status: DetailPortalViewModel.Status<BasicInfos>

    var body: some View {
        switch status {
        case .progress:
            VStack(alignment: .leading) {
                Text("app.detailPortal.basicInfo.title").bold()
                ProgressView()
            }
        case let .fail(error):
            VStack(alignment: .leading) {
                Text("app.detailPortal.basicInfo.title").bold()
                ErrorView(account: account, error: error)
            }
        case let .succeed(data):
            NavigationLink {
                BasicInfoView(data: data)
            } label: {
                VStack(alignment: .leading) {
                    Text("app.detailPortal.basicInfo.title").bold()
                    HStack(spacing: 10) {
                        Image("UI_ItemIcon_116006")
                            .resizable()
                            .scaledToFit()
                            .frame(width: iconFrame, height: iconFrame)
                        Text(
                            verbatim: "\(data.stats.luxuriousChestNumber)"
                        )
                        .font(.title)
                        Spacer()
                    }
                }
            }
        }
    }

    // MARK: Private

    private let iconFrame: CGFloat = 40
}

// MARK: - BasicInfoView

private struct BasicInfoView: View {
    // MARK: Internal

    let data: BasicInfos

    var body: some View {
        List {
            Section {
                DataDisplayView(label: "活跃天数", value: "\(data.stats.activeDayNumber)")
                DataDisplayView(label: "获得角色", value: "\(data.stats.avatarNumber)")
                DataDisplayView(label: "深境螺旋", value: data.stats.spiralAbyss)
                DataDisplayView(
                    label: "成就达成",
                    value: "\(data.stats.achievementNumber)"
                )
                DataDisplayView(
                    label: "解锁锚点",
                    value: "\(data.stats.wayPointNumber)"
                )
                DataDisplayView(
                    label: "解锁秘境",
                    value: "\(data.stats.domainNumber)"
                )
            }

            Section {
                DataDisplayView(label: "普通宝箱", value: "\(data.stats.commonChestNumber)")
                DataDisplayView(
                    label: "珍贵宝箱",
                    value: "\(data.stats.preciousChestNumber)"
                )
                DataDisplayView(
                    label: "精致宝箱",
                    value: "\(data.stats.exquisiteChestNumber)"
                )
                DataDisplayView(
                    label: "华丽宝箱",
                    value: "\(data.stats.luxuriousChestNumber)"
                )
            }
            Section {
                DataDisplayView(
                    symbol: Image("UI_ItemIcon_107001"),
                    label: "风神瞳",
                    value: "\(data.stats.anemoculusNumber)"
                )
                DataDisplayView(
                    symbol: Image("UI_ItemIcon_107003"),
                    label: "岩神瞳",
                    value: "\(data.stats.geoculusNumber)"
                )
                DataDisplayView(
                    symbol: Image("UI_ItemIcon_107014"),
                    label: "雷神瞳",
                    value: "\(data.stats.electroculusNumber)"
                )
                DataDisplayView(
                    symbol: Image("UI_ItemIcon_107017"),
                    label: "草神瞳",
                    value: "\(data.stats.dendroculusNumber)"
                )
                DataDisplayView(
                    symbol: Image("Item_Hydroculus"),
                    label: "水神瞳",
                    value: "\(data.stats.hydroculusNumber)"
                )
            }
            Section {
                ForEach(data.worldExplorations.sorted {
                    $0.id < $1.id
                }, id: \.id) { worldData in
                    WorldExplorationView(worldData: worldData)
                }
            }
        }
        .navigationTitle("app.detailPortal.basicInfo.title")
    }

    // MARK: Private

    private struct DataDisplayView: View {
        // MARK: Lifecycle

        init(symbol: Image, label: LocalizedStringKey, value: String) {
            self.symbol = symbol
            self.label = label
            self.value = value
        }

        init(label: LocalizedStringKey, value: String) {
            self.symbol = nil
            self.label = label
            self.value = value
        }

        // MARK: Internal

        let symbol: Image?
        let label: LocalizedStringKey
        let value: String

        var body: some View {
            if let symbol {
                Label {
                    HStack {
                        Text(label)
                        Spacer()
                        Text(verbatim: value)
                    }
                } icon: {
                    symbol.resizable().scaledToFit()
                        .frame(height: 30)
                }
            } else {
                HStack {
                    Text(label)
                    Spacer()
                    Text(verbatim: value)
                }
            }
        }
    }

    private struct WorldExplorationView: View {
        struct WorldDataLabel: View {
            @Environment(\.colorScheme)
            private var colorScheme
            let worldData: BasicInfos.WorldExploration

            var body: some View {
                Label {
                    Text(worldData.name)
                    Spacer()
                    Text(calculatePercentage(
                        value: Double(worldData.explorationPercentage) /
                            Double(1000)
                    ))
                } icon: {
                    if let url = URL(string: worldData.icon) {
                        AsyncImage(url: url, content: { image in
                            switch colorScheme {
                            case .dark:
                                image.resizable().scaledToFit()
                                    .frame(height: 30)
                            case .light:
                                image.resizable().scaledToFit()
                                    .frame(height: 30)
                                    .colorInvert()
                            @unknown default:
                                image.resizable().scaledToFit()
                                    .frame(height: 30)
                            }
                        }) {
                            ProgressView()
                        }
                    }
                }
            }

            func calculatePercentage(value: Double) -> String {
                let formatter = NumberFormatter()
                formatter.numberStyle = .percent
                return formatter.string(from: value as NSNumber) ?? "Error"
            }
        }

        let worldData: BasicInfos.WorldExploration

        var body: some View {
            if !worldData.offerings.isEmpty {
                DisclosureGroup {
                    ForEach(worldData.offerings, id: \.name) { offering in
                        Label {
                            Text(offering.name)
                            Spacer()
                            Text("Lv. \(offering.level)")
                        } icon: {
                            if let url = URL(string: offering.icon) {
                                AsyncImage(url: url, content: { image in
                                    image.resizable().scaledToFit().frame(height: 30)
                                }) {
                                    ProgressView()
                                }
                            }
                        }
                    }
                } label: {
                    WorldDataLabel(worldData: worldData)
                }
            } else {
                WorldDataLabel(worldData: worldData)
            }
        }
    }
}

// MARK: - ErrorView

private struct ErrorView: View {
    @EnvironmentObject
    private var detailPortalViewModel: DetailPortalViewModel

    let account: AccountConfiguration
    let error: Error

    var body: some View {
        if let miHoYoAPIError = error as? MiHoYoAPIError,
           case .verificationNeeded = miHoYoAPIError {
            VerificationNeededView(account: account) {
                detailPortalViewModel.refresh()
            }
        } else {
            Button {
                detailPortalViewModel.refresh()
            } label: {
                Label {
                    HStack {
                        Text(error.localizedDescription)
                            .foregroundStyle(.primary)
                        Spacer()
                        Image(systemSymbol: .arrowClockwiseCircle)
                    }
                } icon: {
                    Image(systemSymbol: .exclamationmarkCircle)
                        .foregroundStyle(.red)
                }
            }
        }
    }
}

// MARK: - VerificationNeededView

private struct VerificationNeededView: View {
    // MARK: Internal

    let account: AccountConfiguration
    let completion: () -> ()

    var body: some View {
        Button {
            status = .progressing
            popVerificationWebSheet()
        } label: {
            Label {
                Text("account.test.verify.button")
            } icon: {
                Image(systemSymbol: .exclamationmarkTriangle)
                    .foregroundStyle(.yellow)
            }
        }
        .sheet(item: $sheetItem, content: { item in
            switch item {
            case let .gotVerification(verification):
                NavigationView {
                    GeetestValidateView(
                        challenge: verification.challenge,
                        gt: verification.gt,
                        completion: { validate in
                            status = .pending
                            verifyValidate(challenge: verification.challenge, validate: validate)
                            sheetItem = nil
                        }
                    )
                    .toolbar {
                        ToolbarItem(placement: .navigationBarLeading) {
                            Button("sys.cancel") {
                                sheetItem = nil
                            }
                        }
                    }
                    .navigationTitle("account.test.verify.web_sheet.title")
                }
                .navigationViewStyle(.stack)
            }
        })
        if case let .fail(error) = status {
            Text("Error: \(error.localizedDescription)")
        }
    }

    func popVerificationWebSheet() {
        Task(priority: .userInitiated) {
            do {
                let verification = try await MiHoYoAPI.createVerification(
                    cookie: account.safeCookie,
                    deviceFingerPrint: account.deviceFingerPrint, deviceId: account.safeUuid
                )
                status = .gotVerification(verification)
                sheetItem = .gotVerification(verification)
            } catch {
                status = .fail(error)
            }
        }
    }

    func verifyValidate(challenge: String, validate: String) {
        Task {
            do {
                _ = try await MiHoYoAPI.verifyVerification(
                    challenge: challenge,
                    validate: validate,
                    cookie: account.safeCookie,
                    deviceFingerPrint: account.deviceFingerPrint, deviceId: account.safeUuid
                )
                completion()
            } catch {
                status = .fail(error)
            }
        }
    }

    // MARK: Private

    private enum Status: CustomStringConvertible {
        case pending
        case progressing
        case gotVerification(Verification)
        case fail(Error)

        // MARK: Internal

        var description: String {
            switch self {
            case let .fail(error):
                return "ERROR: \(error.localizedDescription)"
            case .progressing:
                return "gettingVerification"
            case let .gotVerification(verification):
                return "Challenge: \(verification.challenge)"
            case .pending:
                return "PENDING"
            }
        }
    }

    private enum SheetItem: Identifiable {
        case gotVerification(Verification)

        // MARK: Internal

        var id: Int {
            switch self {
            case let .gotVerification(verification):
                return verification.challenge.hashValue
            }
        }
    }

    @State
    private var status: Status = .progressing

    @State
    private var sheetItem: SheetItem?
}
