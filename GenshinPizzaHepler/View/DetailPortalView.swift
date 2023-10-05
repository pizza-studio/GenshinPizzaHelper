//
//  DetailPortalView.swift
//  GenshinPizzaHepler
//
//  Created by Bill Haku on 2022/9/17.
//

import HBMihoyoAPI
import HBPizzaHelperAPI
import SwiftPieChart
import SwiftUI

// MARK: - DetailPortalView

@available(iOS 15.0, *)
struct DetailPortalView: View {
    @EnvironmentObject
    var viewModel: ViewModel
    @Environment(\.scenePhase)
    var scenePhase
    var accounts: [Account] { viewModel.accounts }
    @AppStorage(
        "toolViewShowingAccountUUIDString",
        store: .init(suiteName: "group.GenshinPizzaHelper")
    )
    var showingAccountUUIDString: String?
    var account: Account? {
        accounts.first { account in
            (account.config.uuid?.uuidString ?? "123") ==
                showingAccountUUIDString
        }
    }

    var showingCharacterDetail: Bool {
        viewModel.showCharacterDetailOfAccount != nil
    }

    @State
    private var sheetType: SheetTypesForDetailPortalView?

    var thisAbyssData: SpiralAbyssDetail? { account?.spiralAbyssDetail?.this }
    var lastAbyssData: SpiralAbyssDetail? { account?.spiralAbyssDetail?.last }
    @State
    private var abyssDataViewSelection: AbyssDataType = .thisTerm

    var ledgerDataResult: LedgerDataFetchResult? { account?.ledgeDataResult }

    var animation: Namespace.ID

    @State
    private var askAllowAbyssDataCollectionAlert: Bool = false

    var body: some View {
        NavigationView {
            List {
                accountSection()
                playerDetailSection()
                abyssAndPrimogemNavigator()
                // if let accountInfo = account?.basicInfo { abyssAndPrimogemNavigatorView(accountBasicInfo: accountInfo) }
                toolsSection()
            }
            .sectionSpacing(UIFont.systemFontSize)
            .refreshable {
                withAnimation {
                    DispatchQueue.main.async {
                        if let account = account {
                            viewModel.refreshPlayerDetail(for: account)
                        }
                        viewModel.refreshAbyssAndBasicInfo()
                        viewModel.refreshLedgerData()
                    }
                }
            }
            .onAppear {
                if !accounts.isEmpty, showingAccountUUIDString == nil {
                    showingAccountUUIDString = accounts.first!.config.uuid!
                        .uuidString
                }
            }
            .sheet(item: $sheetType) { type in
                switch type {
                case .myLedgerSheet:
                    ledgerSheetView()
                case .mySpiralAbyss:
                    spiralAbyssSheetView()
                case .loginAccountAgainView:
                    GetLedgerCookieWebView(
                        title: String(
                            format: NSLocalizedString(
                                "请登录「%@」",
                                comment: ""
                            ),
                            viewModel
                                .accounts[
                                    viewModel.accounts
                                        .firstIndex(of: account!)!
                                ].config.name ?? ""
                        ),
                        sheetType: $sheetType,
                        cookie: Binding(
                            $viewModel
                                .accounts[
                                    viewModel.accounts
                                        .firstIndex(of: account!)!
                                ]
                                .config.cookie
                        )!,
                        region: viewModel
                            .accounts[
                                viewModel.accounts
                                    .firstIndex(of: account!)!
                            ]
                            .config.server.region
                    )
                    .onDisappear {
                        viewModel.refreshLedgerData()
                    }
                case .allAvatarList:
                    allAvatarListView()
                case .gachaAnalysis:
                    NavigationView {
                        GachaView()
                            .toolbar {
                                ToolbarItem(placement: .navigationBarLeading) {
                                    Button("完成") {
                                        sheetType = nil
                                    }
                                }
                            }
                    }
                case .rankedSpiralAbyss:
                    NavigationView {
                        AbyssDataCollectionView()
                            .toolbar {
                                ToolbarItem(placement: .navigationBarLeading) {
                                    Button("完成") {
                                        sheetType = nil
                                    }
                                }
                            }
                    }
                }
            }
            .onChange(of: account) { newAccount in
                withAnimation {
                    DispatchQueue.main.async {
                        if let newAccount = newAccount {
                            viewModel.refreshPlayerDetail(for: newAccount)
                        }
                    }
                }
            }
            .toolViewNavigationTitleInIOS15()
            .onAppear { checkIfAllowAbyssDataCollection() }
            .alert(
                "是否允许我们收集您的深渊数据？",
                isPresented: $askAllowAbyssDataCollectionAlert
            ) {
                Button("不允许", role: .destructive) {
                    UserDefaults.standard.set(
                        false,
                        forKey: "allowAbyssDataCollection"
                    )
                    UserDefaults.standard.set(
                        true,
                        forKey: "hasAskedAllowAbyssDataCollection"
                    )
                }
                Button("允许", role: .cancel, action: {
                    UserDefaults.standard.set(
                        true,
                        forKey: "allowAbyssDataCollection"
                    )
                    UserDefaults.standard.set(
                        true,
                        forKey: "hasAskedAllowAbyssDataCollection"
                    )
                })
            } message: {
                Text(
                    "我们希望收集您已拥有的角色和在攻克深渊时使用的角色。如果您同意我们使用您的数据，您将可以在App内查看我们实时汇总的深渊角色使用率、队伍使用率等情况。更多相关问题，请查看深渊统计榜单页面右上角的FAQ。"
                )
            }
            .onChange(of: scenePhase, perform: { newPhase in
                switch newPhase {
                case .active:
                    withAnimation {
                        DispatchQueue.main.async {
                            if let account = account {
                                viewModel.refreshPlayerDetail(for: account)
                            }
                            viewModel.refreshAbyssAndBasicInfo()
                            viewModel.refreshLedgerData()
                        }
                    }
                default:
                    break
                }
            })
        }
        .navigationViewStyle(.stack)
    }

    @ViewBuilder
    func accountSection() -> some View {
        if let account = account {
            if let playerDetail = try? account.playerDetailResult?.get() {
                Section {
                    HStack {
                        playerDetail.basicInfo.decoratedIcon(64)
                        VStack(alignment: .leading) {
                            HStack(spacing: 10) {
                                VStack(alignment: .leading) {
                                    Text(playerDetail.basicInfo.nickname)
                                        .font(.title3)
                                        .bold()
                                        .padding(.top, 5)
                                        .lineLimit(1)
                                    Text(playerDetail.basicInfo.signature)
                                        .foregroundColor(.secondary)
                                        .font(.footnote)
                                        .lineLimit(2)
                                        .fixedSize(
                                            horizontal: false,
                                            vertical: true
                                        )
                                }
                                Spacer()
                                selectAccountManuButton()
                            }
                            Text("UID: \(account.config.uid ?? "")")
                                .foregroundColor(.secondary)
                                .font(.footnote)
                                .lineLimit(1)
                                .fixedSize(
                                    horizontal: false,
                                    vertical: true
                                )
                        }
                    }
                }
            } else {
                Section {
                    VStack {
                        HStack {
                            Text(account.config.name ?? "")
                            Spacer()
                            selectAccountManuButton()
                        }
                        Text("UID: \(account.config.uid ?? "")")
                            .foregroundColor(.secondary)
                            .font(.footnote)
                            .lineLimit(1)
                            .fixedSize(
                                horizontal: false,
                                vertical: true
                            )
                    }
                }
            }
        } else if accounts.isEmpty {
            NavigationLink(destination: AddAccountView()) {
                Label("settings.account.pleaseAddAccountFirst", systemImage: "plus.circle")
            }
        } else {
            Menu {
                ForEach(accounts, id: \.config.id) { account in
                    Button(account.config.name ?? "Name Error") {
                        showingAccountUUIDString = account.config.uuid!
                            .uuidString
                    }
                }
            } label: {
                Label("detailPortal.prompt.pleaseSelectAccount", systemImage: "arrow.left.arrow.right.circle")
            }
        }
    }

    @ViewBuilder
    func playerDetailSection() -> some View {
        if let account = account {
            if let result = account.playerDetailResult {
                switch result {
                case .success:
                    successView()
                case let .failure(error):
                    failureView(error: error)
                }
            } else if !account.fetchPlayerDetailComplete {
                loadingView()
            }
        }
        if (try? account?.playerDetailResult?.get()) == nil {
            Section { allAvatarNavigator() }
        }
    }

    @ViewBuilder
    func allAvatarListView() -> some View {
        NavigationView {
            AllAvatarListSheetView(account: account!, sheetType: $sheetType)
        }
    }

    @ViewBuilder
    func successView() -> some View {
        let playerDetail: PlayerDetail = try! account!.playerDetailResult!.get()
        Section {
            VStack {
                if playerDetail.avatars.isEmpty {
                    Text("账号未展示角色")
                        .foregroundColor(.secondary)
                } else {
                    ScrollView(.horizontal) {
                        HStack {
                            ForEach(
                                playerDetail.avatars,
                                id: \.name
                            ) { avatar in
                                avatar.characterAsset.cardIcon(75)
                                    .onTapGesture {
                                        simpleTaptic(type: .medium)
                                        withAnimation(
                                            .interactiveSpring(
                                                response: 0.25,
                                                dampingFraction: 1.0,
                                                blendDuration: 0
                                            )
                                        ) {
                                            viewModel
                                                .showingCharacterName =
                                                avatar.name
                                            viewModel
                                                .showCharacterDetailOfAccount =
                                                account!
                                        }
                                    }
                                    .onAppear {
                                        // 同步时装设定至全局预设值。
                                        let charAsset = avatar.characterAsset
                                        if let costumeAsset = avatar.costumeAsset {
                                            viewModel.costumeMap[charAsset] = costumeAsset
                                        } else {
                                            viewModel.costumeMap.removeValue(forKey: charAsset)
                                        }
                                    }
                            }
                        }
                        .padding(.vertical, 4)
                    }
                }
                allAvatarNavigator()
            }
        }
    }

    @ViewBuilder
    func abyssAndPrimogemNavigator() -> some View {
        if let account = account {
            if let basicInfo: BasicInfos = account.basicInfo {
                abyssAndPrimogemNavigatorView(accountBasicInfo: basicInfo)
            } else {
                ForEach($viewModel.accounts, id: \.config.uuid) { $account in
                    if $account.wrappedValue == account {
                        NavigationLink {
                            AccountDetailView(account: $account)
                        } label: {
                            HStack {
                                Image(
                                    systemName: "exclamationmark.arrow.triangle.2.circlepath"
                                )
                                .frame(width: 20, height: 20)
                                .foregroundColor(.red)
                                Text("detailPortal.errorMessage.accountHasNulledBasicInfo").font(.footnote)
                            }
                        }
                    }
                }
            }
        } else {
            Text("detailPortal.errorMessage.noAccountAvailableForAbyssDisplay").font(.footnote)
        }
    }

    @ViewBuilder
    func abyssAndPrimogemNavigatorView(accountBasicInfo basicInfo: BasicInfos) -> some View {
        Section {
            HStack(spacing: 30) {
                Spacer()
                VStack {
                    VStack(spacing: 7) {
                        AbyssTextLabel(
                            text: "\(basicInfo.stats.spiralAbyss)"
                        )
                        if let thisAbyssData = thisAbyssData {
                            HStack {
                                AbyssStarIcon()
                                    .frame(width: 30, height: 30)
                                Text("\(thisAbyssData.totalStar)")
                                    .font(.system(.body, design: .rounded))
                            }
                        } else {
                            ProgressView()
                                .onTapGesture {
                                    viewModel.refreshAbyssAndBasicInfo()
                                }
                        }
                    }
                    .frame(height: 100)
                }
                .frame(maxWidth: .infinity)
                .onTapGesture {
                    simpleTaptic(type: .medium)
                    sheetType = .mySpiralAbyss
                }
                Divider()
                VStack {
                    if let result = ledgerDataResult {
                        VStack(spacing: 10) {
                            switch result {
                            case let .success(data):
                                PrimogemTextLabel(
                                    primogem: data.dayData
                                        .currentPrimogems
                                )
                                MoraTextLabel(
                                    mora: data.dayData
                                        .currentMora
                                )
                            case let .failure(error):
                                Image(
                                    systemName: "exclamationmark.arrow.triangle.2.circlepath"
                                )
                                .foregroundColor(.red)
                                switch error {
                                case .notLoginError:
                                    (
                                        Text("[\("detailPortal.todayAcquisition.title".localized)]\n") +
                                            Text("detailPortal.todayAcquisition.reloginRequiredNotice")
                                    )
                                    .font(.footnote)
                                    .multilineTextAlignment(.center)
                                default:
                                    Text(error.description)
                                }
                            }
                        }
                        .frame(height: 105)
                    } else {
                        ProgressView()
                            .frame(height: 100)
                    }
                }
                .frame(maxWidth: .infinity)
                .onTapGesture {
                    if let result = ledgerDataResult {
                        switch result {
                        case .success:
                            simpleTaptic(type: .medium)
                            sheetType = .myLedgerSheet
                        case let .failure(error):
                            switch error {
                            case .notLoginError:
                                simpleTaptic(type: .medium)
                                sheetType = .loginAccountAgainView
                            default:
                                viewModel.refreshLedgerData()
                            }
                        }
                    }
                }
                Spacer()
            }
        }
        .listRowInsets(.init(top: 10, leading: 0, bottom: 10, trailing: 0))
    }

    @ViewBuilder
    func ledgerSheetView() -> some View {
        LedgerSheetView(
            data: try! ledgerDataResult!.get(),
            sheetType: $sheetType
        )
    }

    @ViewBuilder
    func spiralAbyssSheetView() -> some View {
        if let thisAbyssData = thisAbyssData,
           let lastAbyssData = lastAbyssData {
            NavigationView {
                VStack {
                    Picker("", selection: $abyssDataViewSelection) {
                        ForEach(AbyssDataType.allCases, id: \.self) { option in
                            Text(option.rawValue.localized)
                        }
                    }
                    .pickerStyle(.segmented)
                    .padding()
                    if let charMap = viewModel.charMap {
                        switch abyssDataViewSelection {
                        case .thisTerm:
                            AbyssDetailDataDisplayView(
                                data: thisAbyssData,
                                charMap: charMap
                            )
                        case .lastTerm:
                            AbyssDetailDataDisplayView(
                                data: lastAbyssData,
                                charMap: charMap
                            )
                        }
                    }
                }
                .navigationTitle("深境螺旋详情")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("完成") {
                            sheetType = nil
                        }
                    }
                }
                .toolbarSavePhotoButtonInIOS16(
                    title: String(
                        localized: "保存\(thisAbyssData.floors.last?.index ?? 12)层的深渊数据"
                    ),
                    placement: .navigationBarLeading
                ) {
                    Group {
                        switch abyssDataViewSelection {
                        case .thisTerm:
                            AbyssShareView(
                                data: thisAbyssData,
                                charMap: viewModel.charMap!
                            )
                            .environment(
                                \.locale,
                                .init(identifier: Locale.current.identifier)
                            )
                        case .lastTerm:
                            AbyssShareView(
                                data: lastAbyssData,
                                charMap: viewModel.charMap!
                            )
                            .environment(
                                \.locale,
                                .init(identifier: Locale.current.identifier)
                            )
                        }
                    }
                }
            }
        } else {
            ProgressView()
        }
    }

    @ViewBuilder
    func selectAccountManuButton() -> some View {
        if accounts.count > 1 {
            Menu {
                ForEach(accounts, id: \.config.id) { account in
                    Button(account.config.name ?? "Name Error") {
                        withAnimation {
                            showingAccountUUIDString = account.config.uuid!
                                .uuidString
                        }
                    }
                }
            } label: {
                Image(systemName: "arrow.left.arrow.right.circle")
                    .font(.title2)
            }
        } else {
            EmptyView()
        }
    }

    @ViewBuilder
    func failureView(error: PlayerDetail.PlayerDetailError) -> some View {
        Section {
            HStack {
                Spacer()
                Image(systemName: "exclamationmark.arrow.triangle.2.circlepath")
                    .foregroundColor(.red)
                    .onTapGesture {
                        if let account = account {
                            viewModel.refreshPlayerDetail(for: account)
                        }
                    }
                Spacer()
            }
        } footer: {
            switch error {
            case .failToGetLocalizedDictionary:
                Text("fail to get localized dictionary")
            case .failToGetCharacterDictionary:
                Text("fail to get character dictionary")
            case let .failToGetCharacterData(message):
                Text(message)
            case let .refreshTooFast(dateWhenRefreshable):
                if dateWhenRefreshable.timeIntervalSinceReferenceDate - Date()
                    .timeIntervalSinceReferenceDate > 0 {
                    let second = Int(
                        dateWhenRefreshable
                            .timeIntervalSinceReferenceDate - Date()
                            .timeIntervalSinceReferenceDate
                    )
                    Text(String(localized: "请稍等\(second)秒再刷新"))
                } else {
                    Text("请下滑刷新")
                }
            }
        }
    }

    @ViewBuilder
    func loadingView() -> some View {
        Section {
            HStack {
                Spacer()
                ProgressView()
                Spacer()
            }
        }
    }

    @ViewBuilder
    func allAvatarNavigator() -> some View {
        if let basicInfo = account?.basicInfo, let charMap = viewModel.charMap {
            AllAvatarNavigator(
                basicInfo: basicInfo,
                charMap: charMap,
                sheetType: $sheetType
            )
        }
    }

    @ViewBuilder
    func toolsSection() -> some View {
        Section {
            // 这里有一个 SwiftUI 故障导致的陈年 Bug。
            // 如果在这个画面存在任何 Navigation Link 的话，
            // 方向键会触发这个画面在 macOS 系统下的异常画面切换行为。
            // 所以这里限制 macOS 在此处以 sheet 的形式呈现这两个画面。
            switch OS.type {
            case .macOS:
                Label {
                    Text("祈愿分析")
                } icon: {
                    Image("UI_MarkPoint_SummerTimeV2_Dungeon_04").resizable()
                        .scaledToFit()
                }.onTapGesture {
                    sheetType = .gachaAnalysis
                }
                Label {
                    Text("深渊统计榜单")
                } icon: {
                    Image("UI_MarkTower_EffigyChallenge_01").resizable()
                        .scaledToFit()
                }.onTapGesture {
                    sheetType = .rankedSpiralAbyss
                }
            default:
                NavigationLink(destination: GachaView()) {
                    Label {
                        Text("祈愿分析")
                    } icon: {
                        Image("UI_MarkPoint_SummerTimeV2_Dungeon_04").resizable()
                            .scaledToFit()
                    }
                }
                NavigationLink(destination: AbyssDataCollectionView()) {
                    Label {
                        Text("深渊统计榜单")
                    } icon: {
                        Image("UI_MarkTower_EffigyChallenge_01").resizable()
                            .scaledToFit()
                    }
                }
            }
        }
    }

    func checkIfAllowAbyssDataCollection() {
        if !UserDefaults.standard
            .bool(forKey: "hasAskedAllowAbyssDataCollection"), account != nil {
            askAllowAbyssDataCollectionAlert = true
        }
    }
}

// MARK: - SheetTypesForDetailPortalView

enum SheetTypesForDetailPortalView: Identifiable {
    case mySpiralAbyss
    case myLedgerSheet
    case loginAccountAgainView
    case allAvatarList
    case gachaAnalysis
    case rankedSpiralAbyss

    // MARK: Internal

    var id: Int {
        hashValue
    }
}

// MARK: - AbyssDataType

private enum AbyssDataType: String, CaseIterable {
    case thisTerm = "本期深渊"
    case lastTerm = "上期深渊"
}

// MARK: - LedgerSheetView

@available(iOS 15.0, *)
private struct LedgerSheetView: View {
    // MARK: Internal

    let data: LedgerData
    @Binding
    var sheetType: SheetTypesForDetailPortalView?

    var body: some View {
        NavigationView {
            List {
                LedgerSheetViewList(data: data)
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("完成") {
                        sheetType = nil
                    }
                }
                ToolbarItem(placement: .principal) {
                    Text("原石摩拉账簿").bold()
                }
            }
            .toolbarSavePhotoButtonInIOS16(
                title: "保存本月原石账簿图片".localized,
                placement: .navigationBarLeading
            ) {
                LedgerShareView(data: data)
                    .environment(
                        \.locale,
                        .init(identifier: Locale.current.identifier)
                    )
            }
        }
    }

    // MARK: Private

    private struct LabelInfoProvider: View {
        let title: String
        let icon: String
        let value: Int

        var body: some View {
            HStack {
                Label(title: { Text(title.localized) }) {
                    Image(icon)
                        .resizable()
                        .scaledToFit()
                }
                Spacer()
                Text("\(value)")
            }
        }
    }

    private struct LedgerSheetViewList: View {
        let data: LedgerData

        var body: some View {
            Section {
                VStack(spacing: 0) {
                    LabelInfoProvider(
                        title: "原石收入",
                        icon: "UI_ItemIcon_Primogem",
                        value: data.dayData.currentPrimogems
                    )
                    if let lastPrimogem = data.dayData.lastPrimogems {
                        let primogemsDifference = data.dayData
                            .currentPrimogems - lastPrimogem
                        HStack {
                            Spacer()
                            Text("较昨日").foregroundColor(.secondary)
                            Text(
                                primogemsDifference > 0 ?
                                    "+\(primogemsDifference)" :
                                    "\(primogemsDifference)"
                            )
                            .foregroundColor(
                                primogemsDifference > 0 ?
                                    .green : .red
                            )
                            .opacity(0.8)
                        }.font(.footnote)
                    }
                }
                VStack(spacing: 0) {
                    LabelInfoProvider(
                        title: "摩拉收入",
                        icon: "UI_ItemIcon_Mora",
                        value: data.dayData.currentMora
                    )
                    if let lastMora = data.dayData.lastMora {
                        let moraDifference = data.dayData.currentMora - lastMora
                        HStack {
                            Spacer()
                            Text("较昨日").foregroundColor(.secondary)
                            Text(
                                moraDifference > 0 ? "+\(moraDifference)" :
                                    "\(moraDifference)"
                            )
                            .foregroundColor(
                                moraDifference > 0 ? .green :
                                    .red
                            )
                            .opacity(0.8)
                        }.font(.footnote)
                    }
                }
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
                ).day!
                let primogemsDifference = data.monthData.currentPrimogems - data
                    .monthData.lastPrimogems / dayCountThisMonth
                VStack(spacing: 0) {
                    LabelInfoProvider(
                        title: "原石收入",
                        icon: "UI_ItemIcon_Primogem",
                        value: data.monthData.currentPrimogems
                    )
                    HStack {
                        Spacer()
                        Text("较上月同期").foregroundColor(.secondary)
                        Text(
                            primogemsDifference > 0 ?
                                "+\(primogemsDifference)" :
                                "\(primogemsDifference)"
                        )
                        .foregroundColor(
                            primogemsDifference > 0 ? .green :
                                .red
                        )
                        .opacity(0.8)
                    }.font(.footnote)
                }
                VStack(spacing: 0) {
                    let moraDifference: Int = data.monthData.currentMora - data
                        .monthData.lastMora / dayCountThisMonth
                    LabelInfoProvider(
                        title: "摩拉收入",
                        icon: "UI_ItemIcon_Mora",
                        value: data.monthData.currentMora
                    )
                    HStack {
                        Spacer()
                        Text("较上月同期").foregroundColor(.secondary)
                        Text(
                            moraDifference > 0 ? "+\(moraDifference)" :
                                "\(moraDifference)"
                        )
                        .foregroundColor(moraDifference > 0 ? .green : .red)
                        .opacity(0.8)
                    }.font(.footnote)
                }
            } header: {
                Text("本月账单 (\(data.dataMonth)月)")
            } footer: {
                HStack {
                    Spacer()
                    PieChartView(
                        values: data.monthData.groupBy.map { Double($0.num) },
                        names: data.monthData.groupBy.map { $0.action },
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
                        innerRadiusFraction: 0.6
                    )
                    .padding(.vertical)
                    .frame(
                        height: UIScreen.main.bounds.width > 1000 ? UIScreen
                            .main.bounds.height * 0.9 : UIScreen.main.bounds
                            .height * 0.7
                    )
                    .frame(width: UIScreen.main.bounds.width > 1000 ? 500 : nil)
                    .padding(.top)
                    Spacer()
                }
            }
        }
    }
}

// MARK: - AllAvatarNavigator

@available(iOS 15.0, *)
private struct AllAvatarNavigator: View {
    // MARK: Internal

    let basicInfo: BasicInfos
    let charMap: [String: ENCharacterMap.Character]
    @Binding
    var sheetType: SheetTypesForDetailPortalView?

    var body: some View {
        HStack(alignment: .center) {
            Text("所有角色")
                .padding(.trailing)
                .font(.footnote)
                .foregroundColor(.primary)
            Spacer()
            HStack(spacing: 3) {
                ForEach(basicInfo.avatars.prefix(5), id: \.id) { avatar in
                    if let char = charMap[avatar.id.description] {
                        // 必须在这里绑一下 AppStorage，不然这个画面的内容不会自动更新。
                        char.asset.decoratedIcon(30, cutTo: cutShouldersForSmallAvatarPhotos ? .face : .shoulder)
                    }
                }
            }
            .padding(.vertical, 3)
        }
        .onTapGesture {
            sheetType = .allAvatarList
        }
    }

    // MARK: Private

    @AppStorage(
        "cutShouldersForSmallAvatarPhotos",
        store: .init(suiteName: "group.GenshinPizzaHelper")
    )
    private var cutShouldersForSmallAvatarPhotos: Bool = false
}

// MARK: - PrimogemTextLabel

private struct PrimogemTextLabel: View {
    let primogem: Int
    @State
    var labelHeight = CGFloat.zero

    var body: some View {
        HStack {
            Image("UI_ItemIcon_Primogem")
                .resizable()
                .scaledToFit()
                .frame(maxHeight: labelHeight)
            Text("\(primogem)")
                .font(.system(.largeTitle, design: .rounded))
                .lineLimit(1)
                .fixedSize(horizontal: false, vertical: true)
                .minimumScaleFactor(0.7)
                .overlay(
                    GeometryReader(content: { geometry in
                        Color.clear
                            .onAppear(perform: {
                                labelHeight = geometry.frame(in: .local)
                                    .size.height
                            })
                    })
                )
        }
    }
}

// MARK: - MoraTextLabel

private struct MoraTextLabel: View {
    let mora: Int
    @State
    var labelHeight = CGFloat.zero

    var body: some View {
        HStack {
            Image("UI_ItemIcon_Mora")
                .resizable()
                .scaledToFit()
                .frame(maxHeight: labelHeight)
            Text("\(mora)")
                .font(.system(.body, design: .rounded))
                .overlay(
                    GeometryReader(content: { geometry in
                        Color.clear
                            .onAppear(perform: {
                                labelHeight = geometry.frame(in: .local)
                                    .size.height
                            })
                    })
                )
        }
    }
}

// MARK: - AbyssTextLabel

private struct AbyssTextLabel: View {
    let text: String
    @State
    var labelHeight = CGFloat.zero

    var body: some View {
        HStack {
            Image("UI_Icon_Tower")
                .resizable()
                .scaledToFit()
                .frame(maxHeight: labelHeight)
            Text(text)
                .font(.system(.largeTitle, design: .rounded))
                .lineLimit(1)
                .fixedSize(horizontal: false, vertical: true)
                .minimumScaleFactor(0.7)
                .overlay(
                    GeometryReader(content: { geometry in
                        Color.clear
                            .onAppear(perform: {
                                labelHeight = geometry.frame(in: .local)
                                    .size.height
                            })
                    })
                )
        }
    }
}

// MARK: - ToolViewNavigationTitleInIOS15

private struct ToolViewNavigationTitleInIOS15: ViewModifier {
    func body(content: Content) -> some View {
        if #available(iOS 16, *) {
            content
        } else {
            content
                .navigationTitle("披萨工具盒")
                .navigationBarTitleDisplayMode(.inline)
        }
    }
}

extension View {
    fileprivate func toolViewNavigationTitleInIOS15() -> some View {
        modifier(ToolViewNavigationTitleInIOS15())
    }
}

extension View {
    public func sectionSpacing(_ spacing: CGFloat) -> some View {
        if #available(iOS 17.0, *) {
            return listSectionSpacing(spacing)
        }
        return self
    }
}
