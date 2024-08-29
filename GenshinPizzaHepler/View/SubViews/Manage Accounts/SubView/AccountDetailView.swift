//
//  AccountDetailView.swift
//  HSRPizzaHelper
//
//  Created by 戴藏龙 on 2023/5/5.
//

import HoYoKit
import SwiftUI

// MARK: - AccountDetailView

struct AccountDetailView: View {
    // MARK: Lifecycle

    init(account: Account) {
        self._account = ObservedObject(wrappedValue: account)
    }

    // MARK: Internal

    @ObservedObject
    var account: Account

    var body: some View {
        List {
            Section {
                HStack {
                    Text("settings.account.username")
                    Spacer()
                    TextField(
                        "settings.account.username",
                        text: $account.safeName,
                        prompt: Text("settings.account.username")
                    )
                    .multilineTextAlignment(.trailing)
                }
                HStack {
                    Text(verbatim: "UID")
                    Spacer()
                    TextField("UID", text: $account.safeUid, prompt: Text(verbatim: "UID"))
                        .keyboardType(.numberPad)
                        .multilineTextAlignment(.trailing)
                }
                Picker("settings.account.server", selection: $account.server) {
                    ForEach(Server.allCases, id: \.self) { server in
                        Text(server.localized).tag(server)
                    }
                }
            }

            Section {
                let cookieTextEditorFrame: CGFloat = 150
                TextEditor(text: $account.safeCookie)
                    .frame(height: cookieTextEditorFrame)
            } header: {
                Text("sys.label.cookie")
                    .textCase(.none)
            }

            Section {
                TextField("settings.account.deviceFingerprint", text: $account.safeDeviceFingerPrint)
                    .multilineTextAlignment(.leading)
                RegenerateDeviceFingerPrintButton(account: account)

            } header: {
                Text("settings.account.deviceFingerprint")
                    .textCase(.none)
            }
        }
        .navigationBarTitle("settings.account.accountDetails", displayMode: .inline)
    }
}

// MARK: - RegenerateDeviceFingerPrintButton

private struct RegenerateDeviceFingerPrintButton: View {
    // MARK: Lifecycle

    init(account: Account) {
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
    var account: Account

    @State
    var isErrorAlertShown: Bool = false
    @State
    var error: AnyLocalizedError?

    @State
    var status: Status = .pending

    var body: some View {
        Button {
            if case let .progress(task) = status {
                task.cancel()
            }
            let task = Task {
                do {
                    account.deviceFingerPrint = try await MiHoYoAPI.getDeviceFingerPrint(
                        region: account.server.region
                    ).deviceFP
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
                Text("settings.account.regenerateDeviceFingerPrint.label")
            case .progress:
                ProgressView()
            case .succeed:
                Label {
                    Text("settings.account.regenerateDeviceFingerPrint.label")
                } icon: {
                    Image(systemSymbol: .checkmarkCircle)
                        .foregroundStyle(.green)
                }
            case .fail:
                Label {
                    Text("settings.account.regenerateDeviceFingerPrint.label")
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
    }
}
