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
    @State private var unsavedUid: String = ""
    @State private var unsavedCookie: String = ""
    @State private var unsavedServer: Server = .china
    
    @State private var isPresentingConfirm: Bool = false
    @State private var isAlertShow: Bool = false
    @State private var connectStatus: ConnectStatus = .unknown
    @State private var errorInfo: String = ""
    
    @State private var isWebShown: Bool = false
    
    @State private var accountsForSelected: [FetchedAccount] = []
    @State private var selectedAccount: FetchedAccount?

    var body: some View {
        List {
            Button("登录米游社账号") { isWebShown.toggle() }
            Button("cookie") {
                DispatchQueue.main.async {
                    if isWebShown == false {
                        print("unsaved cookie is: "+unsavedCookie)
                        API.Features.getUserGameRolesByCookie(unsavedCookie, unsavedServer.region) { result in
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
            
//            if accountsForSelected.count != 0 {
                Section {
                    InfoEditor(title: "自定义帐号名", content: $unsavedName, placeholderText: unsavedName)
                    
//                    HStack {
//                        Text("UID")
//                        Spacer()
//                        Text(selectedAccount!.gameUid)
//                    }

                    if !accountsForSelected.isEmpty {
                        Picker("请选择账号", selection: $selectedAccount) {
                            ForEach(accountsForSelected, id: \.gameUid) { account in
                                Text(account.nickname + "（\(account.gameUid)）")
                                    .tag(account as FetchedAccount?)
                            }
                        }
                    }
                    
//                }

                TestSectionView(uid: $unsavedUid, cookie: $unsavedCookie, server: $unsavedServer)
            }
        }
        .navigationBarTitle("帐号信息", displayMode: .inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("完成") {
                    if selectedAccount == nil {
                        isAlertShow.toggle()
                        return
                    }
                    if (unsavedName == "我的账号") || (unsavedName == "") {
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
            GetCookieWebView(isShown: $isWebShown, cookie: $unsavedCookie, region: .cn)
        }
        .onChange(of: isWebShown) { isWebShown in
            DispatchQueue.main.async {
                if isWebShown == false {
                    DispatchQueue.main.async {
                        API.Features.getUserGameRolesByCookie(unsavedCookie, unsavedServer.region) { result in
                            switch result {
                            case .failure(let fetchError):
                                print(fetchError)
                            case .success(let fetchedAccountArray):
                                accountsForSelected = fetchedAccountArray
                                
                                if !accountsForSelected.isEmpty { selectedAccount = accountsForSelected.first! }
                                // TODO: 需要review——如果之前登陆过其他账号，需要随便发一次请求才能正确抓到信息（我也不知道为什么）
                                API.Features.fetchInfos(region: unsavedServer.region,
                                                        serverID: unsavedServer.id,
                                                        uid: unsavedUid,
                                                        cookie: unsavedCookie) { result in
                                    switch result {
                                    case .failure(_ ):
                                        API.Features.getUserGameRolesByCookie(unsavedCookie, unsavedServer.region) { result in
                                            switch result {
                                            case .failure(let fetchError):
                                                print(fetchError)
                                            case .success(let fetchedAccountArray):
                                                accountsForSelected = fetchedAccountArray
                                                if !accountsForSelected.isEmpty { selectedAccount = accountsForSelected.first! }
                                            }
                                        }
                                    case .success(_):
                                        return
                                    }
                                }
                            }
                        }
                    }
                    
                }
            }
            
        }
    }
}
