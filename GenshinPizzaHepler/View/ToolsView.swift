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

    var showingCharacterDetail: Bool { viewModel.showCharacterDetailOfAccount != nil }

    @State private var sheetType: SheetTypes? = nil

    var body: some View {
        NavigationView {
            List {
                if account == nil {
                    Menu {
                        ForEach(accounts, id:\.config.id) { account in
                            Button(account.config.name ?? "Name Error") {
                                showingAccountUUIDString = account.config.uuid!.uuidString
                            }
                        }
                    } label: {
                        Label("请先选择账号", systemImage: "arrow.left.arrow.right.circle")
                    }
                } else {
                    if let basicInfo = account?.basicInfo, let playerDetail = account?.playerDetail {
                        Section {
                            VStack {
                                HStack(spacing: 10) {
                                    HomeSourceWebIcon(iconString: playerDetail.basicInfo.profilePictureAvatarIconString)
                                        .clipShape(Circle())
                                    VStack(alignment: .leading) {
                                        Text(playerDetail.basicInfo.nickname)
                                            .font(.title3)
                                            .bold()
                                            .padding(.top, 5)
                                            .lineLimit(1)
                                        Text(playerDetail.basicInfo.signature)
                                            .foregroundColor(.secondary)
                                            .font(.footnote)
                                            .lineLimit(2)
                                    }
                                    Spacer()
                                    selectAccountManuButton()
                                }
                            }
                            .frame(height: 60)
                        } footer: {
                            Text("UID: \(account!.config.uid!)")
                        }

                        Section {
                            VStack {
                                Text("角色展示柜")
                                    .font(.footnote)
                                    .foregroundColor(.secondary)
                                Divider()
                                if playerDetail.avatars.isEmpty {
                                    Text("账号未展示角色")
                                        .foregroundColor(.secondary)
                                } else {
                                    ScrollView(.horizontal) {
                                        HStack {
                                            ForEach(playerDetail.avatars, id: \.name) { avatar in
                                                VStack {
                                                    EnkaWebIcon(iconString: avatar.iconString)
                                                        .frame(width: 75, height: 75)
                                                        .background(EnkaWebIcon(iconString: avatar.namecardIconString)
                                                            .scaledToFill())
                                                        .clipShape(Circle())
                                                        .contentShape(Circle())
                                                        .onTapGesture {
                                                            withAnimation {
                                                                viewModel.showingCharacterName = avatar.name
                                                                viewModel.showCharacterDetailOfAccount = account!
                                                            }
                                                        }
                                                }
                                            }
                                        }
                                        .padding(.vertical)
                                    }
                                }
                            }
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
                    } else {
                        HStack {
                            Text(account?.config.name ?? "").foregroundColor(.secondary)
                            Spacer()
                            ProgressView()
                            Spacer()
                            selectAccountManuButton()
                        }
                    }
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
            .refreshable {
                viewModel.refreshPlayerDetail()
            }
            .onAppear {
                if !accounts.isEmpty && showingAccountUUIDString == nil {
                    showingAccountUUIDString = accounts.first!.config.uuid!.uuidString
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
        let basicInfo = self.account!.basicInfo!
        NavigationView {
            List {
                Section(header: Text("帐号基本信息"), footer: Text(playerDetail.basicInfo.signature).font(.footnote)) {
                    InfoPreviewer(title: "世界等级", content: "\(playerDetail.basicInfo.worldLevel)")
                    InfoPreviewer(title: "成就数量", content: "\(basicInfo.stats.achievementNumber)")
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

    @ViewBuilder
    func selectAccountManuButton() -> some View {
        if accounts.count > 1 {
            Menu {
                ForEach(accounts, id:\.config.id) { account in
                    Button(account.config.name ?? "Name Error") {
                        showingAccountUUIDString = account.config.uuid!.uuidString
                    }
                }
            } label: {
                Image(systemName: "arrow.left.arrow.right.circle")
                    .font(.title2)
            }
        } else {
            EmptyView()
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
