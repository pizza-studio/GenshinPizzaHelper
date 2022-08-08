//
//  AddAccountView.swift
//  GenshinPizzaHepler
//
//  Created by Bill Haku on 2022/8/7.
//

import SwiftUI

struct AddAccountView: View {
    @EnvironmentObject var viewModel: ViewModel

    @State private var unsavedName: String = "我的帐号"
    @State private var unsavedUid: String = ""
    @State private var unsavedCookie: String = ""
    @State private var unsavedServer: Server = .china

    @State private var isPresentingConfirm: Bool = false
    @State private var isAlertShow: Bool = false
    @State private var connectStatus: ConnectStatus = .unknown
    @State private var errorInfo: String = ""

    var body: some View {
        List {
            Section {
                InfoEditor(title: "帐号名", content: $unsavedName)
                InfoEditor(title: "UID", content: $unsavedUid, keyboardType: .numberPad)
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

            TestSectionView(uid: $unsavedUid, cookie: $unsavedCookie, server: $unsavedServer)
        }
        .navigationBarTitle("帐号信息", displayMode: .inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("完成") {
                    if unsavedUid == "" {
                        isAlertShow.toggle()
                        return
                    }
                    else if unsavedCookie == "" {
                        isAlertShow.toggle()
                        return
                    }
                    if unsavedName == "" {
                        unsavedName = unsavedUid
                    }

                    viewModel.addAccount(name: unsavedName, uid: unsavedUid, cookie: unsavedCookie, server: unsavedServer)
                }
            }
        }
        .alert(isPresented: $isAlertShow) {
            Alert(title: Text("UID或Cookie未填写！"))
        }
    }
}
