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
    @State private var connectStatus: ConnectStatus = .unknown
    @State private var errorCode: String = ""
    @State private var errorInfo: String = ""

    var body: some View {
        List {
            Section {
                NavigationLink(destination: TextFieldEditorView(title: "帐号名", note: "你可以添加自定义的帐号备注", content: $accountName)) {
                    InfoPreviewer(title: "帐号名", content: accountName)
                }
                NavigationLink(destination: TextFieldEditorView(title: "UID", content: $uid, keyboardType: .numberPad)) {
                    InfoPreviewer(title: "UID", content: uid)
                }
                NavigationLink(destination: TextEditorView(title: "Cookie", content: $cookie, showPasteButton: true)) {
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
                Button(action: {
                    connectStatus = .testing
                    API.Features.fetchInfos(region: server.region,
                                            serverID: server.id,
                                            uid: uid,
                                            cookie: cookie)
                    { retCode, userLoginData, errInfo in
                        if retCode != 0 {
                            connectStatus = .fail
                            errorCode = String(retCode)
                            errorInfo = errInfo ?? "Unknown Error"
                        } else {
                            connectStatus = .success
                        }
                    }
                }) {
                    HStack {
                        Text("测试连接")
                        Spacer()
                        switch connectStatus {
                        case .unknown:
                            Text("")
                        case .success:
                            Image(systemName: "checkmark")
                                .foregroundColor(.green)
                        case .fail:
                            Image(systemName: "xmark")
                                .foregroundColor(.red)
                        case .testing:
                            ProgressView()
                        }
                    }
                }
                if connectStatus == .fail {
                    InfoPreviewer(title: "错误码", content: errorCode)
                    InfoPreviewer(title: "错误内容", content: errorInfo)
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
                        Button("删除", role: .destructive) {
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
