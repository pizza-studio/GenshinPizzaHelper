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
    var account: Account

    var accountsForSelected: [FetchedAccount]?
    @State
    var validate: String = ""

    var body: some View {
        Section {
            RequireLoginView(
                unsavedCookie: $account.cookie,
                unsavedFP: $account.safeDeviceFingerPrint,
                region: account.server.region
            )
        }
        Section {
            HStack {
                Text("settings.account.username")
                Spacer()
                TextField("settings.account.username", text: accountName)
                    .multilineTextAlignment(.trailing)
            }
        } header: {
            HStack {
                Text(verbatim: "UID: " + (account.uid ?? ""))
                Spacer()
                Text(account.server.localized)
            }
        }
        if let accountsForSelected = accountsForSelected {
            SelectAccountView(account: account, accountsForSelected: accountsForSelected)
        }
        Section {
            NavigationLink {
                AccountDetailView(account: account)
            } label: {
                Text("settings.account.accountDetails")
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
    @Binding
    var unsavedFP: String

    @State
    private var isGetCookieWebViewShown: Bool = false

    let region: Region

    var body: some View {
        Button {
            isGetCookieWebViewShown.toggle()
        } label: {
            Text("settings.account.loginViaMiyousheOrHoyoLab.relogin")
                .frame(
                    maxWidth: .infinity,
                    maxHeight: .infinity
                )
        }
        .sheet(isPresented: $isGetCookieWebViewShown, content: {
            switch region {
            case .mainlandChina:
                GetCookieQRCodeView(cookie: $unsavedCookie, deviceFP: $unsavedFP)
            case .global:
                GetCookieWebView(
                    isShown: $isGetCookieWebViewShown,
                    cookie: $unsavedCookie,
                    region: region
                )
            }
        })
    }
}

// MARK: - SelectAccountView

private struct SelectAccountView: View {
    // MARK: Lifecycle

    init(account: Account, accountsForSelected: [FetchedAccount]) {
        self._account = ObservedObject(wrappedValue: account)
        self.accountsForSelected = accountsForSelected
    }

    // MARK: Internal

    @ObservedObject
    var account: Account

    let accountsForSelected: [FetchedAccount]

    var body: some View {
        Section {
            // 如果该账号绑定的UID不止一个，则显示Picker选择账号
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
                self.account.server = .init(rawValue: account.region) ?? .init(uid: account.gameUid) ?? .china
            }
        }
    }
}
