//
//  AccountDetailView.swift
//  GenshinPizzaHepler
//
//  Created by Bill Haku on 2022/8/7.
//  设置页账号详细信息View

import HBMihoyoAPI
import SwiftUI

// MARK: - AccountDetailView

struct AccountDetailView: View {
    @EnvironmentObject
    var viewModel: ViewModel

    @Binding
    var account: Account

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

    var bindingDeviceFingerPrint: Binding<String> {
        Binding($account.config.deviceFingerPrint)!
    }

    @State
    private var isPresentingConfirm: Bool = false

    @State
    var isWebShown: Bool = false

    @State
    private var connectStatus: ConnectStatus = .unknown

    var body: some View {
        List {
            Button("settings.account.reloginHoyoLabAccount") { isWebShown.toggle() }
            Section(header: Text("settings.account.config")) {
                NavigationLink(destination: TextFieldEditorView(
                    title: "settings.account.username".localized,
                    note: "settings.account.explain.youCanCustomizeAccountNamesShownInTheWidget".localized,
                    content: bindingName
                )) {
                    InfoPreviewer(title: "settings.account.username", content: name)
                }
                NavigationLink(destination: TextFieldEditorView(
                    title: "UID",
                    content: bindingUid,
                    keyboardType: .numberPad
                )) {
                    InfoPreviewer(title: "UID", content: uid)
                }
                NavigationLink(destination: TextEditorView(
                    title: "Cookie",
                    content: bindingCookie,
                    showPasteButton: true
                )) {
                    Text("Cookie")
                }
                Picker("settings.account.server", selection: $account.config.server) {
                    ForEach(Server.allCases, id: \.self) { server in
                        Text(server.localized)
                            .tag(server)
                    }
                }
                NavigationLink(destination: TextFieldEditorView(
                    title: "settings.account.deviceFingerprint".localized,
                    content: bindingDeviceFingerPrint
                )) {
                    InfoPreviewer(
                        title: "settings.account.deviceFingerprint".localized,
                        content: bindingDeviceFingerPrint.wrappedValue
                    )
                }
            }
            TestSectionView(
                connectStatus: $connectStatus,
                uid: bindingUid,
                cookie: bindingCookie,
                server: bindingServer,
                deviceFingerPrint: bindingDeviceFingerPrint
            )
        }
        .sectionSpacing(UIFont.systemFontSize)
        .navigationBarTitle("settings.account.accountInformation", displayMode: .inline)
        .onDisappear {
            viewModel.saveAccount()
        }
        .sheet(isPresented: $isWebShown) {
            GetCookieWebView(
                isShown: $isWebShown,
                cookie: bindingCookie,
                region: server.region
            )
            .onDisappear {
                connectStatus = .testing
            }
        }
        .onAppear {
            connectStatus = .testing
        }
    }
}

// MARK: - AccountDetailSheet

struct AccountDetailSheet<SheetType>: View {
    @EnvironmentObject
    var viewModel: ViewModel

    @Binding
    var account: Account

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

    @Binding
    var sheetType: SheetType?

    @State
    private var isPresentingConfirm: Bool = false

    @State
    var isWebShown: Bool = false

    @State
    private var connectStatus: ConnectStatus = .unknown

    var bindingDeviceFingerPrint: Binding<String> {
        .init {
            account.config.deviceFingerPrint ?? ""
        } set: { newValue in
            account.config.deviceFingerPrint = newValue
        }
    }

    var body: some View {
        List {
            Button("重新登录米游社账号") { isWebShown.toggle() }
            Section(header: Text("settings.account.config")) {
                NavigationLink(destination: TextFieldEditorView(
                    title: "settings.account.username".localized,
                    note: "settings.account.explain.youCanCustomizeAccountNamesShownInTheWidget".localized,
                    content: bindingName
                )) {
                    InfoPreviewer(title: "settings.account.username", content: name)
                }
                NavigationLink(destination: TextFieldEditorView(
                    title: "UID",
                    content: bindingUid,
                    keyboardType: .numberPad
                )) {
                    InfoPreviewer(title: "UID", content: uid)
                }
                NavigationLink(destination: TextEditorView(
                    title: "Cookie",
                    content: bindingCookie,
                    showPasteButton: true
                )) {
                    Text("Cookie")
                }
                Picker("settings.account.server", selection: $account.config.server) {
                    ForEach(Server.allCases, id: \.self) { server in
                        Text(server.localized)
                            .tag(server)
                    }
                }
            }
            TestSectionView(
                connectStatus: $connectStatus,
                uid: bindingUid,
                cookie: bindingCookie,
                server: bindingServer,
                deviceFingerPrint: bindingDeviceFingerPrint
            )
        }
        .sectionSpacing(UIFont.systemFontSize)
        .navigationBarTitle("settings.account.accountInformation", displayMode: .inline)
        .sheet(isPresented: $isWebShown) {
            GetCookieWebView(
                isShown: $isWebShown,
                cookie: bindingCookie,
                region: server.region
            )
            .onDisappear {
                connectStatus = .testing
            }
        }
        .onAppear {
            connectStatus = .testing
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("完成") {
                    viewModel.saveAccount()
                    sheetType = nil
                }
            }
        }
    }
}
