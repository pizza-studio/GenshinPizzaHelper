//
//  AccountDetailView.swift
//  GenshinPizzaHepler
//
//  Created by Bill Haku on 2022/8/7.
//

import SwiftUI

struct AccountDetailView: View {
    @StateObject var viewModel = ViewModel()
    @AppStorage("accountNum", store: UserDefaults(suiteName: "group.GenshinPizzaHelper")) var accountNum: Int = 1
    @AppStorage("accountName", store: UserDefaults(suiteName: "group.GenshinPizzaHelper")) var accountName: String = ""
    @AppStorage("uid", store: UserDefaults(suiteName: "group.GenshinPizzaHelper")) var uid: String = ""
    @AppStorage("cookie", store: UserDefaults(suiteName: "group.GenshinPizzaHelper")) var cookie: String = ""
    @AppStorage("server", store: UserDefaults(suiteName: "group.GenshinPizzaHelper")) var server: Server = .china

    @State private var isPresentingConfirm: Bool = false

    var body: some View {
        List {
            Section {
                NavigationLink(destination: TextEditorView(title: "帐号名", note: "你可以添加自定义的帐号备注", content: $accountName)) {
                    InfoPreviewer(title: "帐号名", content: accountName)
                }
                NavigationLink(destination: TextEditorView(title: "UID", content: $uid)) {
                    InfoPreviewer(title: "UID", content: uid)
                }
                NavigationLink(destination: TextEditorView(title: "Cookie", content: $cookie)) {
                    Text("Cookie")
                }
                Picker("服务器", selection: $server) {
                    ForEach(Server.allCases, id: \.self) { server in
                        Text(server.rawValue)
                            .tag(server)
                    }
                }
            }

            Section {
                if #available(iOS 15.0, *) {
                    Button(role: .destructive) {
                        isPresentingConfirm = true
                    } label: {
                        Text("删除帐号")
                            .frame(minWidth: 0, maxWidth: .infinity)
                    }
                    .confirmationDialog("Sure?", isPresented: $isPresentingConfirm) {
                        Button("确认清空数据", role: .destructive) {
                            cleanAccount()
                        }
                    } message: {
                        Text("确认要删除该帐号吗？")
                    }
                } else {
                    Button() {
                        cleanAccount()
                    } label: {
                        Text("删除帐号")
                            .frame(minWidth: 0, maxWidth: .infinity)
                    }
                    .foregroundColor(.red)
                    .padding()
                }
            }
        }
        .navigationBarTitle("帐号信息", displayMode: .inline)
    }

    func cleanAccount() {
        accountNum -= 1
        accountName = ""
        uid = ""
        cookie = ""
        server = .china
    }
}
