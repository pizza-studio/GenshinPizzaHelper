//
//  AccountDetailView.swift
//  GenshinPizzaHepler
//
//  Created by Bill Haku on 2022/8/7.
//

import SwiftUI

struct AccountDetailView: View {
    @EnvironmentObject var viewModel: ViewModel
    
    @Binding var account: Account
    
    var bindingName: Binding<String> {
        Binding($account.config.name)!
    }
    var bindingUid: Binding<String> {
        Binding($account.config.uid)!
    }
    var bindingCookie: Binding<String> {
        Binding($account.config.cookie)!
    }
    var bindingServer: Binding<Server> {
        Binding(projectedValue: $account.config.server)
    }
    
    var name: String {
        account.config.name!
    }
    var uid: String {
        account.config.uid!
    }
    var cookie: String {
        account.config.cookie!
    }
    var server: Server {
        account.config.server
    }

    @State private var isPresentingConfirm: Bool = false

    var body: some View {
        
        List {
            Section {
                NavigationLink(destination: TextFieldEditorView(title: "帐号名", note: "你可以添加自定义的帐号备注", content: bindingName)) {
                    InfoPreviewer(title: "帐号名", content: name)
                }
                NavigationLink(destination: TextFieldEditorView(title: "UID", content: bindingUid, keyboardType: .numberPad)) {
                    InfoPreviewer(title: "UID", content: uid)
                }
                NavigationLink(destination: TextEditorView(title: "Cookie", content: bindingCookie, showPasteButton: true)) {
                    Text("Cookie")
                }
                Picker("服务器", selection: $account.config.server) {
                    ForEach(Server.allCases, id: \.self) { server in
                        Text(server.rawValue)
                            .tag(server)
                    }
                }
            }
            TestSectionView(uid: bindingUid, cookie: bindingCookie, server: bindingServer)
        }
        .navigationBarTitle("帐号信息", displayMode: .inline)
        .onDisappear {
            viewModel.saveAccount()
        }
    }

    func cleanAccount() {
        viewModel.deleteAccount(account: account)
    }
}
