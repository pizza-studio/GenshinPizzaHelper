//
//  AccountDetailView.swift
//  HSRPizzaHelper
//
//  Created by 戴藏龙 on 2023/5/5.
//

import HoYoKit
import SwiftUI

struct AccountDetailView: View {
    // MARK: Lifecycle

    init(
        unsavedName: Binding<String?>,
        unsavedUid: Binding<String?>,
        unsavedCookie: Binding<String?>,
        unsavedServer: Binding<Server>,
        unsavedDeviceFingerPrint: Binding<String>
    ) {
        _unsavedName = .init(get: {
            unsavedName.wrappedValue ?? ""
        }, set: { newValue in
            unsavedName.wrappedValue = newValue
        })
        _unsavedUid = .init(get: {
            unsavedUid.wrappedValue ?? ""
        }, set: { newValue in
            unsavedUid.wrappedValue = newValue
        })
        _unsavedCookie = .init(get: {
            unsavedCookie.wrappedValue ?? ""
        }, set: { newValue in
            unsavedCookie.wrappedValue = newValue
        })
        _unsavedServer = unsavedServer
        _deviceFingerPrint = unsavedDeviceFingerPrint
    }

    // MARK: Internal

    @Binding
    var unsavedName: String
    @Binding
    var unsavedUid: String
    @Binding
    var unsavedCookie: String
    @Binding
    var unsavedServer: Server
    @Binding
    var deviceFingerPrint: String

    var body: some View {
        List {
            Section {
                HStack {
                    Text("settings.account.username")
                    Spacer()
                    TextField(
                        "settings.account.username",
                        text: $unsavedName,
                        prompt: Text("settings.account.username")
                    )
                    .multilineTextAlignment(.trailing)
                }
                HStack {
                    Text("UID")
                    Spacer()
                    TextField("UID", text: $unsavedUid, prompt: Text("UID"))
                        .keyboardType(.numberPad)
                        .multilineTextAlignment(.trailing)
                }
                Picker("settings.account.server", selection: $unsavedServer) {
                    ForEach(Server.allCases, id: \.self) { server in
                        Text(server.localized).tag(server)
                    }
                }
            }

            Section {
                let cookieTextEditorFrame: CGFloat = 150
                TextEditor(text: $unsavedCookie)
                    .frame(height: cookieTextEditorFrame)
            } header: {
                Text("sys.label.cookie")
                    .textCase(.none)
            }
            Section {
                TextField("settings.account.deviceFingerprint", text: $deviceFingerPrint)
                    .multilineTextAlignment(.leading)
            } header: {
                Text("settings.account.deviceFingerprint")
                    .textCase(.none)
            }
        }
        .navigationBarTitle("settings.account.accountDetails", displayMode: .inline)
    }
}
