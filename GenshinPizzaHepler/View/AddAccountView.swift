//
//  AddAccountView.swift
//  GenshinPizzaHepler
//
//  Created by Bill Haku on 2022/8/7.
//

import SwiftUI
import WebKit

struct AddAccountView: View {
    @EnvironmentObject var viewModel: ViewModel
    
    @Environment(\.presentationMode) var presentationMode

    @State private var unsavedName: String = "我的账号"
    @State private var unsavedUid: String = "12345678"
    @State private var unsavedCookie: String = ""
    @State private var unsavedServer: Server = .china
    
    @State private var connectStatus: ConnectStatus = .unknown
    
    @State private var errorInfo: String = ""
    
    @State private var isPresentingConfirm: Bool = false
    @State private var isAlertShow: Bool = false
    @State private var isWebShown: Bool = false
    
    @State private var accountsForSelected: [FetchedAccount] = []
    @State private var selectedAccount: FetchedAccount?
    
    @State private var region: Region = .cn
    
    var body: some View {
        List {
            
            Menu("登录米游社账号") {
                Button("国服") {
                    region = .cn
                    isWebShown = true
                }
                Button("国际服") {
                    region = .global
                    isWebShown = true
                }
            }
            TextField("COOKIE", text: $unsavedCookie)
            
            if accountsForSelected.count != 0 {
                Section(footer: Text("UID: " + selectedAccount!.gameUid)) {
                    InfoEditor(title: "自定义帐号名", content: $unsavedName, placeholderText: unsavedName)
                    if accountsForSelected.count > 1 {
                        Picker("请选择账号", selection: $selectedAccount) {
                            ForEach(accountsForSelected, id: \.gameUid) { account in
                                Text(account.nickname + "（\(account.gameUid)）")
                                    .tag(account as FetchedAccount?)
                            }
                        }
                    }
                    
                }

                TestSectionView(connectStatus: $connectStatus, uid: $unsavedUid, cookie: $unsavedCookie, server: $unsavedServer)
            }
        }
        .navigationBarTitle("帐号信息", displayMode: .inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("完成") {
                    if (unsavedUid == "") || (unsavedCookie == "") {
                        isAlertShow.toggle()
                        return
                    }
                    if unsavedName == "" {
                        unsavedName = unsavedUid
                    }
                    viewModel.addAccount(name: unsavedName, uid: unsavedUid, cookie: unsavedCookie, server: unsavedServer)
                    presentationMode.wrappedValue.dismiss()
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        ReviewHandler.requestReview()
                    }
                }
            }
        }
        .alert(isPresented: $isAlertShow) {
            Alert(title: Text("尚未完成账号设置"))
        }
        .onChange(of: selectedAccount) { value in
            if let selectedAccount = value {
                unsavedName = selectedAccount.nickname
                unsavedUid = selectedAccount.gameUid
                unsavedServer = Server.id(selectedAccount.region)
            }
        }
        .sheet(isPresented: $isWebShown) {
            GetCookieWebView(isShown: $isWebShown, cookie: $unsavedCookie, region: region)
        }
        .onChange(of: isWebShown) { isWebShown in
            DispatchQueue.main.async {
                if isWebShown == false {
                    DispatchQueue.main.async {
                        API.Features.getUserGameRolesByCookie(unsavedCookie, region) { result in
                            switch result {
                            case .failure(let fetchError):
                                switch region {
                                case .cn:
                                    print(fetchError)
                                    API.Features.fetchInfos(region: unsavedServer.region,
                                                            serverID: unsavedServer.id,
                                                            uid: unsavedUid,
                                                            cookie: unsavedCookie) { result in
                                        API.Features.getUserGameRolesByCookie(unsavedCookie, region) { result in
                                            switch result {
                                            case .failure(let fetchError):
                                                print(fetchError)
                                            case .success(let fetchedAccountArray):
                                                accountsForSelected = fetchedAccountArray
                                                if !accountsForSelected.isEmpty { selectedAccount = accountsForSelected.first! }
                                            }
                                        }
                                    }
                                case .global:
                                    print(fetchError)
                                    let globalServers: [Server] = [.cht, .asia, .eu, .us]
                                    globalServers.forEach { server in
                                        API.Features.fetchInfos(region: region,
                                                                serverID: server.id,
                                                                uid: unsavedUid,
                                                                cookie: unsavedCookie) { result in
                                            API.Features.getUserGameRolesByCookie(unsavedCookie, region) { result in
                                                switch result {
                                                case .failure(let fetchError):
                                                    print(fetchError)
                                                case .success(let fetchedAccountArray):
                                                    accountsForSelected = fetchedAccountArray
                                                    if !accountsForSelected.isEmpty { selectedAccount = accountsForSelected.first! }
                                                }
                                            }
                                        }
                                    }
                                    
                                }
                                
                            case .success(let fetchedAccountArray):
                                accountsForSelected = fetchedAccountArray
                                if !accountsForSelected.isEmpty { selectedAccount = accountsForSelected.first! }
                            }
                        }
                    }
                    
                }
                
            }
            
        }
    }
}
