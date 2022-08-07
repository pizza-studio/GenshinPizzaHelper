//
//  AddAccountView.swift
//  GenshinPizzaHepler
//
//  Created by Bill Haku on 2022/8/7.
//

import SwiftUI

struct AddAccountView: View {
    @StateObject var viewModel = ViewModel()
    @AppStorage("accountNum", store: UserDefaults(suiteName: "group.GenshinPizzaHelper")) var accountNum: Int = 0
    @AppStorage("accountName", store: UserDefaults(suiteName: "group.GenshinPizzaHelper")) var accountName: String = ""
    @AppStorage("uid", store: UserDefaults(suiteName: "group.GenshinPizzaHelper")) var uid: String = ""
    @AppStorage("cookie", store: UserDefaults(suiteName: "group.GenshinPizzaHelper")) var cookie: String = ""
    @AppStorage("server", store: UserDefaults(suiteName: "group.GenshinPizzaHelper")) var server: Server = .china

    @State private var unsavedName: String = "我的帐号"
    @State private var unsavedUid: String = ""
    @State private var unsavedCookie: String = ""
    @State private var unsavedServer: Server = .china

    @State private var isPresentingConfirm: Bool = false
    @State private var isAlertShow: Bool = false

    var body: some View {
        List {
            Section {
                InfoEditor(title: "帐号名", content: $unsavedName)
                InfoEditor(title: "UID", content: $unsavedUid)
                NavigationLink(destination: TextEditorView(title: "Cookie", content: $unsavedCookie)) {
                    Text("Cookie")
                }
                Picker("服务器", selection: $unsavedServer) {
                    ForEach(Server.allCases, id: \.self) { server in
                        Text(server.rawValue)
                            .tag(server)
                    }
                }
            }

            Section {

            }
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

                    accountName = unsavedName
                    uid = unsavedUid
                    cookie = unsavedCookie
                    server = unsavedServer

                    accountNum += 1
                }
            }
        }
        .alert(isPresented: $isAlertShow) {
            Alert(title: Text("UID或Cookie未填写！"))
        }
    }
}
