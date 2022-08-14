//
//  SettingsView.swift
//  GenshinPizzaHepler
//
//  Created by Bill Haku on 2022/8/7.
//

import SwiftUI
import WidgetKit

struct SettingsView: View {
    @EnvironmentObject var viewModel: ViewModel
    var accounts: [Account] { viewModel.accounts }
    
    
//    @AppStorage("accountNum", store: UserDefaults(suiteName: "group.GenshinPizzaHelper")) var accountNum: Int = 0
//    @AppStorage("accountName", store: UserDefaults(suiteName: "group.GenshinPizzaHelper")) var s: String = ""
//    @AppStorage("uid", store: UserDefaults(suiteName: "group.GenshinPizzaHelper")) var uid: String = ""
//    @AppStorage("cookie", store: UserDefaults(suiteName: "group.GenshinPizzaHelper")) var cookie: String = ""
    
    @State var isGameBlockAvailable: Bool = true
    @State private var sheetType: SettingsViewSheetType? = nil

    var body: some View {
        NavigationView {
            List {
                Section(header: Text("我的帐号")) {
                    ForEach($viewModel.accounts, id: \.config.uuid) { $account in
                        NavigationLink(destination: AccountDetailView(account: $account)) {
                            AccountInfoView(accountConfig: $account.config)
                        }
                    }
                    .onDelete { indexSet in
                        indexSet.forEach { viewModel.deleteAccount(account: accounts[$0]) }
                    }
                    NavigationLink(destination: AddAccountView()) {
                        Label("添加帐户", systemImage: "plus.circle")
                    }
                }
                .onAppear {
                    // 检查是否同意过用户协议
                    let isPolicyShown = UserDefaults.standard.bool(forKey: "isPolicyShown")
                    if !isPolicyShown {
                        sheetType = .userPolicy
                    }
                    viewModel.fetchAccount()
                    WidgetCenter.shared.reloadAllTimelines()
                }
                
                ForEach(viewModel.accounts, id: \.config.uuid) { account in
                    Section(header: Text(account.config.name!), footer: Text("UID: "+account.config.uid!)) {
                        switch account.result {
                        case .success(let userData):
                            GameInfoBlock(userData: userData, accountName: nil)
                                .listRowInsets(.init(top: 0, leading: 0, bottom: 0, trailing: 0))
                                .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                                .aspectRatio(170/364, contentMode: .fill)
                                .animation(.linear)
                                .listRowBackground(Color.white.opacity(0))
                        case .failure( _) :
                            HStack {
                                Spacer()
                                Image(systemName: "exclamationmark.arrow.triangle.2.circlepath")
                                    .foregroundColor(.red)
                                Spacer()
                            }
                            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                            .aspectRatio(170/364, contentMode: .fill)
                        }
                    }
                }
            }
            .navigationTitle("原神披萨小助手")
            .toolbar {
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        viewModel.refreshData()
                        print(accounts.first?.config.uid ?? "nil")
                        WidgetCenter.shared.reloadAllTimelines()
                    }) {
                        Image(systemName: "arrow.counterclockwise")
                    }
                }
                
                ToolbarItemGroup(placement: .bottomBar) {
                    Button(action: {
                        sheetType = .help
                    }) {
                        Image(systemName: "info.circle")
                    }
                    Spacer()
                }
                
            }
            .sheet(item: $sheetType) { item in
                switch item {
                case .help:
                    HelpSheetView(sheet: $sheetType)
                case .userPolicy:
                    UserPolicyView(sheet: $sheetType)
                        .allowAutoDismiss(false)
                }
            }
            
        }
        .ignoresSafeArea()
        .navigationViewStyle(.stack)
    }
}

enum SettingsViewSheetType: Identifiable {
    var id: Int {
        hashValue
    }

    case help
    case userPolicy
}
