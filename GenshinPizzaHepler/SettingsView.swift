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
//    @AppStorage("accountName", store: UserDefaults(suiteName: "group.GenshinPizzaHelper")) var accountName: String = ""
//    @AppStorage("uid", store: UserDefaults(suiteName: "group.GenshinPizzaHelper")) var uid: String = ""
//    @AppStorage("cookie", store: UserDefaults(suiteName: "group.GenshinPizzaHelper")) var cookie: String = ""
//    @AppStorage("server", store: UserDefaults(suiteName: "group.GenshinPizzaHelper")) var server: Server = .china
    
    @State var isHelpSheepShow: Bool = false
    @State var isGameBlockAvailable: Bool = true
    
    

    var body: some View {
        NavigationView {
            List {
                Section (header: Text("我的帐号")) {
                    
                    
                    if accounts.isEmpty {
                        NavigationLink(destination: AddAccountView()) {
                            Label("添加帐户", systemImage: "plus.circle")
                        }
                    } else {
                        ForEach($viewModel.accounts, id: \.config.uid) { $account in
                            NavigationLink(destination: AccountDetailView(account: $account)) {
                                AccountInfoView(accountConfig: account.config)
                            }
                        }
                    }
                    
                    
                }
                .onAppear {
                    viewModel.fetchAccount()
                    WidgetCenter.shared.reloadAllTimelines()
                }
                
                
                if !accounts.isEmpty {
                    ForEach(accounts, id: \.config.uid) { account in
                        Section {
                            switch account.result {
                            case .success(let userData):
                                GameInfoBlock(userData: userData)
                                    .listRowInsets(.init(top: 0, leading: 0, bottom: 0, trailing: 0))
                                    .animation(.linear)
                            case .failure( _) :
                                HStack {
                                    Spacer()
                                    Image(systemName: "exclamationmark.arrow.triangle.2.circlepath")
                                        .foregroundColor(.red)
                                    Spacer()
                                }
                            }
                        }
                    }
                }
                
                
                
                
            }
            .navigationTitle("原神披萨小助手")
            .toolbar {
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        viewModel.refreshData()
                        WidgetCenter.shared.reloadAllTimelines()
                    }) {
                        Image(systemName: "arrow.counterclockwise")
                    }
                }
                
                ToolbarItemGroup(placement: .bottomBar) {
                    Button(action: {
                        isHelpSheepShow.toggle()
                    }) {
                        Image(systemName: "info.circle")
                    }
                    Spacer()
                }
                
            }
            .sheet(isPresented: $isHelpSheepShow) {
                HelpSheetView(isShow: $isHelpSheepShow)
            }
            
        }
        .ignoresSafeArea()
        .navigationViewStyle(.stack)
    }
}
