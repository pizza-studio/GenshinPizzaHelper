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
    @AppStorage("toolViewShowingAccountUUIDString") var showingAccountUUIDString: String?
    var account: Account? {
        accounts.first { account in
            account.config.uuid!.uuidString == showingAccountUUIDString
        }
    }

    @State private var sheetType: SheetTypes? = nil

    var body: some View {
        NavigationView {
            List {
                if let account = account, let basicInfo = account.basicInfo, let playerDetail = account.playerDetail {
                    Section {
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
                                ForEach(basicInfo.avatars) { avatar in
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
                                Text("\(basicInfo.stats.spiralAbyss)")
                                    .font(.largeTitle)
                                    .frame(height: 120)
                                    .padding(.bottom, 10)
                            }
                            .padding(.horizontal)
                            .background(RoundedRectangle(cornerRadius: 10).fill(Color(UIColor.secondarySystemGroupedBackground)))

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
                                Text("Lv.\(playerDetail.basicInfo.level)")
                                    .font(.largeTitle)
                                    .frame(height: 120)
                                    .padding(.bottom, 10)
                            }
                            .padding(.horizontal)
                            .background(RoundedRectangle(cornerRadius: 10).fill(Color(UIColor.secondarySystemGroupedBackground)))
                            .onTapGesture {
                                simpleTaptic(type: .medium)
                                sheetType = .characters
                            }
                        }
                    }
                    .listRowInsets(.init(top: 0, leading: 0, bottom: 0, trailing: 0))
                    .listRowBackground(Color.white.opacity(0))
                }

                
                Section {
                    VStack {
                        HStack {
                            Text("小工具")
                                .font(.footnote)
                            Spacer()
                            Button(action: {

                            }) {
                                Text("自定义")
                                    .foregroundColor(.blue)
                                    .font(.footnote)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    Text("原神中日英词典")
                    Text("原神计算器")
                    Text("提瓦特大地图")
                }

            }
            .navigationTitle("原神小工具")
            .navigationBarTitleDisplayMode(.inline)
            .onChange(of: showingAccountUUIDString, perform: { newValue in
                print(newValue)
            })
            .onAppear {
                if !accounts.isEmpty && showingAccountUUIDString == nil {
                    showingAccountUUIDString = accounts.first!.config.uuid!.uuidString
                }
            }
            .toolbar {
                Menu {
                    ForEach(accounts, id:\.config.id) { account in
                        Button(account.config.name ?? "Name Error") {
                            showingAccountUUIDString = account.config.uuid!.uuidString
                        }
                    }
                } label: {
                    Label("选择帐号", systemImage: "arrow.left.arrow.right.circle")
                }
            }
            .sheet(item: $sheetType) { type in
                switch type {
                case .characters:
                    characterSheetView()
                case .spiralAbyss:
                    spiralAbyssSheetView()
                }
            }
        }
    }
    
    @ViewBuilder
    func characterSheetView() -> some View {
        let playerDetail = self.account!.playerDetail!
        let account = self.account!
        let basicInfo = self.account!.basicInfo!
        NavigationView {
            List {
                Section(header: Text("帐号基本信息"), footer: Text(playerDetail.basicInfo.signature).font(.footnote)) {
                    InfoPreviewer(title: "世界等级", content: "\(playerDetail.basicInfo.worldLevel)")
                    InfoPreviewer(title: "成就数量", content: "\(basicInfo.stats.achievementNumber)")
                }
                Section {
                    if !playerDetail.avatars.isEmpty {
                        TabView {
                            ForEach(playerDetail.avatars, id:\.name) { avatar in
                                CharacterDetailDatasView(avatar: avatar)
                            }
                        }
                        .tabViewStyle(.page)
                        .indexViewStyle(.page(backgroundDisplayMode: .always))
                        .frame(height: 500)
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                #if os(macOS)
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("返回") {
                        sheetType = nil
                    }
                }
                #endif
                ToolbarItem(placement: .principal) {
                    Label {
                        Text(playerDetail.basicInfo.nickname)
                            .font(.headline)
                    } icon: {
                        WebImage(urlStr: "http://ophelper.top/resource/\(playerDetail.basicInfo.profilePictureAvatarIconString).png")
                            .clipShape(Circle())
                    }
                    .labelStyle(.titleAndIcon)
                }
            }
        }
    }

    @ViewBuilder
    func spiralAbyssSheetView() -> some View {
        Text("")
    }
}

private enum SheetTypes: Identifiable {
    var id: Int {
        hashValue
    }

    case spiralAbyss
    case characters
}
