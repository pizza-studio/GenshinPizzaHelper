//
//  EditAccountView.swift
//  HSRPizzaHelper
//
//  Created by 戴藏龙 on 2023/5/5.
//

import Combine
import HoYoKit
import SwiftUI

// MARK: - EditAccountView

struct EditAccountView: View {
    // MARK: Internal

    @StateObject
    var account: AccountConfiguration

    var accountsForSelected: [FetchedAccount]?
    @State
    var validate: String = ""

    var body: some View {
        Section {
            RequireLoginView(
                unsavedCookie: $account.cookie,
                region: account.server.region
            )
        }
        Section {
            HStack {
                Text("account.label.nickname")
                Spacer()
                TextField("account.label.nickname", text: accountName)
                    .multilineTextAlignment(.trailing)
            }
        } header: {
            HStack {
                Text("UID: " + (account.uid ?? ""))
                Spacer()
                Text(account.server.description)
            }
        }
        if let accountsForSelected = accountsForSelected {
            SelectAccountView(account: account, accountsForSelected: accountsForSelected)
        }
        if account.server.region == .mainlandChina {
            RegenerateDeviceFingerPrintSection(account: account)
        }
        Section {
            NavigationLink {
                AccountDetailView(
                    unsavedName: $account.name,
                    unsavedUid: $account.uid,
                    unsavedCookie: $account.cookie,
                    unsavedServer: $account.server,
                    unsavedDeviceFingerPrint: $account.safeDeviceFingerPrint
                )
            } label: {
                Text("account.label.detail")
            }
        }

        TestAccountSectionView(account: account)
    }

    // MARK: Private

    private var accountName: Binding<String> {
        .init {
            account.name ?? ""
        } set: { newValue in
            account.name = newValue
        }
    }
}

// MARK: - RequireLoginView

private struct RequireLoginView: View {
    @Binding
    var unsavedCookie: String?

    @State
    private var isGetCookieWebViewShown: Bool = false

    let region: Region

    var body: some View {
        Button {
            isGetCookieWebViewShown.toggle()
        } label: {
            Text("account.label.relogin")
                .frame(
                    maxWidth: .infinity,
                    maxHeight: .infinity
                )
        }
        .sheet(isPresented: $isGetCookieWebViewShown, content: {
            GetCookieWebView(
                isShown: $isGetCookieWebViewShown,
                cookie: $unsavedCookie,
                region: region
            )
        })
    }
}

// MARK: - SelectAccountView

private struct SelectAccountView: View {
    // MARK: Lifecycle

    init(account: AccountConfiguration, accountsForSelected: [FetchedAccount]) {
        self._account = ObservedObject(wrappedValue: account)
        self.accountsForSelected = accountsForSelected
    }

    // MARK: Internal

    @ObservedObject
    var account: AccountConfiguration

    let accountsForSelected: [FetchedAccount]

    var body: some View {
        Section {
            // 如果该帐号绑定的UID不止一个，则显示Picker选择帐号
            if accountsForSelected.count > 1 {
                Picker("account.label.select", selection: selectedAccount) {
                    ForEach(
                        accountsForSelected,
                        id: \.gameUid
                    ) { account in
                        Text(account.nickname + "（\(account.gameUid)）")
                            .tag(account as FetchedAccount?)
                    }
                }
            }
        }
    }

    // MARK: Private

    @MainActor
    private var selectedAccount: Binding<FetchedAccount?> {
        .init {
            accountsForSelected.first { account in
                account.gameUid == self.account.uid
            }
        } set: { account in
            if let account = account {
                self.account.name = account.nickname
                self.account.uid = account.gameUid
                self.account.server = Server(rawValue: account.region) ?? .china
            }
        }
    }
}

// MARK: - RegenerateDeviceFingerPrintSection

private struct RegenerateDeviceFingerPrintSection: View {
    // MARK: Lifecycle

    init(account: AccountConfiguration) {
        self._account = ObservedObject(wrappedValue: account)
    }

    // MARK: Internal

    enum Status {
        case pending
        case progress(Task<(), Never>)
        case succeed
        case fail(Error)
    }

    @ObservedObject
    var account: AccountConfiguration

    @State
    var isErrorAlertShown: Bool = false
    @State
    var error: AnyLocalizedError?

    @State
    var status: Status = .pending

    var body: some View {
        Section {
            Button {
                if case let .progress(task) = status {
                    task.cancel()
                }
                let task = Task {
                    do {
                        account.deviceFingerPrint = try await MiHoYoAPI.getDeviceFingerPrint(deviceId: account.safeUuid)
                        status = .succeed
                    } catch {
                        status = .fail(error)
                        self.error = AnyLocalizedError(error)
                    }
                }
                status = .progress(task)
            } label: {
                switch status {
                case .pending:
                    Text("account.regenerateDeviceFingerPrint.label")
                case .progress:
                    ProgressView()
                case .succeed:
                    Label {
                        Text("account.regenerateDeviceFingerPrint.label")
                    } icon: {
                        Image(systemSymbol: .checkmarkCircle)
                            .foregroundStyle(.green)
                    }
                case .fail:
                    Label {
                        Text("account.regenerateDeviceFingerPrint.label")
                    } icon: {
                        Image(systemSymbol: .xmarkCircle)
                            .foregroundStyle(.red)
                    }
                }
            }
            .disabled({ if case .progress = status { true } else { false }}())
            .alert(isPresented: $isErrorAlertShown, error: error) { _ in
                Button("sys.done") { isErrorAlertShown = false }
            } message: { error in
                Text(error.localizedDescription)
            }
        } footer: {
            Text("account.regenerateDeviceFingerPrint.footer")
        }
    }
}
