//
//  ToolsView.swift
//  GenshinPizzaHepler
//
//  Created by Bill Haku on 2022/9/17.
//

import SwiftUI

@available(iOS 15.0, *)
struct ToolsView: View {
    @EnvironmentObject var viewModel: ViewModel
    var accounts: [Account] { viewModel.accounts }
    @State var selectedAccount = 0
    @State private var sheetType: SheetTypes? = nil

    @State var accountCharactersInfo: BasicInfos? = nil
    @State var playerDetailDatas: PlayerDetails? = nil

    var body: some View {
        NavigationView {
            List {
                if let accountCharactersInfo = accountCharactersInfo, let playerDetailDatas = playerDetailDatas {
                    Section(footer: Text("签名：\(playerDetailDatas.playerInfo.signature)").font(.footnote)) {
                        VStack {
                            HStack {
                                Text("我的角色")
                                    .font(.footnote)
                                Spacer()
                            }
                            Divider()
                        }
                        .listRowSeparator(.hidden)
                        ScrollView(.horizontal) {
                            HStack {
                                ForEach(accountCharactersInfo.avatars) { avatar in
                                    VStack {
                                        WebImage(urlStr: avatar.image)
                                            .frame(width: 75, height: 75)
                                            .background(avatar.rarity == 5 ? Color.yellow : Color.blue)
                                            .clipShape(Circle())
                                    }
                                }
                            }
                            .padding()
                        }
                        .padding(.bottom, 10)
                        .listRowInsets(.init(top: 0, leading: 0, bottom: 0, trailing: 0))
                    }

                    Section {
                        HStack(spacing: 30) {
                            VStack {
                                VStack {
                                    HStack {
                                        Text("深境螺旋")
                                            .font(.footnote)
                                        Spacer()
                                    }
                                    .padding(.top, 5)
                                    Divider()
                                }
                                Text("\(playerDetailDatas.playerInfo.towerFloorIndex)-\(playerDetailDatas.playerInfo.towerLevelIndex)")
                                    .font(.largeTitle)
                                    .frame(height: 120)
                                    .padding(.bottom, 10)
                            }
                            .padding(.horizontal)
                            .background(RoundedRectangle(cornerRadius: 10).fill(Color(UIColor.systemBackground)))

                            VStack {
                                VStack {
                                    HStack {
                                        Text("游戏内公开信息")
                                            .font(.footnote)
                                        Spacer()
                                    }
                                    .padding(.top, 5)
                                    Divider()
                                }
                                Text("Lv.\(playerDetailDatas.playerInfo.level)")
                                    .font(.largeTitle)
                                    .frame(height: 120)
                                    .padding(.bottom, 10)
                            }
                            .padding(.horizontal)
                            .background(RoundedRectangle(cornerRadius: 10).fill(Color(UIColor.systemBackground)))
                            .onTapGesture {
                                sheetType = .characters
                            }
                        }
                    }
                    .listRowInsets(.init(top: 0, leading: 0, bottom: 0, trailing: 0))
                    .listRowBackground(Color(UIColor.secondarySystemBackground))
                }
                
                Section {
                    VStack {
                        HStack {
                            Text("第三方工具")
                                .font(.footnote)
                            Spacer()
                        }
                    }
                    Text("原神中日英词典")
                    Text("原神计算器")
                }

            }
            .navigationTitle("原神小工具")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                Menu {
                    Picker("选择帐号", selection: $selectedAccount) {
                        ForEach(accounts, id:\.config.id) { account in
                            Text(account.config.name ?? "Name Error")
                                .tag(getAccountItemIndex(item: account))
                        }
                    }
                } label: {
                    Label("选择帐号", systemImage: "arrow.left.arrow.right.circle")
                }
            }
            .onChange(of: selectedAccount) { _ in
                print(accounts[selectedAccount].config.name ?? "")
                fetchSummaryData()
            }
            .onChange(of: accounts) { _ in
                fetchSummaryData()
            }
            .onAppear(perform: fetchSummaryData)
            .sheet(item: $sheetType) { type in
                switch type {
                case .characters:
                    if playerDetailDatas != nil {
                        characterSheetView()
                    } else {
                        Text("Data error")
                    }
                case .spiralAbyss:
                    spiralAbyssSheetView()
                }
            }
        }
    }

    @ViewBuilder
    func characterSheetView() -> some View {
        NavigationView {
            List {
                Section(footer: Text(playerDetailDatas!.playerInfo.signature).font(.footnote)) {
                    Text(playerDetailDatas!.playerInfo.nickname)
                    Text("Lv. \(playerDetailDatas!.playerInfo.level)")
                }
                Section {
                    TabView {
                        ForEach(playerDetailDatas!.avatarInfoList, id:\.avatarId) { avatarInfo in
                            CharacterDetailDatasView(characterDetailData: avatarInfo)
                        }
                    }
                    .tabViewStyle(.page)
                    .indexViewStyle(.page(backgroundDisplayMode: .always))
                    .frame(height: 500)
//                    .fixedSize(horizontal: false, vertical: false)
                }
            }
        }
    }

    @ViewBuilder
    func spiralAbyssSheetView() -> some View {
        Text("")
    }

    func getAccountItemIndex(item: Account) -> Int {
        return accounts.firstIndex { currentItem in
            return currentItem.config.id == item.config.id
        } ?? 0
    }

    private func fetchSummaryData() -> Void {
        DispatchQueue.global(qos: .userInteractive).async {
            if !viewModel.accounts.isEmpty {
                API.Features.fetchBasicInfos(region: accounts[selectedAccount].config.server.region, serverID: accounts[selectedAccount].config.server.id, uid: accounts[selectedAccount].config.uid ?? "", cookie: accounts[selectedAccount].config.cookie ?? "") { result in
                    switch result {
                    case .success(let data) :
                        accountCharactersInfo = data
                    case .failure(_):
                        break
                    }
                }
            } else {
                print("accounts is empty")
            }
        }
        DispatchQueue.global(qos: .userInteractive).async {
            if !viewModel.accounts.isEmpty {
                API.OpenAPIs.fetchPlayerDatas(accounts[selectedAccount].config.uid ?? "0") { result in
                    switch result {
                    case .success(let data):
                        playerDetailDatas = data
                    case .failure(_):
                        break
                    }
                }
            }
        }
    }
}

private enum SheetTypes: Identifiable {
    var id: Int {
        hashValue
    }

    case spiralAbyss
    case characters
}
