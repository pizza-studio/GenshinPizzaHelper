//
//  AddAccountView.swift
//  HSRPizzaHelper
//
//  Created by 戴藏龙 on 2023/5/3.
//

import Combine
import HoYoKit
import SwiftUI
import WidgetKit

let globalDailyNoteCardRefreshSubject: PassthroughSubject<(), Never> = .init()

// MARK: - CreateAccountSheetView

struct CreateAccountSheetView: View {
    // MARK: Lifecycle

    init(account: AccountConfiguration, isShown: Binding<Bool>) {
        self._isShown = isShown
        self._account = StateObject(wrappedValue: account)
    }

    // MARK: Internal

    var body: some View {
        NavigationStack {
            List {
                switch status {
                case .pending:
                    pendingView()
                case .gotCookie:
                    gotCookieView()
                case .gotAccount:
                    gotAccountView()
                }
            }
            .navigationTitle("settings.account.addAccount")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                if status != .pending {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("sys.done") {
                            saveAccount()
                            globalDailyNoteCardRefreshSubject.send(())
                        }
                        .disabled(status != .gotAccount)
                    }
                } else {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        menuForManagingHoYoLabAccounts()
                    }
                }
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("sys.cancel") {
                        viewContext.rollback()
                        isShown.toggle()
                    }
                }
            }
            .alert(isPresented: $isSaveAccountFailAlertShown, error: saveAccountError) {
                Button("sys.ok") {
                    isSaveAccountFailAlertShown.toggle()
                }
            }
            .alert(isPresented: $isGetAccountFailAlertShown, error: getAccountError) {
                Button("sys.ok") {
                    isGetAccountFailAlertShown.toggle()
                }
            }
            .onChange(of: status) { newValue in
                switch newValue {
                case .gotCookie:
                    getAccountForSelected()
                default:
                    return
                }
            }
        }
    }

    func saveAccount() {
        guard account.isValid() else {
            saveAccountError = .missingFieldError(
                String(localized: .init(stringLiteral: "err.mfe"))
            )
            isSaveAccountFailAlertShown.toggle()
            return
        }
        viewContext.performAndWait {
            do {
                try viewContext.save()
                isShown.toggle()
                WidgetCenter.shared.reloadAllTimelines()
            } catch {
                saveAccountError = .saveDataError(error)
                isSaveAccountFailAlertShown.toggle()
            }
        }
    }

    func getAccountForSelected() {
        Task(priority: .userInitiated) {
            if let cookie = account.cookie {
                do {
                    accountsForSelected = try await MiHoYoAPI.getUserGameRolesByCookie(region: region, cookie: cookie)
                    if let account = accountsForSelected.first {
                        self.account.name = account.nickname
                        self.account.uid = account.gameUid
                        self.account.server = .init(rawValue: account.region) ?? .init(uid: account.gameUid) ?? .china
                    } else {
                        getAccountError = .customize("account.login.error.no.account.found")
                    }
                    // Get device finger print
                    if account.server.region == .mainlandChina {
                        account.deviceFingerPrint = try await MiHoYoAPI.getDeviceFingerPrint(deviceId: account.safeUuid)
                    }
                    status = .gotAccount
                } catch {
                    getAccountError = .source(error)
                    isGetAccountFailAlertShown.toggle()
                    status = .pending
                }
            }
        }
    }

    @ViewBuilder
    func menuForManagingHoYoLabAccounts() -> some View {
        Menu {
            OtherSettingsView.linksForManagingHoYoLabAccounts
        } label: {
            Text("account.login.manageLink.shortened")
        }
    }

    @ViewBuilder
    func pendingView() -> some View {
        Group {
            Section {
                RequireLoginView(unsavedCookie: $account.cookie, region: $region)
            } footer: {
                VStack(alignment: .leading) {
                    HStack {
                        Text("account.login.manual.1")
                        NavigationLink {
                            AccountDetailView(account: account)
                        } label: {
                            Text("account.login.manual.2")
                                .font(.footnote)
                        }
                    }
                    Divider().padding(.vertical)
                    ExplanationView()
                }
            }
        }
        .onChange(of: account.cookie) { _ in
            if account.hasValidCookie {
                status = .gotCookie
            }
        }
        .interactiveDismissDisabled()
    }

    @ViewBuilder
    func gotCookieView() -> some View {
        ProgressView()
    }

    @ViewBuilder
    func gotAccountView() -> some View {
        EditAccountView(account: account, accountsForSelected: accountsForSelected)
    }

    // MARK: Private

    @EnvironmentObject
    private var alertToastVariable: AlertToastVariable

    @Binding
    private var isShown: Bool

    @StateObject
    private var account: AccountConfiguration

    @Environment(\.managedObjectContext)
    private var viewContext

    @State
    private var isSaveAccountFailAlertShown: Bool = false
    @State
    private var saveAccountError: SaveAccountError?

    @State
    private var isGetAccountFailAlertShown: Bool = false
    @State
    private var getAccountError: GetAccountError?

    @State
    private var status: AddAccountStatus = .pending

    @State
    private var accountsForSelected: [FetchedAccount] = []

    @State
    private var region: Region = .mainlandChina

    private var name: Binding<String> {
        .init {
            account.name ?? ""
        } set: { newValue in
            account.name = newValue
        }
    }
}

// MARK: - RequireLoginView

private struct RequireLoginView: View {
    // MARK: Internal

    @State
    var getCookieWebViewRegion: Region?
    @Binding
    var unsavedCookie: String?
    @Binding
    var region: Region

    var body: some View {
        Menu {
            Button("sys.server.cn") {
                assign(region: .mainlandChina)
            }
            Button("sys.server.os") {
                assign(region: .global)
            }
        } label: {
            Group {
                if isUnsavedCookieInvalid {
                    Text("settings.account.loginViaMiyousheOrHoyoLab")
                } else {
                    Text("settings.account.loginViaMiyousheOrHoyoLab.relogin")
                }
            }
            .frame(
                maxWidth: .infinity,
                maxHeight: .infinity
            )
        }
        .sheet(item: $getCookieWebViewRegion, content: { region in
            switch region {
            case .mainlandChina:
                GetCookieQRCodeView(cookie: $unsavedCookie)
            case .global:
                GetCookieWebView(
                    isShown: isCookieWebViewShown,
                    cookie: $unsavedCookie,
                    region: region
                )
            }
        })
    }

    // MARK: Private

    private var isUnsavedCookieInvalid: Bool {
        (unsavedCookie ?? "").isEmpty
    }

    private var isCookieWebViewShown: Binding<Bool> {
        .init(get: {
            getCookieWebViewRegion != nil
        }, set: { newValue in
            if !newValue {
                getCookieWebViewRegion = nil
            }
        })
    }

    private func assign(region givenRegion: Region) {
        getCookieWebViewRegion = givenRegion
        region = givenRegion
    }
}

// MARK: - AddAccountStatus

private enum AddAccountStatus {
    case pending
    case gotCookie
    case gotAccount
}

// MARK: - SaveAccountError

private enum SaveAccountError {
    case saveDataError(Error)
    case missingFieldError(String)
}

// MARK: LocalizedError

extension SaveAccountError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case let .saveDataError(error):
            return "Save Account Fail\nSave Error: \(error).\nPlease try again."
        case let .missingFieldError(field):
            return "Save Account Fail\nMissing Fields: \(field).\nPlease try again."
        }
    }

    var failureReason: String? {
        switch self {
        case let .saveDataError(error):
            return "Save Error: \(error)."
        case let .missingFieldError(field):
            return "Missing Fields: \(field)."
        }
    }

    var helpAnchor: String? {
        "Please try login again. "
    }
}

// MARK: - GetAccountError

private enum GetAccountError: LocalizedError {
    case source(Error)
    case customize(String)

    // MARK: Internal

    var errorDescription: String? {
        switch self {
        case let .source(error):
            return error.localizedDescription
        case let .customize(message):
            return message
        }
    }
}

// MARK: - ExplanationView

private struct ExplanationView: View {
    // MARK: Internal

    var body: some View {
        Group {
            VStack(alignment: .leading, spacing: 9) {
                Text(verbatim: beareOfTextHeader)
                    .font(.callout)
                    .bold()
                    .foregroundColor(.red)
                ForEach(beareOfTextContents, id: \.self) { currentLine in
                    Text(verbatim: currentLine)
                        .font(.subheadline)
                        .foregroundColor(.red)
                }
                Text("account.explanation.title.1")
                    .font(.callout)
                    .bold()
                    .padding(.top)
                Text("account.explanation.1")
                    .font(.subheadline)
                Text("account.explanation.title.2")
                    .font(.callout)
                    .bold()
                    .padding(.top)
                Text("account.explanation.2")
                    .font(.subheadline)
            }
        }
    }

    // MARK: Private

    private let bewareOfTextLines: [String] = String(
        localized: .init(stringLiteral: "account.notice.bewareof")
    ).split(separator: "\n\n").map(\.description)

    private var beareOfTextHeader: String {
        bewareOfTextLines.first ?? "BewareOf_Header"
    }

    private var beareOfTextContents: [String] {
        Array(bewareOfTextLines.dropFirst())
    }
}
