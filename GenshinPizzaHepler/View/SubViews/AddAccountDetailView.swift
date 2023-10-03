//
//  AddAccountDetailView.swift
//  GenshinPizzaHepler
//
//  Created by 戴藏龙 on 2022/8/19.
//  添加账号页面的详细信息

import HBMihoyoAPI
import SwiftUI

struct AddAccountDetailView: View {
    @Binding
    var unsavedName: String
    @Binding
    var unsavedUid: String
    @Binding
    var unsavedCookie: String
    @Binding
    var unsavedServer: Server
    @Binding
    var connectStatus: ConnectStatus
    @Binding
    var unsavedDeviceFingerPrint: String

    var body: some View {
        List {
            Section(header: Text("settings.account.config")) {
                InfoEditor(
                    title: "UID",
                    content: $unsavedUid,
                    keyboardType: .numberPad
                )
                NavigationLink(destination: TextEditorView(
                    title: "Cookie",
                    content: $unsavedCookie,
                    showPasteButton: true,
                    showShortCutsLink: true
                )) {
                    Text("Cookie")
                }
                Picker("settings.account.server", selection: $unsavedServer) {
                    ForEach(Server.allCases, id: \.self) { server in
                        Text(server.rawValue)
                            .tag(server)
                    }
                }
            }
            Section {
                InfoEditor(title: "设备指纹", content: $unsavedDeviceFingerPrint)
            } footer: {
                Text("设备指纹仅限国服账号需要设置")
                    .textCase(.none)
            }
            if unsavedUid != "", unsavedCookie != "" {
                TestSectionView(
                    connectStatus: $connectStatus,
                    uid: $unsavedUid,
                    cookie: $unsavedCookie,
                    server: $unsavedServer,
                    deviceFingerPrint: $unsavedDeviceFingerPrint
                )
            }
        }
        .navigationBarTitle("settings.account.accountInformation", displayMode: .inline)
    }
}
