//
//  AddAccountDetailView.swift
//  GenshinPizzaHepler
//
//  Created by 戴藏龙 on 2022/8/19.
//

import SwiftUI

struct AddAccountDetailView: View {
    @Binding var unsavedName: String
    @Binding var unsavedUid: String
    @Binding var unsavedCookie: String
    @Binding var unsavedServer: Server
    @Binding var connectStatus: ConnectStatus
    
    var body: some View {
        List {
            Section(header: Text("账号配置")) {
                NavigationLink(destination: TextFieldEditorView(title: "UID", content: $unsavedUid, keyboardType: .numberPad)) {
                    InfoPreviewer(title: "UID", content: unsavedUid)
                }
                NavigationLink(destination: TextEditorView(title: "Cookie", content: $unsavedCookie, showPasteButton: true, showShortCutsLink: true)) {
                    Text("Cookie")
                }
                Picker("服务器", selection: $unsavedServer) {
                    ForEach(Server.allCases, id: \.self) { server in
                        Text(server.rawValue)
                            .tag(server)
                    }
                }
            }
            if (unsavedUid != "") && (unsavedCookie != "") {
                TestSectionView(connectStatus: $connectStatus, uid: $unsavedUid, cookie: $unsavedCookie, server: $unsavedServer)
            }
        }
        .navigationBarTitle("帐号信息", displayMode: .inline)
    }
}

