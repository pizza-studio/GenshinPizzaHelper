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

final private class DetailPortalViewModel: ObservableObject {
    // MARK: Lifecycle

    init() {
        let request = AccountConfiguration.fetchRequest()
        request.sortDescriptors = [.init(keyPath: \AccountConfiguration.priority, ascending: false)]
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
    var selectedAccount: AccountConfiguration? {
        didSet { refresh() }
    }

    @Published
    var playerDetailStatus: Status<(PlayerDetail, nextRefreshableDate: Date)> = .progress(nil)

    @Published
    var basicInfoStatus: Status<BasicInfos> = .progress(nil)

    @Published
    var spiralAbyssDetailStatus: Status<SpiralAbyssDetail> = .progress(nil)

    func refresh() {
        fetchPlayerDetail()
        fetchBasicInfo()
        fetchSpiralAbyssInfo()
        detailPortalRefreshSubject.send(())
    }

    func fetchPlayerDetail() {
        guard let selectedAccount else { return }
        if case let .succeed((_, refreshableDate)) = playerDetailStatus {
            guard Date() > refreshableDate else { return }
        }
        if case let .progress(task) = playerDetailStatus { task?.cancel() }
        let task = Task {
            do {
                let result = try await API.OpenAPIs.fetchPlayerDetail(
                    selectedAccount.safeUid,
                    dateWhenNextRefreshable: nil
                )
                guard let charLoc = Enka.Sputnik.shared.charLoc else {
                    throw PlayerDetail.PlayerDetailError.failToGetLocalizedDictionary
                }
                guard let charMap = Enka.Sputnik.shared.charMap else {
                    throw PlayerDetail.PlayerDetailError.failToGetCharacterDictionary
                }
                DispatchQueue.main.async {
                    withAnimation {
                        self.playerDetailStatus = .succeed((
                            PlayerDetail(
                                PlayerDetailFetchModel: result,
                                localizedDictionary: charLoc,
                                characterMap: charMap
                            ),
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
            ascending: false
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
                Button(action: {
                    detailPortalViewModel.refresh()
                }, label: {
                    Label {
                        Text(error.localizedDescription)
                    } icon: {
                        Image(systemSymbol: .xmarkCircle)
                            .foregroundColor(.red)
                    }
                })
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
            AllAvatarNavigator(account: account)
        }
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
                VStack {
                    Text("app.detailPortal.abyss.title").bold()
                    ProgressView()
                }
            case let .fail(error):
                VStack {
                    Text("app.detailPortal.abyss.title").bold()
                    Text(error.localizedDescription)
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
                VStack {
                    Text("app.detailPortal.abyss.title").bold()
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
                    }
                }
            }
        }

        // MARK: Private

        private let iconFrame: CGFloat = 40
    }
}

// MARK: - AllAvatarNavigator

// @available(iOS 15.0, *)
// struct DetailPortalView: View {
//    @EnvironmentObject
//    var viewModel: ViewModel
//    @Environment(\.scenePhase)
//    var scenePhase
//    var accounts: [Account] { viewModel.accounts }
//    @Default(.detailPortalViewShowingAccountUUIDString)
//    var showingAccountUUIDString: String? {
//        didSet {
//            if let account = account {
//                viewModel.refreshCostumeMap(for: account)
//            }
//        }
//    }
//
//    var account: Account? {
//        accounts.first { account in
//            (account.config.uuid?.uuidString ?? "123") ==
//                showingAccountUUIDString
//        }
//    }
//
//    var showingCharacterDetail: Bool {
//        viewModel.showCharacterDetailOfAccount != nil
//    }
//
//    @State
//    private var sheetType: SheetTypesForDetailPortalView?
//
//    var thisAbyssData: SpiralAbyssDetail? { account?.spiralAbyssDetail?.this }
//    var lastAbyssData: SpiralAbyssDetail? { account?.spiralAbyssDetail?.last }
//    @State
//    private var abyssDataViewSelection: AbyssDataType = .thisTerm
//
//    var ledgerDataResult: LedgerDataFetchResult? { account?.ledgeDataResult }
//
//    var animation: Namespace.ID
//
//    @State
//    private var askAllowAbyssDataCollectionAlert: Bool = false
//
//    @StateObject
//    private var orientation = ThisDevice.DeviceOrientation()
//
//    var body: some View {
//        NavigationView {
//            List {
//                accountSection()
//                playerDetailSection()
//                abyssAndPrimogemNavigator()
//                toolsSection()
//            }
//            .listStyle(.insetGrouped)
//            .sectionSpacing(UIFont.systemFontSize)
//            .environmentObject(orientation)
//            .refreshable {
//                withAnimation {
//                    DispatchQueue.main.async {
//                        if let account = account {
//                            viewModel.refreshPlayerDetail(for: account)
//                        }
//                        viewModel.refreshAbyssAndBasicInfo()
//                        viewModel.refreshLedgerData()
//                    }
//                }
//            }
//            .onAppear {
//                if !accounts.isEmpty, showingAccountUUIDString == nil {
//                    showingAccountUUIDString = accounts.first?.config.uuid?
//                        .uuidString
//                }
//            }
//            .sheet(item: $sheetType) { type in
//                switch type {
//                case .myLedgerSheet:
//                    ledgerSheetView()
//                case .mySpiralAbyss:
//                    spiralAbyssSheetView()
//                case .loginAccountAgainView:
//                    Group {
//                        if let account = account, let firstMatchedIndex = viewModel.accounts.firstIndex(of: account),
//                           let binding = Binding(
//                               $viewModel
//                                   .accounts[firstMatchedIndex]
//                                   .config.cookie
//                           ) {
//                            GetLedgerCookieWebView(
//                                title: String(
//                                    format: NSLocalizedString(
//                                        "请登录「%@」",
//                                        comment: ""
//                                    ),
//                                    viewModel.accounts[firstMatchedIndex].config.name ?? ""
//                                ),
//                                sheetType: $sheetType,
//                                cookie: binding,
//                                region: viewModel
//                                    .accounts[firstMatchedIndex]
//                                    .config.server.region
//                            )
//                        }
//                    }
//                    .onDisappear {
//                        viewModel.refreshLedgerData()
//                    }
//                case .allAvatarList:
//                    allAvatarListView()
//                case .gachaAnalysis:
//                    NavigationView {
//                        GachaView()
//                            .toolbar {
//                                ToolbarItem(placement: .navigationBarLeading) {
//                                    Button("完成") {
//                                        sheetType = nil
//                                    }
//                                }
//                            }
//                    }
//                case .rankedSpiralAbyss:
//                    NavigationView {
//                        AbyssDataCollectionView()
//                            .toolbar {
//                                ToolbarItem(placement: .navigationBarLeading) {
//                                    Button("完成") {
//                                        sheetType = nil
//                                    }
//                                }
//                            }
//                    }
//                }
//            }
//            .onChange(of: account) { newAccount in
//                withAnimation {
//                    DispatchQueue.main.async {
//                        if let newAccount = newAccount {
//                            viewModel.refreshPlayerDetail(for: newAccount)
//                        }
//                    }
//                }
//            }
//            .toolViewNavigationTitleInIOS15()
//            .onAppear { checkIfAllowAbyssDataCollection() }
//            .alert(
//                "是否允许我们收集您的深渊数据？",
//                isPresented: $askAllowAbyssDataCollectionAlert
//            ) {
//                Button("不允许", role: .destructive) {
//                    Defaults[.allowAbyssDataCollection] = false
//                    Defaults[.hasAskedAllowAbyssDataCollection] = true
//                }
//                Button("允许", role: .cancel, action: {
//                    Defaults[.allowAbyssDataCollection] = true
//                    Defaults[.hasAskedAllowAbyssDataCollection] = true
//                })
//            } message: {
//                Text(
//                    "我们希望收集您已拥有的角色和在攻克深渊时使用的角色。如果您同意我们使用您的数据，您将可以在App内查看我们实时汇总的深渊角色使用率、队伍使用率等情况。更多相关问题，请查看深渊统计榜单页面右上角的FAQ。"
//                )
//            }
//            .onChange(of: scenePhase, perform: { newPhase in
//                switch newPhase {
//                case .active:
//                    withAnimation {
//                        DispatchQueue.main.async {
//                            if let account = account {
//                                viewModel.refreshPlayerDetail(for: account)
//                            }
//                            viewModel.refreshAbyssAndBasicInfo()
//                            viewModel.refreshLedgerData()
//                        }
//                    }
//                default:
//                    break
//                }
//            })
//        }
//        .navigationViewStyle(.stack)
//    }
//
//    @ViewBuilder
//    func accountSection() -> some View {
//        if let account = account {
//            if let playerDetail = try? account.playerDetailResult?.get() {
//                Section {
//                    HStack(spacing: 0) {
//                        HStack {
//                            if let basicInfo = playerDetail.basicInfo {
//                                basicInfo.decoratedIcon(64)
//                            } else {
//                                CharacterAsset.Paimon.decoratedIcon(64)
//                            }
//                            Spacer()
//                        }
//                        .frame(width: 74)
//                        .corneredTag(
//                            "detailPortal.player.adventureRank.short:\(playerDetail.basicInfo?.level.description ?? "213")",
//                            alignment: .bottomTrailing,
//                            textSize: 12
//                        )
//                        VStack(alignment: .leading) {
//                            HStack(spacing: 10) {
//                                VStack(alignment: .leading) {
//                                    Text(playerDetail.basicInfo?.nickname ?? "ENKA ERROR")
//                                        .font(.title3)
//                                        .bold()
//                                        .padding(.top, 5)
//                                        .lineLimit(1)
//                                    Text(
//                                        playerDetail.basicInfo?
//                                            .signature ??
//                                            "↑: \(playerDetail.enkaMessage ?? "UNKNOWN_ENKA_ERROR")"
//                                    )
//                                    .foregroundColor(.secondary)
//                                    .font(.footnote)
//                                    .lineLimit(2)
//                                    .fixedSize(
//                                        horizontal: false,
//                                        vertical: true
//                                    )
//                                }
//                                Spacer()
//                                selectAccountManuButton()
//                            }
//                        }
//                    }
//                } footer: {
//                    HStack {
//                        Text("UID: \(account.config.uid ?? "UID_NULLED")")
//                        Spacer()
//                        let worldLevelTitle = "detailPortal.player.worldLevel".localized
//                        Text("\(worldLevelTitle): \(playerDetail.basicInfo?.worldLevel ?? 213)")
//                    }
//                }
//            } else {
//                Section {
//                    VStack {
//                        HStack {
//                            Text(account.config.name ?? "")
//                            Spacer()
//                            selectAccountManuButton()
//                        }
//                        Text("UID: \(account.config.uid ?? "")")
//                            .foregroundColor(.secondary)
//                            .font(.footnote)
//                            .lineLimit(1)
//                            .fixedSize(
//                                horizontal: false,
//                                vertical: true
//                            )
//                    }
//                }
//            }
//        } else if accounts.isEmpty {
//            NavigationLink(destination: AddAccountView()) {
//                Label("settings.account.pleaseAddAccountFirst", systemSymbol: .plusCircle)
//            }
//        } else {
//            Menu {
//                ForEach(accounts, id: \.config.id) { account in
//                    Button(account.config.name ?? "Name Error") {
//                        showingAccountUUIDString = account.config.uuid?
//                            .uuidString
//                    }
//                }
//            } label: {
//                Label("detailPortal.prompt.pleaseSelectAccount", systemSymbol: .arrowLeftArrowRightCircle)
//            }
//        }
//    }
//
//    @ViewBuilder
//    func playerDetailSection() -> some View {
//        if let account = account {
//            if let result = account.playerDetailResult {
//                let fetchedDetail = try? result.get()
//                switch result {
//                case .success:
//                    if let fetchedDetail = fetchedDetail {
//                        // 此时拿到的资料可能是以 HTTP 200 送过来的错误资料。总之交给 dataFetchedView() 处理。
//                        dataFetchedView(fetchedDetail)
//                    } else {
//                        dataFetchFailedView(
//                            error: PlayerDetail.PlayerDetailError
//                                .failToGetCharacterData(message: "account.playerDetailResult.get.returned.nil")
//                        )
//                    }
//                case let .failure(error):
//                    dataFetchFailedView(error: error)
//                }
//            } else if !account.fetchPlayerDetailComplete {
//                loadingView()
//            }
//        }
//        if (try? account?.playerDetailResult?.get()) == nil {
//            Section { allAvatarNavigator() }
//        }
//    }
//
//    @ViewBuilder
//    func allAvatarListView() -> some View {
//        if let account = account {
//            NavigationView {
//                AllAvatarListSheetView(account: account, sheetType: $sheetType)
//            }
//        }
//    }
//
//    @ViewBuilder
//    func dataFetchedView(_ playerDetail: PlayerDetail) -> some View {
//        Section {
//            VStack {
//                if playerDetail.avatars.isEmpty {
//                    Text(
//                        playerDetail
//                            .basicInfo != nil
//                            ? "account.playerDetailResult.message.characterShowCaseClassified"
//                            : "account.playerDetailResult.message.enkaGotNulledResultFromCelestiaServer"
//                    )
//                    .foregroundColor(.secondary)
//                    if let msg = playerDetail.enkaMessage {
//                        Text(msg).foregroundColor(.secondary).controlSize(.small)
//                    }
//                } else {
//                    ScrollView(.horizontal) {
//                        HStack {
//                            ForEach(
//                                playerDetail.avatars,
//                                id: \.name
//                            ) { avatar in
//                                avatar.characterAsset.cardIcon(75)
//                                    .onTapGesture {
//                                        simpleTaptic(type: .medium)
//                                        withAnimation(
//                                            .interactiveSpring(
//                                                response: 0.25,
//                                                dampingFraction: 1.0,
//                                                blendDuration: 0
//                                            )
//                                        ) {
//                                            viewModel
//                                                .showingCharacterName =
//                                                avatar.name
//                                            viewModel
//                                                .showCharacterDetailOfAccount =
//                                                account
//                                        }
//                                    }
//                            }
//                        }
//                        .padding(.vertical, 4)
//                    }.onAppear {
//                        viewModel.refreshCostumeMap()
//                    }
//                }
//                if !playerDetail.avatars.isEmpty {
//                    HelpTextForScrollingOnDesktopComputer(.horizontal)
//                }
//                allAvatarNavigator()
//            }
//        }
//    }
//
//    @ViewBuilder
//    func abyssAndPrimogemNavigator() -> some View {
//        if let account = account {
//            if let basicInfo: BasicInfos = account.basicInfo {
//                if OS.type == .macOS || ThisDevice.isSmallestHDScreenPhone || ThisDevice.isThinnestSplitOnPad {
//                    // 哀凤 SE2 / SE3 开启荧幕放大模式之后，这个版面很难保证排版完整性、需要专门重新做这份。
//                    abyssAndPrimogemNavigatorViewLegacy(accountBasicInfo: basicInfo)
//                } else {
//                    abyssAndPrimogemNavigatorView(accountBasicInfo: basicInfo)
//                }
//            } else if account.fetchPlayerDetailComplete {
//                if let bindingAccount = $viewModel.accounts.first(where: { $0.wrappedValue == account }) {
//                    NavigationLink {
//                        AccountDetailView(account: bindingAccount)
//                    } label: {
//                        HStack {
//                            Image(
//                                systemName: "exclamationmark.arrow.triangle.2.circlepath"
//                            )
//                            .frame(width: 20, height: 20)
//                            .foregroundColor(.red)
//                            Text(
//                                "detailPortal.errorMessage.anotherVerificationAttemptRequiredToSeeSpiralAbyssHistory"
//                            )
//                            .font(.footnote)
//                        }
//                    }
//                }
//            }
//        } else {
//            if accounts.isEmpty {
//                Text("detailPortal.errorMessage.noAccountAvailableForAbyssDisplay").font(.footnote)
//            } else {
//                Text("detailPortal.errorMessage.plzChooseAnAccountForAbyssDisplay").font(.footnote)
//            }
//        }
//    }
//
//    @ViewBuilder
//    func abyssAndPrimogemNavigatorViewLegacy(accountBasicInfo basicInfo: BasicInfos) -> some View {
//        Section {
//            Button {
//                simpleTaptic(type: .medium)
//                sheetType = .mySpiralAbyss
//            } label: {
//                Label(
//                    title: {
//                        HStack {
//                            // try! account?.playerDetailResult?.get().basicInfo.towerFloorLevelSimplified ??
//                            let textString = basicInfo.stats.spiralAbyss.description
//                            Text(textString).fontWeight(.heavy)
//                            Spacer()
//                            if let thisAbyssData = thisAbyssData {
//                                Text("✡︎ \(thisAbyssData.totalStar)").font(.footnote)
//                            }
//                        }
//                        .foregroundStyle(Color.primary)
//                    },
//                    icon: { Image("UI_Icon_Tower").resizable().frame(width: 30, height: 30) }
//                )
//            }
//            if let result = ledgerDataResult {
//                switch result {
//                case let .success(data):
//                    Button {
//                        simpleTaptic(type: .medium)
//                        sheetType = .myLedgerSheet
//                    } label: {
//                        Label(
//                            title: {
//                                HStack {
//                                    Text(data.dayData.currentPrimogems.description).fontWeight(.heavy)
//                                    Spacer()
//                                    Text("\(data.dayData.currentMora) 🪙").font(.footnote)
//                                }.foregroundStyle(Color.primary)
//                            },
//                            icon: {
//                                Image("UI_ItemIcon_Primogem").resizable().frame(width: 30, height: 30)
//                            }
//                        )
//                    }
//                case let .failure(error):
//                    Button {
//                        switch error {
//                        case .notLoginError:
//                            simpleTaptic(type: .medium)
//                            sheetType = .loginAccountAgainView
//                        default:
//                            viewModel.refreshLedgerData()
//                        }
//                    } label: {
//                        Label(
//                            title: {
//                                switch error {
//                                case .notLoginError:
//                                    (
//                                        HStack {
//                                            Text("[\("detailPortal.todayAcquisition.title".localized)] ") +
//                                                Text("detailPortal.todayAcquisition.reloginRequiredNotice")
//                                        }.foregroundStyle(Color.primary)
//                                    )
//                                    .font(.footnote)
//                                default:
//                                    Text(error.description)
//                                        .font(.footnote)
//                                        .foregroundStyle(Color.primary)
//                                }
//                            },
//                            icon: {
//                                Image(systemSymbol: .exclamationmarkArrowTriangle2Circlepath)
//                                    .foregroundColor(.red)
//                                    .frame(width: 30, height: 30)
//                            }
//                        )
//                    }
//                }
//            }
//        }
//    }
//
//    @ViewBuilder
//    func abyssAndPrimogemNavigatorView(accountBasicInfo basicInfo: BasicInfos) -> some View {
//        Section {
//            HStack(spacing: 30) {
//                Spacer()
//                VStack {
//                    VStack(spacing: 7) {
//                        AbyssTextLabel(
//                            text: "\(basicInfo.stats.spiralAbyss)"
//                        )
//                        if let thisAbyssData = thisAbyssData {
//                            HStack {
//                                AbyssStarIcon()
//                                    .frame(width: 30, height: 30)
//                                Text("\(thisAbyssData.totalStar)")
//                                    .font(.system(.body, design: .rounded))
//                            }
//                        } else {
//                            ProgressView()
//                                .onTapGesture {
//                                    viewModel.refreshAbyssAndBasicInfo()
//                                }
//                        }
//                    }
//                    .frame(height: 100)
//                }
//                .frame(maxWidth: .infinity)
//                .onTapGesture {
//                    simpleTaptic(type: .medium)
//                    sheetType = .mySpiralAbyss
//                }
//                Divider()
//                VStack {
//                    if let result = ledgerDataResult {
//                        VStack(spacing: 10) {
//                            switch result {
//                            case let .success(data):
//                                PrimogemTextLabel(
//                                    primogem: data.dayData
//                                        .currentPrimogems
//                                )
//                                MoraTextLabel(
//                                    mora: data.dayData
//                                        .currentMora
//                                )
//                            case let .failure(error):
//                                Image(
//                                    systemName: "exclamationmark.arrow.triangle.2.circlepath"
//                                )
//                                .foregroundColor(.red)
//                                switch error {
//                                case .notLoginError:
//                                    (
//                                        Text("[\("detailPortal.todayAcquisition.title".localized)]\n") +
//                                            Text("detailPortal.todayAcquisition.reloginRequiredNotice")
//                                    )
//                                    .font(.footnote)
//                                    .multilineTextAlignment(.center)
//                                default:
//                                    Text(error.description)
//                                }
//                            }
//                        }
//                        .frame(height: 105)
//                    } else {
//                        ProgressView()
//                            .frame(height: 100)
//                    }
//                }
//                .frame(maxWidth: .infinity)
//                .onTapGesture {
//                    if let result = ledgerDataResult {
//                        switch result {
//                        case .success:
//                            simpleTaptic(type: .medium)
//                            sheetType = .myLedgerSheet
//                        case let .failure(error):
//                            switch error {
//                            case .notLoginError:
//                                simpleTaptic(type: .medium)
//                                sheetType = .loginAccountAgainView
//                            default:
//                                viewModel.refreshLedgerData()
//                            }
//                        }
//                    }
//                }
//                Spacer()
//            }
//        }
//        .listRowInsets(.init(top: 10, leading: 0, bottom: 10, trailing: 0))
//    }
//
//    @ViewBuilder
//    func ledgerSheetView() -> some View {
//        if let data = try? ledgerDataResult?.get() {
//            LedgerSheetView(
//                data: data,
//                sheetType: $sheetType
//            )
//        }
//    }
//
//    @ViewBuilder
//    func spiralAbyssSheetView() -> some View {
//        if let thisAbyssData = thisAbyssData,
//           let lastAbyssData = lastAbyssData {
//            NavigationView {
//                VStack {
//                    Picker("", selection: $abyssDataViewSelection) {
//                        ForEach(AbyssDataType.allCases, id: \.self) { option in
//                            Text(option.rawValue.localized)
//                        }
//                    }
//                    .pickerStyle(.segmented)
//                    .padding()
//                    switch abyssDataViewSelection {
//                    case .thisTerm:
//                        AbyssDetailDataDisplayView(
//                            data: thisAbyssData
//                        )
//                    case .lastTerm:
//                        AbyssDetailDataDisplayView(
//                            data: lastAbyssData
//                        )
//                    }
//                }
//                .navigationTitle("深境螺旋详情")
//                .navigationBarTitleDisplayMode(.inline)
//                .toolbar {
//                    ToolbarItem(placement: .navigationBarTrailing) {
//                        Button("完成") {
//                            sheetType = nil
//                        }
//                    }
//                }
//                .toolbarSavePhotoButtonInIOS16(
//                    title: String(
//                        localized: "保存\(thisAbyssData.floors.last?.index ?? 12)层的深渊数据"
//                    ),
//                    placement: .navigationBarLeading
//                ) {
//                    Group {
//                        switch abyssDataViewSelection {
//                        case .thisTerm:
//                            AbyssShareView(
//                                data: thisAbyssData
//                            )
//                            .environment(
//                                \.locale,
//                                .init(identifier: Locale.current.identifier)
//                            )
//                        case .lastTerm:
//                            AbyssShareView(
//                                data: lastAbyssData
//                            )
//                            .environment(
//                                \.locale,
//                                .init(identifier: Locale.current.identifier)
//                            )
//                        }
//                    }
//                }
//            }
//        } else {
//            ProgressView()
//        }
//    }
//
//    @ViewBuilder
//    func selectAccountManuButton() -> some View {
//        if accounts.count > 1 {
//            Menu {
//                ForEach(accounts, id: \.config.id) { account in
//                    Button(account.config.name ?? "Name Error") {
//                        withAnimation {
//                            showingAccountUUIDString = account.config.uuid?.uuidString
//                        }
//                    }
//                }
//            } label: {
//                Image(systemSymbol: .arrowLeftArrowRightCircle)
//                    .font(.title2)
//            }
//        } else {
//            EmptyView()
//        }
//    }
//
//    @ViewBuilder
//    func dataFetchFailedView(error: PlayerDetail.PlayerDetailError) -> some View {
//        Section {
//            HStack {
//                Spacer()
//                Image(systemSymbol: .exclamationmarkArrowTriangle2Circlepath)
//                    .foregroundColor(.red)
//                    .onTapGesture {
//                        if let account = account {
//                            viewModel.refreshPlayerDetail(for: account)
//                        }
//                    }
//                Spacer()
//            }
//        } footer: {
//            switch error {
//            case .failToGetLocalizedDictionary:
//                Text("fail to get localized dictionary")
//            case .failToGetCharacterDictionary:
//                Text("fail to get character dictionary")
//            case let .failToGetCharacterData(message):
//                Text(message)
//            case let .refreshTooFast(dateWhenRefreshable):
//                if dateWhenRefreshable.timeIntervalSinceReferenceDate - Date()
//                    .timeIntervalSinceReferenceDate > 0 {
//                    let second = Int(
//                        dateWhenRefreshable
//                            .timeIntervalSinceReferenceDate - Date()
//                            .timeIntervalSinceReferenceDate
//                    )
//                    Text(String(localized: "请稍等\(second)秒再刷新"))
//                } else {
//                    Text("请下滑刷新")
//                }
//            }
//        }
//    }
//
//    @ViewBuilder
//    func loadingView() -> some View {
//        Section {
//            HStack {
//                Spacer()
//                ProgressView()
//                Spacer()
//            }
//        }
//    }
//
//    @ViewBuilder
//    func allAvatarNavigator() -> some View {
//        if let basicInfo = account?.basicInfo {
//            AllAvatarNavigator(
//                basicInfo: basicInfo,
//                sheetType: $sheetType
//            )
//        }
//    }
//
//    @ViewBuilder
//    func toolsSection() -> some View {
//        Section {
//            // 这里有一个 SwiftUI 故障导致的陈年 Bug。
//            // 如果在这个画面存在任何 Navigation Link 的话，
//            // 方向键会触发这个画面在 macOS 系统下的异常画面切换行为。
//            // 所以这里限制 macOS 在此处以 sheet 的形式呈现这两个画面。
//            switch OS.type {
//            case .iPadOS, .macOS:
//                Button {
//                    sheetType = .gachaAnalysis
//                } label: {
//                    Label {
//                        Text("祈愿分析")
//                            .foregroundColor(.primary)
//                    } icon: {
//                        Image("UI_MarkPoint_SummerTimeV2_Dungeon_04").resizable()
//                            .scaledToFit()
//                    }
//                }
//                Button {
//                    sheetType = .rankedSpiralAbyss
//                } label: {
//                    Label {
//                        Text("深渊统计榜单")
//                            .foregroundColor(.primary)
//                    } icon: {
//                        Image("UI_MarkTower_EffigyChallenge_01").resizable()
//                            .scaledToFit()
//                    }
//                }
//            default:
//                NavigationLink(destination: GachaView()) {
//                    Label {
//                        Text("祈愿分析")
//                    } icon: {
//                        Image("UI_MarkPoint_SummerTimeV2_Dungeon_04").resizable()
//                            .scaledToFit()
//                    }
//                }
//                NavigationLink(destination: AbyssDataCollectionView()) {
//                    Label {
//                        Text("深渊统计榜单")
//                    } icon: {
//                        Image("UI_MarkTower_EffigyChallenge_01").resizable()
//                            .scaledToFit()
//                    }
//                }
//            }
//        }
//    }
//
//    func checkIfAllowAbyssDataCollection() {
//        if !Defaults[.hasAskedAllowAbyssDataCollection], account != nil {
//            askAllowAbyssDataCollectionAlert = true
//        }
//    }
// }
//
//// MARK: - SheetTypesForDetailPortalView
//
// enum SheetTypesForDetailPortalView: Identifiable {
//    case mySpiralAbyss
//    case myLedgerSheet
//    case loginAccountAgainView
//    case allAvatarList
//    case gachaAnalysis
//    case rankedSpiralAbyss
//
//    // MARK: Internal
//
//    var id: Int {
//        hashValue
//    }
// }
//
//// MARK: - AbyssDataType
//
// private enum AbyssDataType: String, CaseIterable {
//    case thisTerm = "本期深渊"
//    case lastTerm = "上期深渊"
// }
//
//// MARK: - LedgerSheetView
//
// @available(iOS 15.0, *)
// private struct LedgerSheetView: View {
//    // MARK: Internal
//
//    let data: LedgerData
//    @Binding
//    var sheetType: SheetTypesForDetailPortalView?
//
//    var body: some View {
//        NavigationView {
//            List {
//                LedgerSheetViewList(data: data)
//            }
//            .sectionSpacing(UIFont.systemFontSize)
//            .navigationBarTitleDisplayMode(.inline)
//            .toolbar {
//                ToolbarItem(placement: .navigationBarTrailing) {
//                    Button("完成") {
//                        sheetType = nil
//                    }
//                }
//                ToolbarItem(placement: .principal) {
//                    Text("原石摩拉账簿").bold()
//                }
//            }
//            .toolbarSavePhotoButtonInIOS16(
//                title: "保存本月原石账簿图片".localized,
//                placement: .navigationBarLeading
//            ) {
//                LedgerShareView(data: data)
//                    .environment(
//                        \.locale,
//                        .init(identifier: Locale.current.identifier)
//                    )
//            }
//        }
//    }
//
//    // MARK: Private
//
//    private struct LedgerSheetViewList: View {
//        // MARK: Internal
//
//        let data: LedgerData
//
//        var body: some View {
//            Section {
//                LabelWithDescription(
//                    title: "原石收入",
//                    memo: "较昨日",
//                    icon: "UI_ItemIcon_Primogem",
//                    mainValue: data.dayData.currentPrimogems,
//                    previousValue: data.dayData.lastPrimogems
//                )
//                LabelWithDescription(
//                    title: "摩拉收入",
//                    memo: "较昨日",
//                    icon: "UI_ItemIcon_Mora",
//                    mainValue: data.dayData.currentMora,
//                    previousValue: data.dayData.lastMora
//                )
//            } header: {
//                HStack {
//                    Text("detailPortal.todayAcquisition.title")
//                    Spacer()
//                    Text("\(data.date ?? "")")
//                }
//            } footer: {
//                Text("仅统计充值途径以外获取的资源。数据存在延迟。")
//                    .font(.footnote)
//                    .multilineTextAlignment(.leading)
//            }
//
//            Section {
//                let dayCountThisMonth = Calendar.current.dateComponents(
//                    [.day],
//                    from: Date()
//                ).day
//                LabelWithDescription(
//                    title: "原石收入",
//                    memo: "较上月同期",
//                    icon: "UI_ItemIcon_Primogem",
//                    mainValue: data.monthData.currentPrimogems,
//                    previousValue: data.monthData.lastPrimogems / (dayCountThisMonth ?? 1)
//                )
//                LabelWithDescription(
//                    title: "摩拉收入",
//                    memo: "较上月同期",
//                    icon: "UI_ItemIcon_Mora",
//                    mainValue: data.monthData.currentMora,
//                    previousValue: data.monthData.lastMora / (dayCountThisMonth ?? 1)
//                )
//            } header: {
//                Text("本月账单 (\(data.dataMonth)月)")
//            } footer: {
//                HStack(alignment: .center) {
//                    Spacer()
//                    PieChartView(
//                        values: data.monthData.groupBy.map { Double($0.num) },
//                        names: data.monthData.groupBy
//                            .map { (LedgerDataActions(rawValue: $0.actionId) ?? .byOther).localized },
//                        formatter: { value in String(format: "%.0f", value) },
//                        colors: [
//                            .blue,
//                            .green,
//                            .orange,
//                            .yellow,
//                            .purple,
//                            .gray,
//                            .brown,
//                            .cyan,
//                        ],
//                        backgroundColor: Color(UIColor.systemGroupedBackground),
//                        widthFraction: 1,
//                        innerRadiusFraction: 0.6
//                    )
//                    .frame(minWidth: 280, maxWidth: 280, minHeight: 600, maxHeight: 600)
//                    .padding(.vertical)
//                    .padding(.top)
//                    Spacer()
//                }
//            }
//        }
//
//        // MARK: Private
//
//        private struct LabelWithDescription: View {
//            let title: LocalizedStringKey
//            let memo: LocalizedStringKey
//            let icon: String
//            let mainValue: Int
//            let previousValue: Int?
//
//            var delta: Int { mainValue - (previousValue ?? 0) }
//
//            var body: some View {
//                Label {
//                    VStack {
//                        HStack {
//                            Text(title)
//                            Spacer()
//                            Text("\(mainValue)")
//                        }
//                        if previousValue != nil {
//                            HStack {
//                                Text(memo).foregroundColor(.secondary)
//                                Spacer()
//                                switch delta {
//                                case 1...: Text("+\(delta)").foregroundStyle(.green)
//                                default: Text("\(delta)").foregroundStyle(.red)
//                                }
//                            }.font(.footnote).opacity(0.8)
//                        }
//                    }
//                } icon: {
//                    Image(icon)
//                        .resizable()
//                        .scaledToFit()
//                }
//            }
//        }
//    }
// }
//
//// MARK: - AllAvatarNavigator
//
@available(iOS 15.0, *)
private struct AllAvatarNavigator: View {
    let account: AccountConfiguration

    var body: some View {
        NavigationLink("所有角色") {
            AllAvatarListSheetView(account: account)
        }
    }
}

// MARK: - PlayerDetail.Avatar + Identifiable

//
//// MARK: - PrimogemTextLabel
//
// private struct PrimogemTextLabel: View {
//    let primogem: Int
//    @State
//    var labelHeight = CGFloat.zero
//
//    var body: some View {
//        HStack {
//            Image("UI_ItemIcon_Primogem")
//                .resizable()
//                .scaledToFit()
//                .frame(maxHeight: labelHeight)
//            Text("\(primogem)")
//                .font(.system(.largeTitle, design: .rounded))
//                .lineLimit(1)
//                .fixedSize(horizontal: false, vertical: true)
//                .minimumScaleFactor(0.7)
//                .overlay(
//                    GeometryReader(content: { geometry in
//                        Color.clear
//                            .onAppear(perform: {
//                                labelHeight = geometry.frame(in: .local)
//                                    .size.height
//                            })
//                    })
//                )
//        }
//    }
// }
//
//// MARK: - MoraTextLabel
//
// private struct MoraTextLabel: View {
//    let mora: Int
//    @State
//    var labelHeight = CGFloat.zero
//
//    var body: some View {
//        HStack {
//            Image("UI_ItemIcon_Mora")
//                .resizable()
//                .scaledToFit()
//                .frame(maxHeight: labelHeight)
//            Text("\(mora)")
//                .font(.system(.body, design: .rounded))
//                .overlay(
//                    GeometryReader(content: { geometry in
//                        Color.clear
//                            .onAppear(perform: {
//                                labelHeight = geometry.frame(in: .local)
//                                    .size.height
//                            })
//                    })
//                )
//        }
//    }
// }
//
//// MARK: - AbyssTextLabel
//
// private struct AbyssTextLabel: View {
//    let text: String
//    @State
//    var labelHeight = CGFloat.zero
//
//    var body: some View {
//        HStack {
//            Image("UI_Icon_Tower")
//                .resizable()
//                .scaledToFit()
//                .frame(maxHeight: labelHeight)
//            Text(text)
//                .font(.system(.largeTitle, design: .rounded))
//                .lineLimit(1)
//                .fixedSize(horizontal: false, vertical: true)
//                .minimumScaleFactor(0.7)
//                .overlay(
//                    GeometryReader(content: { geometry in
//                        Color.clear
//                            .onAppear(perform: {
//                                labelHeight = geometry.frame(in: .local)
//                                    .size.height
//                            })
//                    })
//                )
//        }
//    }
// }
//
//// MARK: - ToolViewNavigationTitleInIOS15
//
// private struct ToolViewNavigationTitleInIOS15: ViewModifier {
//    func body(content: Content) -> some View {
//        if #available(iOS 16, *) {
//            content
//        } else {
//            content
//                .navigationTitle("披萨工具盒")
//                .navigationBarTitleDisplayMode(.inline)
//        }
//    }
// }
//
// extension View {
//    fileprivate func toolViewNavigationTitleInIOS15() -> some View {
//        modifier(ToolViewNavigationTitleInIOS15())
//    }
// }
