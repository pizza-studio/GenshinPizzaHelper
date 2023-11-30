//
//  HomeView.swift
//  GenshinPizzaHepler
//
//  Created by Bill Haku on 2022/8/22.
//  展示所有账号的主页

import AlertToast
import Defaults
import HBMihoyoAPI
import HoYoKit
import SFSafeSymbols
import SwiftUI

// MARK: - NewHomeView

struct NewHomeView: View {
    @FetchRequest(sortDescriptors: [.init(
        keyPath: \AccountConfiguration.priority,
        ascending: false
    )])
    var accounts: FetchedResults<AccountConfiguration>

    var body: some View {
        NavigationView {
            List {
                TodayMaterialView()
                ForEach(accounts) { account in
                    AccountInfoCardView(account: account)
                }
            }
        }
    }
}

// MARK: - AccountInfoCardView

struct AccountInfoCardView: View {
    enum Status {
        case succeed(dailyNote: DailyNote)
        case failure(error: AnyLocalizedError)
        case progress
    }

    struct NoteView: View {
        // MARK: Internal

        let dailyNote: DailyNote
        let account: AccountConfiguration

        var body: some View {
            VStack {
                HStack {
                    Text("Resin").bold()
                    Spacer()
                }
                HStack(spacing: 10) {
                    let iconFrame: CGFloat = 40
                    Image("树脂")
                        .resizable()
                        .scaledToFit()
                        .frame(height: iconFrame)
                    HStack(alignment: .lastTextBaseline, spacing: 0) {
                        Text(verbatim: "\(dailyNote.resinInformation.currentResin)")
                            .font(.title)
                        Text(verbatim: " / \(dailyNote.resinInformation.maxResin)")
                            .font(.caption)
                        Spacer()
                        if dailyNote.resinInformation.resinRecoveryTime > Date() {
                            (
                                Text(dailyNote.resinInformation.resinRecoveryTime, style: .relative)
                                    + Text(verbatim: "\n")
                                    + Text(dateFormatter.string(from: dailyNote.resinInformation.resinRecoveryTime))
                            )
                            .multilineTextAlignment(.trailing)
                            .font(.caption2)
                        }
                    }
                }
            }
        }

        // MARK: Private

        private let dateFormatter: DateFormatter = {
            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = .short
            dateFormatter.timeStyle = .short
            dateFormatter.doesRelativeDateFormatting = true
            return dateFormatter
        }()
    }

    let account: AccountConfiguration

    @State
    var status: Status = .progress

    @Environment(\.scenePhase)
    var scenePhase

    var body: some View {
        Section {
            switch status {
            case let .succeed(dailyNote):
                NoteView(dailyNote: dailyNote, account: account)
            case let .failure(error):
                Text(error.localizedDescription)
            case .progress:
                ProgressView()
            }
        }
        .onChange(of: scenePhase, perform: { newPhase in
            switch newPhase {
            case .active:
                Task {
                    await fetchDailyNote()
                }
            default:
                break
            }
        })
    }

    func fetchDailyNote() async {
        status = .progress
        do {
            status = .succeed(dailyNote: try await MiHoYoAPI.dailyNote(for: account))
        } catch {
            status = .failure(error: AnyLocalizedError(error))
        }
    }
}

extension MiHoYoAPI {
    static func dailyNote(for account: AccountConfiguration) async throws -> DailyNote {
        try await dailyNote(
            server: account.server,
            uid: account.safeUid,
            cookie: account.safeCookie,
            deviceFingerPrint: account.safeDeviceFingerPrint
        )
    }
}

// MARK: - TodayMaterialView

struct TodayMaterialView: View {
    @Environment(\.scenePhase)
    var scenePhase

    @State
    var eventContents: [EventModel] = []

    var body: some View {
        Section {
            InAppMaterialNavigator()
                .onChange(of: scenePhase, perform: { newPhase in
                    switch newPhase {
                    case .active:
                        getCurrentEvent()
                    default:
                        break
                    }
                })
                .onAppear {
                    if eventContents.isEmpty {
                        getCurrentEvent()
                    }
                }
        }
        Section {
            CurrentEventNavigator(eventContents: $eventContents)
        }
    }

    func getCurrentEvent() {
        DispatchQueue.global().async {
            API.OpenAPIs.fetchCurrentEvents { result in
                switch result {
                case let .success(events):
                    withAnimation {
                        eventContents = [EventModel](events.event.values)
                        eventContents = eventContents.sorted {
                            $0.endAt < $1.endAt
                        }
                    }
                case .failure:
                    break
                }
            }
        }
    }
}

// MARK: - HomeView

struct HomeView: View {
    @EnvironmentObject
    var viewModel: ViewModel

    @Environment(\.colorScheme)
    var colorScheme

    @Environment(\.scenePhase)
    var scenePhase

    @Environment(\.horizontalSizeClass)
    var horizontalSizeClass

    @State
    var eventContents: [EventModel] = []

    var animation: Namespace.ID

    var sharedPadding: CGFloat = UIFont.systemFontSize / 2

    @FetchRequest(sortDescriptors: [.init(
        keyPath: \AccountConfiguration.priority,
        ascending: false
    )])
    var accounts: FetchedResults<AccountConfiguration>

    var viewBackgroundColor: UIColor {
        colorScheme == .light ? UIColor.secondarySystemBackground : UIColor.systemBackground
    }

    var sectionBackgroundColor: UIColor {
        colorScheme == .dark ? UIColor.secondarySystemBackground : UIColor.systemBackground
    }

    var accounts: [Account] { viewModel.accounts }
    var body: some View {
        HStack {
            if horizontalSizeClass != .compact { Spacer() }
            NavigationView {
                ScrollView {
                    VStack(spacing: UIFont.systemFontSize) {
                        // MARK: - 今日材料

                        InAppMaterialNavigator()
                            .onChange(of: scenePhase, perform: { newPhase in
                                switch newPhase {
                                case .active:
                                    getCurrentEvent()
                                default:
                                    break
                                }
                            })
                            .onAppear {
                                if eventContents.isEmpty {
                                    getCurrentEvent()
                                }
                            }

                        // MARK: - 当前活动

                        CurrentEventNavigator(eventContents: $eventContents)
                        if viewModel.accounts.isEmpty {
                            NavigationLink(destination: AddAccountView()) {
                                Label("settings.account.pleaseAddAccountFirst", systemSymbol: .plusCircle)
                            }
                            .padding(sharedPadding)
                            .blurMaterialBackground()
                            .clipShape(RoundedRectangle(
                                cornerRadius: 10,
                                style: .continuous
                            ))
                            .padding(.top, sharedPadding * 2)
                        } else {
                            // MARK: - 账号信息

                            AccountInfoCards(animation: animation)
                        }
                    }
                    .background(Color(uiColor: viewBackgroundColor))
                }
                .navigationTitle("app.title.full")
                .navigationBarTitleDisplayMode(.large)
                .background(Color(uiColor: viewBackgroundColor))
            }
            .navigationViewStyle(.stack)
            .frame(maxWidth: horizontalSizeClass == .compact ? nil : 500)
            .myRefreshable {
                withAnimation {
                    DispatchQueue.main.async {
                        viewModel.refreshData()
                    }
                    getCurrentEvent()
                }
            }
            if horizontalSizeClass != .compact { Spacer() }
        }
        .background(Color(uiColor: viewBackgroundColor))
    }

    func getCurrentEvent() {
        DispatchQueue.global().async {
            API.OpenAPIs.fetchCurrentEvents { result in
                switch result {
                case let .success(events):
                    withAnimation {
                        eventContents = [EventModel](events.event.values)
                        eventContents = eventContents.sorted {
                            $0.endAt < $1.endAt
                        }
                    }
                case .failure:
                    break
                }
            }
        }
    }
}

extension View {
    @ViewBuilder
    func myRefreshable(action: @escaping () -> ()) -> some View {
        refreshable {
            action()
        }
    }
}

// MARK: - PinnedAccountInfoCard

private struct PinnedAccountInfoCard: View {
    // MARK: Internal

    @EnvironmentObject
    var viewModel: ViewModel
    var animation: Namespace.ID
    @Default(.pinToTopAccountUUIDString)
    var pinToTopAccountUUIDString: String
    @Binding
    var isErrorAlertShow: Bool
    @Binding
    var errorMessage: String

    @Binding
    var isSucceedAlertShow: Bool

    var accountIndex: Int? {
        viewModel.accounts
            .firstIndex(where: {
                $0.config.uuid?.uuidString ?? "1" == pinToTopAccountUUIDString
            })
    }

    var bindingAccount: Binding<Account>? {
        if let accountIndex = accountIndex {
            return $viewModel.accounts[accountIndex]
        } else {
            return nil
        }
    }

    var body: some View {
        realBody
    }

    // MARK: Private

    private var realBody: some View {
        guard let accountIndex = accountIndex
        else { return AnyView(EmptyView()) }
        let account: Account = viewModel.accounts[accountIndex]
        guard account != viewModel.showDetailOfAccount
        else { return AnyView(EmptyView()) }
        guard let accountResult = account.result
        else { return AnyView(ProgressView().padding([.bottom, .horizontal])) }
        return AnyView(buildBodyView(for: accountResult, account: account))
    }

    @ViewBuilder
    private func buildBodyView(
        for accountResult: FetchResult,
        account: Account
    )
        -> some View {
        switch accountResult {
        case let .success(userData)
            where account.config.uuid != nil:
            GameInfoBlock(
                userData: userData,
                accountName: account.config.name,
                accountUUIDString: account.config.uuid!
                    .uuidString,
                animation: animation,
                widgetBackground: account.background,
                fetchComplete: account.fetchComplete
            )
            .padding(.horizontal)
            .listRowBackground(Color.white.opacity(0))
            .onTapGesture {
                simpleTaptic(type: .medium)
                withAnimation(
                    .interactiveSpring(
                        response: 0.5,
                        dampingFraction: 0.8,
                        blendDuration: 0.8
                    )
                ) {
                    viewModel
                        .showDetailOfAccount = account
                }
            }
            .contextMenu {
                Button("home.infoCard.unpin".localized) {
                    withAnimation {
                        Defaults.reset(.pinToTopAccountUUIDString)
                        viewModel.objectWillChange.send()
                    }
                }
                if #available(iOS 16, *) {
                    let view = GameInfoBlockForSave(
                        userData: userData,
                        accountName: account.config
                            .name ?? "",
                        accountUUIDString: account
                            .config.uuid?
                            .uuidString ?? "",
                        animation: animation,
                        widgetBackground: account
                            .background
                    ).environment(
                        \.locale,
                        .init(
                            identifier: Locale
                                .current.identifier
                        )
                    )
                    if let uiImage = view.asUiImage() {
                        let image = Image(uiImage: uiImage)
                        ShareLink(
                            item: image,
                            preview: SharePreview("button.savePic".localized, image: image)
                        )
                    }
                }
                #if canImport(ActivityKit)
                if #available(iOS 16.1, *) {
                    Button("为该账号开启树脂计时器") {
                        do {
                            try ResinRecoveryActivityController
                                .shared
                                .createResinRecoveryTimerActivity(
                                    for: account
                                )
                            isSucceedAlertShow.toggle()
                        } catch {
                            errorMessage = error
                                .localizedDescription
                            isErrorAlertShow.toggle()
                        }
                    }
                }
                #endif
            }
        case .failure:
            HStack {
                NavigationLink {
                    AccountDetailView(account: bindingAccount!)
                } label: {
                    ZStack {
                        Image(
                            systemName: "exclamationmark.arrow.triangle.2.circlepath"
                        )
                        .padding()
                        .foregroundColor(.red)
                        HStack {
                            Spacer()
                            Text(account.config.name ?? "")
                                .foregroundColor(Color(
                                    UIColor
                                        .systemGray4
                                ))
                                .font(.caption2)
                                .padding(.horizontal)
                        }
                    }
                    .padding(.horizontal)
                }
            }
        default: EmptyView()
        }
    }
}

// MARK: - AccountInfoCards

private struct AccountInfoCards: View {
    @EnvironmentObject
    var viewModel: ViewModel
    var animation: Namespace.ID

    @Default(.pinToTopAccountUUIDString)
    var pinToTopAccountUUIDString: String

    @State
    var isErrorAlertShow: Bool = false
    @State
    var errorMessage: String = ""
    @State
    var isSucceedAlertShow: Bool = false

    var body: some View {
        PinnedAccountInfoCard(
            animation: animation,
            isErrorAlertShow: $isErrorAlertShow,
            errorMessage: $errorMessage,
            isSucceedAlertShow: $isSucceedAlertShow
        )
        .overlay(
            EmptyView()
//                .alert(isPresented: $isSucceedAlertShow) {
//                    Alert(title: Text("创建树脂计时器成功".localized))
//                }
                .toast(isPresenting: $isSucceedAlertShow) {
                    AlertToast(
                        displayMode: .hud,
                        type: .complete(.green),
                        title: "创建树脂计时器成功"
                    )
                }
        )
        .overlay(
            EmptyView()
//                .alert(isPresented: $isErrorAlertShow) {
//                    Alert(title: Text("ERROR \(errorMessage)"))
//                }
                .toast(isPresenting: $isErrorAlertShow) {
                    AlertToast(
                        displayMode: .hud,
                        type: .error(.red),
                        title: "ERROR \(errorMessage)"
                    )
                }
        )
        ForEach($viewModel.accounts, id: \.config.uuid) { $account in
            if account != viewModel.showDetailOfAccount,
               account != viewModel.accounts
               .first(where: {
                   $0.config.uuid?
                       .uuidString ?? "1" == pinToTopAccountUUIDString
               }) {
                if account.result != nil, let accountConfigUUID = account.config.uuid {
                    switch account.result! {
                    case let .success(userData):
                        GameInfoBlock(
                            userData: userData,
                            accountName: account.config.name,
                            accountUUIDString: accountConfigUUID
                                .uuidString,
                            animation: animation,
                            widgetBackground: account.background,
                            fetchComplete: account.fetchComplete
                        )
                        .padding(.horizontal)
                        .listRowBackground(Color.white.opacity(0))
                        .onTapGesture {
                            simpleTaptic(type: .medium)
                            withAnimation(
                                .interactiveSpring(
                                    response: 0.5,
                                    dampingFraction: 0.8,
                                    blendDuration: 0.8
                                )
                            ) {
                                viewModel.showDetailOfAccount = account
                            }
                        }
                        .contextMenu {
                            Button("home.infoCard.pinToTop".localized) {
                                withAnimation {
                                    pinToTopAccountUUIDString = accountConfigUUID.uuidString
                                }
                            }
                            if #available(iOS 16, *) {
                                let view = GameInfoBlockForSave(
                                    userData: userData,
                                    accountName: account.config
                                        .name ?? "",
                                    accountUUIDString: account
                                        .config.uuid?.uuidString ?? "",
                                    animation: animation,
                                    widgetBackground: account
                                        .background
                                ).environment(
                                    \.locale,
                                    .init(
                                        identifier: Locale.current
                                            .identifier
                                    )
                                )
                                if let uiImage = view.asUiImage() {
                                    let image = Image(uiImage: uiImage)
                                    ShareLink(
                                        item: image,
                                        preview: SharePreview("button.savePic".localized, image: image)
                                    )
                                }
                            }
                            #if canImport(ActivityKit)
                            if #available(iOS 16.1, *) {
                                Button("为该账号开启树脂计时器") {
                                    do {
                                        try ResinRecoveryActivityController
                                            .shared
                                            .createResinRecoveryTimerActivity(
                                                for: account
                                            )
                                        isSucceedAlertShow.toggle()
                                    } catch {
                                        errorMessage = error
                                            .localizedDescription
                                        isErrorAlertShow.toggle()
                                    }
                                }
                            }
                            #endif
                            #if DEBUG
                            Button("Toast Debug") {
                                isSucceedAlertShow.toggle()
                                print("isSucceedAlertShow toggle")
                            }
                            #endif
                        }

                    case .failure:
                        HStack {
                            NavigationLink {
                                AccountDetailView(account: $account)
                            } label: {
                                ZStack {
                                    Image(
                                        systemName: "exclamationmark.arrow.triangle.2.circlepath"
                                    )
                                    .padding()
                                    .foregroundColor(.red)
                                    HStack {
                                        Spacer()
                                        Text(account.config.name ?? "")
                                            .foregroundColor(Color(
                                                UIColor
                                                    .systemGray4
                                            ))
                                            .font(.caption2)
                                            .padding(.horizontal)
                                    }
                                }
                                .padding(.horizontal)
                            }
                        }
                    }
                } else {
                    ProgressView()
                        .padding(.horizontal)
                }
            }
        }
    }
}
