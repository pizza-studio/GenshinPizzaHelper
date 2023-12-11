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

    typealias PlayerDetailStatus = Status<(PlayerDetail, nextRefreshableDate: Date)>
    typealias BasicInfoStatus = Status<BasicInfos>
    typealias SpiralAbyssDetailStatus = Status<SpiralAbyssDetail>
    typealias LedgerDataStatus = Status<LedgerData>
    typealias AllAvatarInfoStatus = Status<AllAvatarDetailModel>

    @Published
    var playerDetailStatus: PlayerDetailStatus = .progress(nil)

    @Published
    var basicInfoStatus: BasicInfoStatus = .progress(nil)

    @Published
    var spiralAbyssDetailStatus: SpiralAbyssDetailStatus = .progress(nil)

    @Published
    var ledgerDataStatus: LedgerDataStatus = .progress(nil)

    @Published
    var allAvatarInfoStatus: AllAvatarInfoStatus = .progress(nil)

    @Published
    var currentBasicInfo: PlayerDetail.PlayerBasicInfo?

    @Published
    var selectedAccount: AccountConfiguration? {
        didSet { refresh() }
    }

    var currentAccountNamecardFileName: String {
        (NameCard(rawValue: currentBasicInfo?.nameCardId ?? 0) ?? NameCard.defaultValueForAppBackground).fileName
    }

    func refresh() {
        fetchPlayerDetail()
        fetchBasicInfo()
        fetchSpiralAbyssInfo()
        fetchLedgerData()
        fetchAllAvatarInfo()
        uploadData()
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
                refreshCostumeMap(playerDetail: playerDetail)
                currentBasicInfo = playerDetail.basicInfo
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
        DispatchQueue.main.async {
            withAnimation { [weak self] in
                guard let self else { return }
                playerDetailStatus = .progress(task)
            }
        }
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
        DispatchQueue.main.async {
            withAnimation { [weak self] in
                guard let self else { return }
                spiralAbyssDetailStatus = .progress(task)
            }
        }
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
        DispatchQueue.main.async {
            withAnimation { [weak self] in
                guard let self else { return }
                spiralAbyssDetailStatus = .progress(task)
            }
        }
    }

    /// 同步时装设定至全局预设值。
    func refreshCostumeMap(playerDetail: PlayerDetail) {
        guard !playerDetail.avatars.isEmpty else { return }
        CharacterAsset.costumeMap.removeAll()
        let assetPairs = playerDetail.avatars.map { ($0.characterAsset, $0.costumeAsset) }
        assetPairs.forEach { characterAsset, costumeAsset in
            guard let costumeAsset = costumeAsset else { return }
            CharacterAsset.costumeMap[characterAsset] = costumeAsset
        }
    }

    func uploadData() {
        Task(priority: .background) {
            guard let account = selectedAccount else { return }
            if case let .progress(task) = basicInfoStatus {
                await task?.value
            }
            if case let .progress(task) = spiralAbyssDetailStatus {
                await task?.value
            }
            if case let .progress(task) = allAvatarInfoStatus {
                await task?.value
            }
            if case let .succeed(basicInfo) = basicInfoStatus {
                uploadHoldingData(account: account, basicInfo: basicInfo)
                if case let .succeed(abyssData) = spiralAbyssDetailStatus {
                    uploadAbyssData(account: account, abyssData: abyssData, basicInfo: basicInfo)
                    if case let .succeed(allAvatarData) = allAvatarInfoStatus {
                        uploadHuTaoDBAbyssData(
                            account: account,
                            abyssData: abyssData,
                            basicInfo: basicInfo,
                            allAvatarInfo: allAvatarData
                        )
                    }
                }
            }
        }
    }

    func uploadAbyssData(account: AccountConfiguration, abyssData: SpiralAbyssDetail, basicInfo: BasicInfos) {
        guard Defaults[.allowAbyssDataCollection] else { return }
        guard let uploadData = AbyssData(
            accountUID: account.safeUid,
            server: account.server,
            basicInfo: basicInfo,
            abyssData: abyssData,
            which: .this
        ) else { return }
        let md5 = "\(account.safeUid)\(uploadData.getLocalAbyssSeason())"
            .md5
        guard !Defaults[.hasUploadedAbyssDataAccountAndSeasonMD5].contains(md5)
        else {
            print(
                "uploadAbyssData ERROR: This abyss data has uploaded.  "
            ); return
        }
        let encoder = JSONEncoder()
        encoder.outputFormatting = .sortedKeys
        let data = try! encoder.encode(abyssData)
        print(String(data: data, encoding: .utf8)!)
        API.PSAServer.uploadUserData(
            path: "/abyss/upload",
            data: data
        ) { result in
            switch result {
            case .success:
                print("uploadAbyssData SUCCEED")
                saveMD5()
            case let .failure(error):
                switch error {
                case let .uploadError(message):
                    if message == "uid existed" {
                        saveMD5()
                    }
                default:
                    break
                }
                print("uploadAbyssData ERROR: \(error)")
                print(md5)
                print(Defaults[.hasUploadedAbyssDataAccountAndSeasonMD5])
            }
        }
        func saveMD5() {
            Defaults[.hasUploadedAbyssDataAccountAndSeasonMD5].append(md5)
            print(
                "uploadAbyssData MD5: \(Defaults[.hasUploadedAbyssDataAccountAndSeasonMD5])"
            )
            UserDefaults.opSuite.synchronize()
        }
    }

    func uploadHoldingData(account: AccountConfiguration, basicInfo: BasicInfos) {
        print("uploadHoldingData START")
        guard Defaults[.allowAbyssDataCollection]
        else { print("not allowed"); return }
        if let avatarHoldingData = AvatarHoldingData(
            accountUID: account.safeUid,
            server: account.server,
            basicInfo: basicInfo,
            which: .this
        ) {
            let encoder = JSONEncoder()
            encoder.outputFormatting = .sortedKeys
            let data = try! encoder.encode(avatarHoldingData)
            let md5 = String(data: data, encoding: .utf8)!.md5
            guard !Defaults[.hasUploadedAvatarHoldingDataMD5].contains(md5) else {
                print(
                    "uploadHoldingData ERROR: This holding data has uploaded. "
                ); return
            }
            guard !UPLOAD_HOLDING_DATA_LOCKED
            else { print("uploadHoldingDataLocked is locked"); return }
            API.PSAServer.uploadUserData(
                path: "/user_holding/upload",
                data: data
            ) { result in
                switch result {
                case .success:
                    print("uploadHoldingData SUCCEED")
                    saveMD5()
                    print(md5)
                    print(Defaults[.hasUploadedAvatarHoldingDataMD5])
                case let .failure(error):
                    switch error {
                    case let .uploadError(message):
                        if message == "uid existed" || message ==
                            "Insert Failed" {
                            saveMD5()
                        }
                    default:
                        break
                    }
                }
            }
            func saveMD5() {
                Defaults[.hasUploadedAvatarHoldingDataMD5].append(md5)
                UserDefaults.opSuite.synchronize()
            }

        } else {
            print(
                "uploadAbyssData ERROR: generate data fail. Maybe because not full star."
            )
        }
    }

    func uploadHuTaoDBAbyssData(
        account: AccountConfiguration,
        abyssData: SpiralAbyssDetail,
        basicInfo: BasicInfos,
        allAvatarInfo: AllAvatarDetailModel
    ) {
        Task(priority: .background) {
            print("uploadHuTaoDBAbyssData START")
            guard Defaults[.allowAbyssDataCollection]
            else { print("not allowed"); return }
            if let abyssData = await HuTaoDBAbyssData(
                accountUID: account.safeUid,
                server: account.server,
                cookie: account.safeCookie,
                basicInfo: basicInfo,
                abyssData: abyssData,
                allAvatarInfo: allAvatarInfo,
                which: .this
            ) {
                let encoder = JSONEncoder()
                encoder.outputFormatting = .sortedKeys
                let data = try! encoder.encode(abyssData)
                print(String(data: data, encoding: .utf8)!)
                API.PSAServer
                    .uploadHuTaoDBUserData(
                        path: "/Record/Upload",
                        data: data
                    ) { result in
                        switch result {
                        case .success:
                            print("uploadHuTaoDBAbyssData SUCCEED")
                        case let .failure(error):
                            print("uploadHuTaoDBAbyssData ERROR: \(error)")
                        }
                    }
            } else {
                print(
                    "uploadHuTaoDBAbyssData ERROR: generate data fail. Maybe because not full star."
                )
            }
        }
    }
}

// MARK: - DetailPortalView

struct DetailPortalView: View {
    // MARK: Internal

    var body: some View {
        NavigationStack {
            List {
                SelectAccountSection(selectedAccount: $detailPortalViewModel.selectedAccount)
                    .listRowMaterialBackground()
                if let account = detailPortalViewModel.selectedAccount {
                    PlayerDetailSection(account: account)
                        .listRowMaterialBackground()
                    Section {
                        AbyssInfoNavigator(account: account, status: detailPortalViewModel.spiralAbyssDetailStatus)
                        LedgerDataNavigator(account: account, status: detailPortalViewModel.ledgerDataStatus)
                        BasicInfoNavigator(account: account, status: detailPortalViewModel.basicInfoStatus)
//                        VerificationNeededView(account: account) {
//                            detailPortalViewModel.refresh()
//                        }
                    }
                    .listRowMaterialBackground()
                }
            }
            .scrollContentBackground(.hidden)
            .background {
                EnkaWebIcon(iconString: detailPortalViewModel.currentAccountNamecardFileName)
                    .scaledToFill()
                    .ignoresSafeArea(.all)
                    .overlay(.ultraThinMaterial)
            }
            .refreshable {
                detailPortalViewModel.refresh()
            }
            .navigationDestination(for: BasicInfos.self) { data in
                BasicInfoView(data: data)
            }
            .navigationDestination(for: SpiralAbyssDetail.self) { data in
                AbyssDetailDataDisplayView(data: data)
            }
            .navigationDestination(for: LedgerData.self) { data in
                LedgerView(data: data)
            }
            .navigationDestination(for: AllAvatarDetailModel.self) { data in
                AllAvatarListSheetView(data: data)
            }
        }
        .environmentObject(detailPortalViewModel)
        .alert(
            "是否允许我们收集您的深渊数据？",
            isPresented: $askAllowAbyssDataCollectionAlert
        ) {
            Button("不允许", role: .destructive) {
                Defaults[.allowAbyssDataCollection] = false
                Defaults[.hasAskedAllowAbyssDataCollection] = true
            }
            Button("允许", role: .cancel, action: {
                Defaults[.allowAbyssDataCollection] = true
                Defaults[.hasAskedAllowAbyssDataCollection] = true
            })
        } message: {
            Text(
                "我们希望收集您已拥有的角色和在攻克深渊时使用的角色。如果您同意我们使用您的数据，您将可以在App内查看我们实时汇总的深渊角色使用率、队伍使用率等情况。更多相关问题，请查看深渊统计榜单页面右上角的FAQ。"
            )
        }
        .onAppear {
            if !Defaults[.hasAskedAllowAbyssDataCollection] {
                askAllowAbyssDataCollectionAlert = true
            }
        }
    }

    // MARK: Private

    @State
    private var askAllowAbyssDataCollectionAlert: Bool = false

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
            VStack(alignment: .leading) {
                // 此处不处理 avatars.isEmpty 之情形，因为在 PlayerDetailSection 已经处理过了。
                // （Enka 被天空岛服务器喂屎的情形也会导致 playerDetail.avatars 成为空阵列。）
                ScrollView(.horizontal) {
                    HStack {
                        ForEach(
                            playerDetail.avatars,
                            id: \.name
                        ) { avatar in
                            Button {
                                simpleTaptic(type: .medium)
                                var transaction = Transaction()
                                // transaction.animation = .easeInOut
                                transaction.disablesAnimations = true // 要想恢复动画的话，请删掉这行。
                                withTransaction(transaction) {
                                    showingCharacterName = avatar.name
                                }
                            } label: {
                                avatar.characterAsset.cardIcon(75)
                            }
                        }
                    }
                }
                .padding(.vertical, 4)
                HelpTextForScrollingOnDesktopComputer(.horizontal)
            }
            .fullScreenCover(item: $showingCharacterName) { characterName in
                CharacterDetailView(
                    account: account,
                    showingCharacterName: characterName,
                    playerDetail: playerDetail
                ) {
                    var transaction = Transaction()
                    // transaction.animation = .easeInOut
                    transaction.disablesAnimations = true // 要想恢复动画的话，请删掉这行。
                    withTransaction(transaction) {
                        showingCharacterName = nil
                    }
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
                ErrorView(account: account, error: error) {
                    detailPortalViewModel.fetchPlayerDetail()
                }
            case let .succeed((playerDetail, _)):
                if playerDetail.avatars.isEmpty {
                    Button(action: {
                        detailPortalViewModel.refresh()
                    }, label: {
                        Label {
                            VStack {
                                Text(
                                    playerDetail
                                        .basicInfo != nil
                                        ? "account.playerDetailResult.message.characterShowCaseClassified"
                                        : "account.playerDetailResult.message.enkaGotNulledResultFromCelestiaServer"
                                )
                                .foregroundColor(.secondary)
                                if let msg = playerDetail.enkaMessage {
                                    Text(msg).foregroundColor(.secondary).controlSize(.small).font(.footnote)
                                }
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
    @EnvironmentObject
    private var detailPortalViewModel: DetailPortalViewModel

    // MARK: Internal

    let account: AccountConfiguration
    var status: DetailPortalViewModel.Status<AllAvatarDetailModel>

    var body: some View {
        switch status {
        case .progress:
            InformationRowView("app.detailPortal.allAvatar.title") {
                ProgressView()
            }
        case let .fail(error):
            InformationRowView("app.detailPortal.allAvatar.title") {
                ErrorView(account: account, error: error) {
                    detailPortalViewModel.fetchAllAvatarInfo()
                }
            }
        case let .succeed(data):
            InformationRowView("app.detailPortal.allAvatar.title") {
                let thisLabel = HStack(spacing: 3) {
                    ForEach(data.avatars.prefix(5), id: \.id) { avatar in
                        // 这里宜用 CharacterAsset.match，可以让尚未支持的角色显示成派蒙、方便尽早发现这类问题。
                        CharacterAsset.match(id: avatar.id)
                            .decoratedIcon(30, cutTo: cutShouldersForSmallAvatarPhotos ? .face : .shoulder)
                    }
                }
                if OS.type == .macOS {
                    SheetCaller(forceDarkMode: true) {
                        AllAvatarListSheetView(data: data)
                    } label: {
                        thisLabel
                    }
                } else {
                    NavigationLink(value: data) {
                        thisLabel
                    }
                }
            }
        }
    }

    // MARK: Private

    @Default(.cutShouldersForSmallAvatarPhotos)
    private var cutShouldersForSmallAvatarPhotos: Bool
}

// MARK: - LedgerDataNavigator

private struct LedgerDataNavigator: View {
    @EnvironmentObject
    private var detailPortalViewModel: DetailPortalViewModel

    // MARK: Internal

    let account: AccountConfiguration
    let status: DetailPortalViewModel.Status<LedgerData>

    var body: some View {
        Group {
            switch status {
            case .progress:
                InformationRowView("app.detailPortal.ledger.title") {
                    ProgressView().id(UUID())
                }
            case let .fail(error):
                InformationRowView("app.detailPortal.ledger.title") {
                    ErrorView(account: account, error: error) {
                        detailPortalViewModel.fetchLedgerData()
                    }
                }
            case let .succeed(data):
                LedgerDataView(ledgerData: data)
            }
        }
    }

    // MARK: Fileprivate

    fileprivate struct LedgerDataView: View {
        // MARK: Internal

        let ledgerData: LedgerData

        @ViewBuilder
        var displayLabel: some View {
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

        var body: some View {
            InformationRowView("app.detailPortal.ledger.title") {
                if OS.type == .macOS {
                    SheetCaller(forceDarkMode: true) {
                        LedgerView(data: ledgerData)
                    } label: {
                        displayLabel
                    }
                } else {
                    NavigationLink(value: ledgerData) {
                        displayLabel
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
    @EnvironmentObject
    private var detailPortalViewModel: DetailPortalViewModel

    // MARK: Internal

    let account: AccountConfiguration
    let status: DetailPortalViewModel.Status<SpiralAbyssDetail>

    var body: some View {
        Group {
            switch status {
            case .progress:
                InformationRowView("app.detailPortal.abyss.title") {
                    ProgressView().id(UUID())
                }
            case let .fail(error):
                InformationRowView("app.detailPortal.abyss.title") {
                    ErrorView(account: account, error: error) {
                        detailPortalViewModel.fetchSpiralAbyssInfo()
                    }
                }
            case let .succeed(data):
                AbyssInfoView(abyssInfo: data)
            }
        }
    }

    // MARK: Fileprivate

    fileprivate struct AbyssInfoView: View {
        // MARK: Internal

        let abyssInfo: SpiralAbyssDetail

        @ViewBuilder
        var displayLabel: some View {
            HStack(spacing: 10) {
                Image("UI_Icon_Tower")
                    .resizable()
                    .scaledToFit()
                    .frame(width: iconFrame, height: iconFrame)
                if abyssInfo.maxFloor != "0-0" {
                    HStack(alignment: .lastTextBaseline, spacing: 0) {
                        Text(verbatim: "\(abyssInfo.maxFloor)")
                            .font(.title)
                        Text(verbatim: "  ✡︎ \(abyssInfo.totalStar)")
                            .font(.title3)
                    }
                    Spacer()
                } else {
                    Text("暂无本期深渊数据")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        }

        var body: some View {
            InformationRowView("app.detailPortal.abyss.title") {
                // 如果没有本期深境螺旋数据的话，就不响应任何点击行为。
                if abyssInfo.maxFloor != "0-0" {
                    if OS.type == .macOS {
                        SheetCaller(forceDarkMode: true) {
                            AbyssDetailDataDisplayView(data: abyssInfo)
                        } label: {
                            displayLabel
                        }
                    } else {
                        NavigationLink(value: abyssInfo) {
                            displayLabel
                        }
                    }
                } else {
                    displayLabel
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
        .navigationTitle("app.detailPortal.ledger.title")
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
    @EnvironmentObject
    private var detailPortalViewModel: DetailPortalViewModel

    // MARK: Internal

    let account: AccountConfiguration
    let status: DetailPortalViewModel.Status<BasicInfos>

    var body: some View {
        switch status {
        case .progress:
            InformationRowView("app.detailPortal.basicInfo.title") {
                ProgressView().id(UUID())
            }
        case let .fail(error):
            InformationRowView("app.detailPortal.basicInfo.title") {
                ErrorView(account: account, error: error) {
                    detailPortalViewModel.fetchBasicInfo()
                }
            }
        case let .succeed(data):
            let thisLabel = HStack(spacing: 10) {
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
            InformationRowView("app.detailPortal.basicInfo.title") {
                if OS.type == .macOS {
                    SheetCaller(forceDarkMode: true) {
                        BasicInfoView(data: data)
                    } label: {
                        thisLabel
                    }
                } else {
                    NavigationLink(value: data) {
                        thisLabel
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
    @EnvironmentObject
    private var detailPortalViewModel: DetailPortalViewModel

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
            .listRowMaterialBackground()

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
            .listRowMaterialBackground()

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
            .listRowMaterialBackground()

            Section {
                ForEach(data.worldExplorations.sorted {
                    $0.id < $1.id
                }, id: \.id) { worldData in
                    WorldExplorationView(worldData: worldData)
                }
            }
            .listRowMaterialBackground()
        }
        .scrollContentBackground(.hidden)
        .background {
            EnkaWebIcon(iconString: detailPortalViewModel.currentAccountNamecardFileName)
                .scaledToFill()
                .ignoresSafeArea(.all)
                .overlay(.ultraThinMaterial)
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
                            let basicResponse = image.resizable().scaledToFit().frame(height: 30)
                            if colorScheme == .light {
                                basicResponse.colorInvert()
                            } else {
                                basicResponse
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

    let completion: () -> ()

    var body: some View {
        if let miHoYoAPIError = error as? MiHoYoAPIError,
           case .verificationNeeded = miHoYoAPIError {
            VerificationNeededView(account: account) {
                detailPortalViewModel.refresh()
            }
        } else {
            Button {
                completion()
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

    var disableButton: Bool {
        if case .progressing = status {
            true
        } else if case .gotVerification = status {
            true
        } else {
            false
        }
    }

    var body: some View {
        VStack {
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
            .disabled(disableButton)
            .sheet(item: $sheetItem, content: { item in
                switch item {
                case let .gotVerification(verification):
                    NavigationStack {
                        GeetestValidateView(
                            challenge: verification.challenge,
                            gt: verification.gt,
                            completion: { validate in
                                DispatchQueue.main.async {
                                    status = .pending
                                    verifyValidate(challenge: verification.challenge, validate: validate)
                                    sheetItem = nil
                                }
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
                }
            })
            if case let .fail(error) = status {
                Text("Error: \(error.localizedDescription)")
            }
        }
    }

    func popVerificationWebSheet() {
        Task(priority: .userInitiated) {
            do {
                let verification = try await MiHoYoAPI.createVerification(
                    cookie: account.safeCookie,
                    deviceFingerPrint: account.deviceFingerPrint, deviceId: account.safeUuid
                )
                DispatchQueue.main.async {
                    status = .gotVerification(verification)
                    sheetItem = .gotVerification(verification)
                }
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
                    deviceFingerPrint: account.deviceFingerPrint,
                    deviceId: account.safeUuid
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
    private var status: Status = .pending

    @State
    private var sheetItem: SheetItem?
}
