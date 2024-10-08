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

// MARK: - DetailPortalViewModel

@MainActor
final class DetailPortalViewModel: ObservableObject {
    // MARK: Lifecycle

    init() {
        let request = Account.fetchRequest()
        request.sortDescriptors = [.init(keyPath: \Account.priority, ascending: true)]
        let accounts = try? AccountModel.shared.container.viewContext.fetch(request)
        if let accounts, let account = accounts.first {
            self._selectedAccount = .init(initialValue: account)
            if let basicInfoRAW = Defaults[.queriedEnkaProfiles][account.safeUid] {
                self.currentEnkaProfile = EnkaGI.QueryRelated.ProfileTranslated(
                    fetchedModel: basicInfoRAW,
                    theDB: EnkaGI.Sputnik.sharedDB
                )
            }
            refresh()
        } else {
            self.selectedAccount = nil
        }
    }

    // MARK: Internal

    enum Status<T> {
        case progress(Task<(), Never>?)
        case fail(Error)
        case succeed(T)
        case standby

        // MARK: Internal

        var isBusy: Bool {
            switch self {
            case .progress: return true
            default: return false
            }
        }
    }

    typealias EnkaProfileStatus = Status<(EnkaGI.QueryRelated.ProfileTranslated, nextRefreshableDate: Date)>
    typealias BasicInfoStatus = Status<BasicInfos>
    typealias SpiralAbyssDetailStatus = Status<SpiralAbyssDetail>
    typealias LedgerDataStatus = Status<LedgerData>
    typealias CharInventoryStatus = Status<CharacterInventoryModel>

    static let refreshSubject: PassthroughSubject<(), Never> = .init()

    @Published
    var enkaProfileStatus: EnkaProfileStatus = .standby

    @Published
    var basicInfoStatus: BasicInfoStatus = .standby

    @Published
    var spiralAbyssDetailStatusCurrent: SpiralAbyssDetailStatus = .standby

    @Published
    var spiralAbyssDetailStatusPrevious: SpiralAbyssDetailStatus = .standby

    @Published
    var ledgerDataStatus: LedgerDataStatus = .standby

    @Published
    var characterInventoryStatus: CharInventoryStatus = .standby

    @Published
    var currentEnkaProfile: EnkaGI.QueryRelated.ProfileTranslated?

    @Published
    var selectedAccount: Account? {
        willSet {
            if let newValue, let currentProfileRAW = Defaults[.queriedEnkaProfiles][newValue.safeUid] {
                currentEnkaProfile = .init(
                    fetchedModel: currentProfileRAW,
                    theDB: EnkaGI.Sputnik.sharedDB
                )
            } else {
                currentEnkaProfile = nil
            }
        }
        didSet {
            refresh()
        }
    }

    var enkaDB: EnkaGI.EnkaDB {
        EnkaGI.Sputnik.sharedDB
    }

    var currentAccountNamecardFileName: String {
        (
            NameCard(rawValue: currentEnkaProfile?.basicInfo?.nameCardId ?? 0)
                ?? NameCard.currentValueForAppBackground
        ).fileName
    }

    func refresh() {
        Task.detached { @MainActor [self] in
            await fetchEnkaPlayerProfile()
            await fetchBasicInfo()
            await fetchSpiralAbyssInfoCurrent()
            await fetchSpiralAbyssInfoPrevious()
            await fetchLedgerData()
            await fetchCharacterInventoryList()
            await uploadData()
            Self.refreshSubject.send(())
        }
    }

    func fetchCharacterInventoryList() async {
        guard let account = selectedAccount else { return }
        if case let .progress(task) = characterInventoryStatus { task?.cancel() }
        let task = Task.detached { @MainActor in
            do {
                let result = try await MiHoYoAPI.allAvatarDetail(
                    server: account.server,
                    uid: account.safeUid,
                    cookie: account.safeCookie,
                    deviceFingerPrint: account.safeDeviceFingerPrint,
                    deviceId: account.safeUuid
                )
                Task.detached { @MainActor in
                    withAnimation {
                        self.characterInventoryStatus = .succeed(result)
                    }
                }
            } catch {
                Task.detached { @MainActor in
                    self.characterInventoryStatus = .fail(error)
                }
            }
        }
        Task.detached { @MainActor in
            self.characterInventoryStatus = .progress(task)
        }
    }

    func fetchEnkaPlayerProfile() async {
        guard let selectedAccount, !selectedAccount.safeUid.isEmpty else { return }
        if case let .succeed((_, refreshableDate)) = enkaProfileStatus {
            guard Date() > refreshableDate else { return }
        }
        if case let .progress(task) = enkaProfileStatus { task?.cancel() }
        let task = Task.detached { @MainActor [self] in
            do {
                let fetchedModel = try await API.OpenAPIs.fetchQueriableEnkaProfile(
                    selectedAccount.safeUid,
                    dateWhenNextRefreshable: nil
                ).merge(old: currentEnkaProfile?.rawInfo)
                Defaults[.queriedEnkaProfiles][selectedAccount.safeUid] = fetchedModel
                let theDB = try await EnkaGI.Sputnik.getEnkaDB {
                    $0.checkValidity(against: fetchedModel)
                }
                let playerDetail = EnkaGI.QueryRelated.ProfileTranslated(
                    fetchedModel: fetchedModel,
                    theDB: theDB
                )
                refreshCostumeMap(playerDetail: playerDetail)
                currentEnkaProfile?.update(newRawInfo: fetchedModel, dropExistingData: false)
                Task.detached { @MainActor in
                    withAnimation {
                        self.enkaProfileStatus = .succeed((
                            playerDetail,
                            Date()
                        ))
                    }
                }
            } catch {
                Task.detached { @MainActor in
                    self.enkaProfileStatus = .fail(error)
                }
            }
        }
        Task.detached { @MainActor in
            withAnimation {
                self.enkaProfileStatus = .progress(task)
            }
        }
    }

    func fetchBasicInfo() async {
        guard let account = selectedAccount else { return }
        if case let .progress(task) = basicInfoStatus { task?.cancel() }
        let task = Task.detached { @MainActor in
            do {
                let result = try await MiHoYoAPI.basicInfo(
                    server: account.server,
                    uid: account.safeUid,
                    cookie: account.safeCookie,
                    deviceFingerPrint: account.safeDeviceFingerPrint,
                    deviceId: account.safeUuid
                )
                Task.detached { @MainActor in
                    withAnimation {
                        self.basicInfoStatus = .succeed(result)
                    }
                }
            } catch {
                Task.detached { @MainActor in
                    self.basicInfoStatus = .fail(error)
                }
            }
        }
        Task.detached { @MainActor in
            withAnimation {
                self.basicInfoStatus = .progress(task)
            }
        }
    }

    func fetchSpiralAbyssInfoPrevious() async {
        guard let account = selectedAccount else { return }
        if case let .progress(task) = spiralAbyssDetailStatusPrevious { task?.cancel() }
        let task = Task.detached { @MainActor in
            do {
                let result = try await MiHoYoAPI.abyssData(
                    round: .last,
                    server: account.server,
                    uid: account.safeUid,
                    cookie: account.safeCookie,
                    deviceFingerPrint: account.safeDeviceFingerPrint,
                    deviceId: account.safeUuid
                )
                Task.detached { @MainActor in
                    withAnimation {
                        self.spiralAbyssDetailStatusPrevious = .succeed(result)
                    }
                }
            } catch {
                Task.detached { @MainActor in
                    self.spiralAbyssDetailStatusPrevious = .fail(error)
                }
            }
        }
        Task.detached { @MainActor in
            withAnimation {
                self.spiralAbyssDetailStatusPrevious = .progress(task)
            }
        }
    }

    func fetchSpiralAbyssInfoCurrent() async {
        guard let account = selectedAccount else { return }
        if case let .progress(task) = spiralAbyssDetailStatusCurrent { task?.cancel() }
        let task = Task.detached { @MainActor in
            do {
                let result = try await MiHoYoAPI.abyssData(
                    round: .this,
                    server: account.server,
                    uid: account.safeUid,
                    cookie: account.safeCookie,
                    deviceFingerPrint: account.safeDeviceFingerPrint,
                    deviceId: account.safeUuid
                )
                Task.detached { @MainActor in
                    withAnimation {
                        self.spiralAbyssDetailStatusCurrent = .succeed(result)
                    }
                }
            } catch {
                Task.detached { @MainActor in
                    self.spiralAbyssDetailStatusCurrent = .fail(error)
                }
            }
        }
        Task.detached { @MainActor in
            withAnimation {
                self.spiralAbyssDetailStatusCurrent = .progress(task)
            }
        }
    }

    func fetchLedgerData() async {
        guard let account = selectedAccount else { return }
        if case let .progress(task) = ledgerDataStatus { task?.cancel() }
        let task = Task.detached { @MainActor in
            do {
                let month = Calendar.current.dateComponents([.month], from: Date()).month!
                let result = try await MiHoYoAPI.ledgerData(
                    month: month,
                    uid: account.safeUid,
                    server: account.server,
                    cookie: account.safeCookie
                )
                Task.detached { @MainActor in
                    withAnimation {
                        self.ledgerDataStatus = .succeed(result)
                    }
                }
            } catch {
                Task.detached { @MainActor in
                    self.ledgerDataStatus = .fail(error)
                }
            }
        }
        Task.detached { @MainActor in
            withAnimation {
                self.ledgerDataStatus = .progress(task)
            }
        }
    }

    /// 同步时装设定至全局预设值。
    func refreshCostumeMap(playerDetail: EnkaGI.QueryRelated.ProfileTranslated) {
        guard !playerDetail.avatars.isEmpty else { return }
        CharacterAsset.costumeMap.removeAll()
        let assetPairs = playerDetail.avatars.map { ($0.characterAsset, $0.costumeAsset) }
        assetPairs.forEach { characterAsset, costumeAsset in
            guard let costumeAsset = costumeAsset else { return }
            CharacterAsset.costumeMap[characterAsset] = costumeAsset
        }
    }

    func uploadData() async {
        Task(priority: .background) {
            guard let account = selectedAccount else { return }
            if case let .progress(task) = basicInfoStatus {
                await task?.value
            }
            if case let .progress(task) = spiralAbyssDetailStatusCurrent {
                await task?.value
            }
            if case let .progress(task) = characterInventoryStatus {
                await task?.value
            }
            if case let .succeed(basicInfo) = basicInfoStatus {
                await uploadHoldingData(account: account, basicInfo: basicInfo)
                if case let .succeed(abyssData) = spiralAbyssDetailStatusCurrent {
                    await uploadAbyssData(account: account, abyssData: abyssData, basicInfo: basicInfo)
                    if case let .succeed(allAvatarData) = characterInventoryStatus {
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

    func uploadAbyssData(account: Account, abyssData: SpiralAbyssDetail, basicInfo: BasicInfos) async {
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

    func uploadHoldingData(account: Account, basicInfo: BasicInfos) async {
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
        account: Account,
        abyssData: SpiralAbyssDetail,
        basicInfo: BasicInfos,
        allAvatarInfo: CharacterInventoryModel
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
                SelectAccountSection(selectedAccount: $vmDPV.selectedAccount)
                    .listRowMaterialBackground()
                if let account = vmDPV.selectedAccount {
                    PlayerDetailSection(account: account)
                        .listRowMaterialBackground()
                    Section {
                        AbyssInfoNavigator(
                            account: account,
                            status: vmDPV.spiralAbyssDetailStatusCurrent
                        )
                        LedgerDataNavigator(account: account, status: vmDPV.ledgerDataStatus)
                        BasicInfoNavigator(account: account, status: vmDPV.basicInfoStatus)
//                        VerificationNeededView(account: account) {
//                            vmDPV.refresh()
//                        }
                    }
                    .listRowMaterialBackground()
                }
            }
            .scrollContentBackground(.hidden)
            .listContainerBackground(fileNameOverride: vmDPV.currentAccountNamecardFileName)
            .refreshable {
                vmDPV.refresh()
            }
            .navigationDestination(for: BasicInfos.self) { data in
                BasicInfoView(data: data)
            }
            .navigationDestination(for: SpiralAbyssDetail.self) { data in
                AbyssDetailDataDisplayView(
                    currentSeason: data,
                    previousSeason: {
                        switch vmDPV.spiralAbyssDetailStatusPrevious {
                        case let .succeed(prevData): return prevData
                        default: return nil
                        }
                    }()
                )
            }
            .navigationDestination(for: LedgerData.self) { data in
                LedgerView(data: data)
            }
            .navigationDestination(for: CharacterInventoryModel.self) { data in
                CharacterInventoryView(data: data)
            }
        }
        .environmentObject(vmDPV)
        .alert(
            "settings.privacy.abyssDataCollect",
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
            Text("settings.privacy.abyssDataCollect.detail")
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
    private var vmDPV: DetailPortalViewModel = .init()
}

// MARK: - SelectAccountSection

private struct SelectAccountSection: View {
    @EnvironmentObject
    private var vmDPV: DetailPortalViewModel

    // MARK: Internal

    @Binding
    var selectedAccount: Account?

    var body: some View {
        if let selectedAccount {
            if case let .succeed((playerDetail, _)) = vmDPV.enkaProfileStatus,
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
        playerDetail: EnkaGI.QueryRelated.ProfileTranslated,
        basicInfo: EnkaGI.QueryRelated.PlayerInfoTranslated,
        selectedAccount: Account
    )
        -> some View {
        Section {
            HStack(spacing: 0) {
                HStack {
                    basicInfo.accountProfileIcon(64)
                    #if os(OSX) || targetEnvironment(macCatalyst)
                        .contextMenu {
                            Group {
                                Button("↺".description) {
                                    withAnimation {
                                        vmDPV.refresh()
                                    }
                                }
                            }
                        }
                    #endif
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
                Text(verbatim: "UID: \(selectedAccount.safeUid)")
                Spacer()
                let worldLevelTitle = "detailPortal.player.worldLevel".localized
                Text("\(worldLevelTitle): \(basicInfo.worldLevel)")
            }
            .secondaryColorVerseBackground()
        }
    }

    @ViewBuilder
    func noBasicInfoFallBackView(selectedAccount: Account) -> some View {
        Section {
            HStack(spacing: 0) {
                HStack {
                    CharacterAsset.Paimon.decoratedIcon(64)
                    #if os(OSX) || targetEnvironment(macCatalyst)
                        .contextMenu {
                            Group {
                                Button("↺".description) {
                                    withAnimation {
                                        vmDPV.refresh()
                                    }
                                }
                            }
                        }
                    #endif
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
                Text(verbatim: "UID: \(selectedAccount.safeUid)")
            }
            .secondaryColorVerseBackground()
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
            keyPath: \Account.priority,
            ascending: true
        )])
        var accounts: FetchedResults<Account>

        let label: () -> T

        let completion: (Account) -> ()

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

#if hasFeature(RetroactiveAttribute)
extension PlayerDetailSection.DataFetchedView.ID: @retroactive Identifiable {}
#else
extension PlayerDetailSection.DataFetchedView.ID: Identifiable {}
#endif

extension PlayerDetailSection.DataFetchedView.ID {
    public var id: Int { self }
}

// MARK: - PlayerDetailSection

private struct PlayerDetailSection: View {
    @EnvironmentObject
    private var vmDPV: DetailPortalViewModel

    struct DataFetchedView: View {
        // MARK: Internal

        typealias ID = Int

        let playerDetail: EnkaGI.QueryRelated.ProfileTranslated
        let account: Account

        @State
        var showingCharacterIdentifier: ID?

        var body: some View {
            VStack(alignment: .leading) {
                // 此处不处理 avatars.isEmpty 之情形，因为在 PlayerDetailSection 已经处理过了。
                // （Enka 被天空岛服务器喂屎的情形也会导致 playerDetail.avatars 成为空阵列。）
                ScrollView(.horizontal) {
                    HStack {
                        // TabView 以 Name 为依据，不能仅依赖资料本身的 Identifiable 特性。
                        ForEach(playerDetail.avatars, id: \.enkaID) { avatar in
                            Button {
                                simpleTaptic(type: .medium)
                                var transaction = Transaction()
                                transaction.animation = .easeInOut
                                transaction.disablesAnimations = !animateOnCallingCharacterShowcase
                                withTransaction(transaction) {
                                    // TabView 以 Name 为依据。
                                    showingCharacterIdentifier = avatar.enkaID
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
            .fullScreenCover(item: $showingCharacterIdentifier) { characterName in
                AvatarShowCaseView(
                    account: account,
                    showingCharacterIdentifier: characterName,
                    playerDetail: playerDetail
                ) {
                    var transaction = Transaction()
                    transaction.animation = .easeInOut
                    transaction.disablesAnimations = !animateOnCallingCharacterShowcase
                    withTransaction(transaction) {
                        showingCharacterIdentifier = nil
                    }
                }
                .environment(\.colorScheme, .dark)
            }
        }

        // MARK: Private

        @Default(.animateOnCallingCharacterShowcase)
        private var animateOnCallingCharacterShowcase: Bool

        @Default(.artifactRatingOptions)
        private var artifactRatingOptions: ArtifactRatingOptions
    }

    let account: Account

    var enkaProfileStatus: DetailPortalViewModel
        .Status<(EnkaGI.QueryRelated.ProfileTranslated, nextRefreshableDate: Date)> { vmDPV.enkaProfileStatus }

    @ViewBuilder
    var currentShowCase: some View {
        if let playerDetail = vmDPV.currentEnkaProfile {
            DataFetchedView(playerDetail: playerDetail, account: account)
        } else if case let .succeed((playerDetail, _)) = enkaProfileStatus {
            DataFetchedView(playerDetail: playerDetail, account: account)
        }
    }

    var body: some View {
        Section {
            let theCase = currentShowCase
            switch enkaProfileStatus {
            case .progress:
                VStack {
                    theCase
                        .disabled(true)
                        .saturation(0)
                    InfiniteProgressBar().id(UUID())
                }
            case let .fail(error):
                theCase
                DPVErrorView(account: account, apiPath: "", error: error) {
                    Task.detached { @MainActor in
                        await vmDPV.fetchEnkaPlayerProfile()
                    }
                }
            case .standby:
                theCase
            case let .succeed((playerDetail, _)):
                theCase
                errorViewForBlankAvatars(playerDetail: playerDetail)
            }
            CharInventoryNavigator(account: account, status: vmDPV.characterInventoryStatus)
        }
    }

    @ViewBuilder
    private func errorViewForBlankAvatars(
        playerDetail: EnkaGI.QueryRelated.ProfileTranslated
    )
        -> some View {
        if playerDetail.avatars.isEmpty {
            Button(action: {
                vmDPV.refresh()
            }, label: {
                Label {
                    VStack {
                        Text(errorTextForBlankAvatars(hasBasicInfo: playerDetail.basicInfo != nil))
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
        }
    }

    private func errorTextForBlankAvatars(hasBasicInfo: Bool) -> String {
        let raw = hasBasicInfo
            ? "account.PlayerDetail.FetchedResult.message.characterShowCaseClassified"
            : "account.PlayerDetail.FetchedResult.message.enkaGotNulledResultFromCelestiaServer"
        return raw.localized
    }
}

// MARK: - CharInventoryNavigator

private struct CharInventoryNavigator: View {
    @EnvironmentObject
    private var vmDPV: DetailPortalViewModel

    // MARK: Internal

    let account: Account
    var status: DetailPortalViewModel.Status<CharacterInventoryModel>

    var body: some View {
        switch status {
        case .progress:
            InformationRowView("app.detailPortal.allAvatar.title") {
                ProgressView()
            }
        case let .fail(error):
            InformationRowView("app.detailPortal.allAvatar.title") {
                DPVErrorView(
                    account: account,
                    apiPath: "https://api-takumi-record.mihoyo.com/game_record/app/genshin/api/character",
                    error: error
                ) {
                    Task.detached { @MainActor in
                        await vmDPV.fetchCharacterInventoryList()
                    }
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
                if #unavailable(macOS 14), OS.type == .macOS {
                    SheetCaller(forceDarkMode: false) {
                        CharacterInventoryView(data: data)
                    } label: {
                        thisLabel
                    }
                } else {
                    NavigationLink(value: data) {
                        thisLabel
                    }
                }
            }
        case .standby:
            EmptyView()
        }
    }

    // MARK: Private

    @Default(.cutShouldersForSmallAvatarPhotos)
    private var cutShouldersForSmallAvatarPhotos: Bool
}

// MARK: - LedgerDataNavigator

private struct LedgerDataNavigator: View {
    @EnvironmentObject
    private var vmDPV: DetailPortalViewModel

    // MARK: Internal

    let account: Account
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
                    DPVErrorView(
                        account: account,
                        apiPath: "https://hk4e-api.mihoyo.com/event/ys_ledger/monthInfo",
                        error: error
                    ) {
                        Task.detached { @MainActor in
                            await vmDPV.fetchLedgerData()
                        }
                    }
                }
            case let .succeed(data):
                LedgerDataView(ledgerData: data)
            case .standby:
                EmptyView()
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
                if #unavailable(macOS 14), OS.type == .macOS {
                    SheetCaller(forceDarkMode: false) {
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
    private var vmDPV: DetailPortalViewModel

    // MARK: Internal

    let account: Account
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
                    DPVErrorView(
                        account: account,
                        apiPath: "https://api-takumi-record.mihoyo.com/game_record/app/genshin/api/spiralAbyss",
                        error: error
                    ) {
                        Task.detached { @MainActor in
                            await vmDPV.fetchSpiralAbyssInfoCurrent()
                        }
                    }
                }
            case let .succeed(data):
                AbyssInfoView(abyssInfo: data)
            case .standby:
                EmptyView()
            }
        }
    }

    // MARK: Fileprivate

    fileprivate struct AbyssInfoView: View {
        @EnvironmentObject
        private var vmDPV: DetailPortalViewModel

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
                    HStack(alignment: .lastTextBaseline) {
                        Text(verbatim: "\(abyssInfo.maxFloor)")
                            .font(.title)
                        HStack(alignment: .center, spacing: 2) {
                            AbyssStarIcon()
                                .frame(width: 20, height: 20)
                            Text(verbatim: "\(abyssInfo.totalStar)")
                                .font(.title3)
                        }
                    }
                    Spacer()
                } else {
                    Text("app.abyss.noData")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        }

        var body: some View {
            InformationRowView("app.detailPortal.abyss.title") {
                if #unavailable(macOS 14), OS.type == .macOS {
                    SheetCaller(forceDarkMode: false, sansFinishButton: true) {
                        AbyssDetailDataDisplayView(
                            currentSeason: abyssInfo,
                            previousSeason: {
                                switch vmDPV.spiralAbyssDetailStatusPrevious {
                                case let .succeed(prevData): return prevData
                                default: return nil
                                }
                            }()
                        )
                    } label: {
                        displayLabel
                    }
                } else {
                    NavigationLink(value: abyssInfo) {
                        displayLabel
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
                    title: "app.ledger.primogems",
                    memo: "app.ledger.compare",
                    icon: "UI_ItemIcon_Primogem",
                    mainValue: data.dayData.currentPrimogems,
                    previousValue: data.dayData.lastPrimogems
                )
                LabelWithDescription(
                    title: "app.ledger.mora",
                    memo: "app.ledger.compare",
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
                .secondaryColorVerseBackground()
            } footer: {
                Text("app.ledger.tip")
                    .font(.footnote)
                    .multilineTextAlignment(.leading)
                    .secondaryColorVerseBackground()
            }
            .listRowMaterialBackground()

            Section {
                let dayCountThisMonth = Calendar.current.dateComponents(
                    [.day],
                    from: Date()
                ).day
                LabelWithDescription(
                    title: "app.ledger.primogems",
                    memo: "app.ledger.compare.month",
                    icon: "UI_ItemIcon_Primogem",
                    mainValue: data.monthData.currentPrimogems,
                    previousValue: data.monthData.lastPrimogems / (dayCountThisMonth ?? 1)
                )
                LabelWithDescription(
                    title: "app.ledger.mora",
                    memo: "app.ledger.compare.month",
                    icon: "UI_ItemIcon_Mora",
                    mainValue: data.monthData.currentMora,
                    previousValue: data.monthData.lastMora / (dayCountThisMonth ?? 1)
                )
            } header: {
                Text("本月账单 (\(data.dataMonth)月)")
                    .secondaryColorVerseBackground()
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
                        backgroundColor: .clear,
                        widthFraction: 1,
                        innerRadiusFraction: 0.6
                    )
                    .frame(minWidth: 280, maxWidth: 280, minHeight: 600, maxHeight: 600)
                    .padding(.vertical)
                    .padding(.top)
                    Spacer()
                }
            }
            .listRowMaterialBackground()
        }
        .scrollContentBackground(.hidden)
        .listContainerBackground(fileNameOverride: vmDPV.currentAccountNamecardFileName)
        .navigationTitle("app.detailPortal.ledger.title")
    }

    // MARK: Private

    private struct LabelWithDescription: View {
        @Environment(\.colorScheme)
        var colorScheme

        let title: LocalizedStringKey
        let memo: LocalizedStringKey
        let icon: String
        let mainValue: Int
        let previousValue: Int?

        var valueDelta: Int { mainValue - (previousValue ?? 0) }

        var brightnessDelta: Double {
            colorScheme == .dark ? 0 : -0.35
        }

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
                            switch valueDelta {
                            case 1...: Text("+\(valueDelta)")
                                .foregroundStyle(.green).brightness(brightnessDelta)
                            default: Text("\(valueDelta)")
                                .foregroundStyle(.red).brightness(brightnessDelta)
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

    @EnvironmentObject
    private var vmDPV: DetailPortalViewModel
}

// MARK: - BasicInfoNavigator

private struct BasicInfoNavigator: View {
    @EnvironmentObject
    private var vmDPV: DetailPortalViewModel

    // MARK: Internal

    let account: Account
    let status: DetailPortalViewModel.Status<BasicInfos>

    var body: some View {
        switch status {
        case .progress:
            InformationRowView("app.detailPortal.basicInfo.title") {
                ProgressView().id(UUID())
            }
        case let .fail(error):
            InformationRowView("app.detailPortal.basicInfo.title") {
                DPVErrorView(
                    account: account,
                    apiPath: "https://api-takumi-record.mihoyo.com/game_record/app/genshin/api/index",
                    error: error
                ) {
                    Task.detached { @MainActor in
                        await vmDPV.fetchBasicInfo()
                    }
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
                if #unavailable(macOS 14), OS.type == .macOS {
                    SheetCaller(forceDarkMode: false) {
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
        case .standby:
            EmptyView()
        }
    }

    // MARK: Private

    private let iconFrame: CGFloat = 40
}

// MARK: - BasicInfoView

private struct BasicInfoView: View {
    @EnvironmentObject
    private var vmDPV: DetailPortalViewModel

    // MARK: Internal

    let data: BasicInfos

    var body: some View {
        List {
            Section {
                DataDisplayView(label: "app.account.basicInfo.daysActive", value: "\(data.stats.activeDayNumber)")
                DataDisplayView(label: "app.account.basicInfo.characters", value: "\(data.stats.avatarNumber)")
                DataDisplayView(label: "app.account.basicInfo.abyss", value: data.stats.spiralAbyss)
                DataDisplayView(
                    label: "app.account.basicInfo.achievements",
                    value: "\(data.stats.achievementNumber)"
                )
                DataDisplayView(
                    label: "app.account.basicInfo.waypoints",
                    value: "\(data.stats.wayPointNumber)"
                )
                DataDisplayView(
                    label: "app.account.basicInfo.domains",
                    value: "\(data.stats.domainNumber)"
                )
            }
            .listRowMaterialBackground()

            Section {
                DataDisplayView(label: "app.account.basicInfo.chest.1", value: "\(data.stats.commonChestNumber)")
                DataDisplayView(
                    label: "app.account.basicInfo.chest.3",
                    value: "\(data.stats.preciousChestNumber)"
                )
                DataDisplayView(
                    label: "app.account.basicInfo.chest.2",
                    value: "\(data.stats.exquisiteChestNumber)"
                )
                DataDisplayView(
                    label: "app.account.basicInfo.chest.4",
                    value: "\(data.stats.luxuriousChestNumber)"
                )
            }
            .listRowMaterialBackground()

            Section {
                DataDisplayView(
                    symbol: Image("UI_ItemIcon_107001"),
                    label: "app.account.basicInfo.anemo",
                    value: "\(data.stats.anemoculusNumber)"
                )
                DataDisplayView(
                    symbol: Image("UI_ItemIcon_107003"),
                    label: "app.account.basicInfo.geo",
                    value: "\(data.stats.geoculusNumber)"
                )
                DataDisplayView(
                    symbol: Image("UI_ItemIcon_107014"),
                    label: "app.account.basicInfo.electro",
                    value: "\(data.stats.electroculusNumber)"
                )
                DataDisplayView(
                    symbol: Image("UI_ItemIcon_107017"),
                    label: "app.account.basicInfo.dendro",
                    value: "\(data.stats.dendroculusNumber)"
                )
                DataDisplayView(
                    symbol: Image("Item_Hydroculus"),
                    label: "app.account.basicInfo.hydro",
                    value: "\(data.stats.hydroculusNumber)"
                )
                DataDisplayView(
                    symbol: Image("Item_Pyroculus"),
                    label: "app.account.basicInfo.pyro",
                    value: "\(data.stats.pyroculusNumber)"
                )
            }
            .listRowMaterialBackground()

            Section {
                ForEach(data.worldExplorations.sortedDataWithDeduplication, id: \.id) { worldData in
                    WorldExplorationView(worldData: worldData)
                }
            }
            .listRowMaterialBackground()
        }
        .scrollContentBackground(.hidden)
        .listContainerBackground(fileNameOverride: vmDPV.currentAccountNamecardFileName)
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
                            let basicResponse = image
                                .resizable().scaledToFit().frame(height: 30)
                            if colorScheme == .light {
                                basicResponse.colorInvert()
                            } else {
                                basicResponse
                            }
                        }) {
                            ForEach(Array(countryIconConversionMap), id: \.key) { key, value in
                                if url.absoluteString.contains(key) {
                                    let basicResponse = Image(value)
                                        .resizable().scaledToFit().frame(height: 30)
                                    if colorScheme == .light {
                                        basicResponse.colorInvert()
                                    } else {
                                        basicResponse
                                    }
                                }
                            }
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
                            Text(verbatim: "Lv. \(offering.level)")
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

// MARK: - DPVErrorView

private struct DPVErrorView: View {
    @EnvironmentObject
    private var vmDPV: DetailPortalViewModel

    let account: Account
    let apiPath: String
    let error: Error

    let completion: () -> ()

    var body: some View {
        if case .verificationNeeded = error as? MiHoYoAPIError {
            VerificationNeededView(account: account, challengePath: apiPath) {
                vmDPV.refresh()
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

    let account: Account
    let challengePath: String
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
                                Task.detached { @MainActor in
                                    status = .pending
                                    verifyValidate(challenge: verification.challenge, validate: validate)
                                    sheetItem = nil
                                }
                            }
                        )
                        .listContainerBackground(fileNameOverride: vmDPV.currentAccountNamecardFileName)
                        .toolbar {
                            ToolbarItem(placement: .navigationBarLeading) {
                                Button("sys.cancel") {
                                    status = .pending
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
        .frame(maxWidth: .infinity, alignment: .leading)
        .clipShape(Rectangle())
    }

    func popVerificationWebSheet() {
        Task(priority: .userInitiated) {
            do {
                let verification = try await MiHoYoAPI.createVerification(
                    cookie: account.safeCookie,
                    deviceFingerPrint: account.deviceFingerPrint, challengePath: challengePath,
                    deviceId: account.safeUuid
                )
                Task.detached { @MainActor in
                    status = .gotVerification(verification)
                    sheetItem = .gotVerification(verification)
                }
            } catch {
                status = .fail(error)
            }
        }
    }

    func verifyValidate(challenge: String, validate: String) {
        Task.detached { @MainActor in
            do {
                _ = try await MiHoYoAPI.verifyVerification(
                    challenge: challenge,
                    validate: validate, challengePath: challengePath,
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

    @EnvironmentObject
    private var vmDPV: DetailPortalViewModel
}

// MARK: - InformationRowView

private struct InformationRowView<L: View>: View {
    // MARK: Lifecycle

    init(_ title: LocalizedStringKey, @ViewBuilder labelContent: @escaping () -> L) {
        self.title = title
        self.labelContent = labelContent
    }

    // MARK: Internal

    @ViewBuilder
    let labelContent: () -> L

    let title: LocalizedStringKey

    var body: some View {
        VStack(alignment: .leading) {
            Text(title).bold()
            labelContent()
                .frame(maxWidth: .infinity, alignment: .leading)
                .clipShape(Rectangle())
        }
    }
}

// MARK: - Extending [Offering]

extension Array where Element == BasicInfos.WorldExploration {
    public var sortedDataWithDeduplication: [BasicInfos.WorldExploration] {
        var offered: Set<BasicInfos.WorldExploration.Offering> = .init()
        var result = [BasicInfos.WorldExploration]()
        let chenyuValePercent: Int = reversed().compactMap { this in
            if this.icon.contains("ChenYuVale") || this.innerIcon.contains("ChenYuVale") {
                return !this.offerings.isEmpty ? 0 : this.explorationPercentage
            } else {
                return nil
            }
        }.reduce(0, +)
        var chenyuValeAlreadyAdded = false
        forEach { this in
            var this = this
            let chenyuStr = "ChenYuVale"
            chenyu: if this.icon.contains(chenyuStr) || this.innerIcon.contains(chenyuStr) {
                if !chenyuValeAlreadyAdded, !this.offerings.isEmpty {
                    chenyuValeAlreadyAdded = true
                    this.explorationPercentage = Int(floor(Double(chenyuValePercent) / 3))
                    break chenyu
                }
                return
            }
            let oldOfferings = this.offerings
            this.offerings.removeAll()
            oldOfferings.forEach { offering in
                guard !offered.contains(offering) else { return }
                this.offerings.append(offering)
                offered.insert(offering)
            }
            // 从伺服器拿到的资料是反序排列的，这里给它正过来。
            result.insert(this, at: result.startIndex)
        }
        return result
    }
}

private let countryIconConversionMap: [String: String] = [
    "UI_ChapterIcon_Nata": "Emblem_Natlan_White",
    "UI_ChapterIcon_TheOldSea": "Emblem_Sea_of_Bygone_Eras_White",
    "UI_ChapterIcon_Fengdan": "Emblem_Fontaine_White",
    "UI_ChapterIcon_Xumi": "Emblem_Sumeru_White",
    "UI_ChapterIcon_ChasmsMaw": "Emblem_The_Chasm_White",
    "UI_ChapterIcon_Enkanomiya": "Emblem_Enkanomiya_White",
    "UI_ChapterIcon_Daoqi": "Emblem_Inazuma_White",
    "UI_ChapterIcon_Dragonspine": "Emblem_Dragonspine_White",
    "UI_ChapterIcon_Liyue": "Emblem_Liyue_White",
    "UI_ChapterIcon_Mengde": "Emblem_Mondstadt_White",
    "UI_ChapterIcon_ChenYuVale": "Emblem_Chenyu_Vale_White",
]
