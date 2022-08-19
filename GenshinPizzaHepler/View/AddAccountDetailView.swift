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
    
    var body: some View {
        List {
            Section {
                NavigationLink(destination: TextFieldEditorView(title: "帐号名", note: "你可以添加自定义的帐号备注", content: $unsavedName)) {
                    InfoPreviewer(title: "帐号名", content: unsavedName)
                }
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
        }
        .navigationBarTitle("帐号信息", displayMode: .inline)
    }
}

