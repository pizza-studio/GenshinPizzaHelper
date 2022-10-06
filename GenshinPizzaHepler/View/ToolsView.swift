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

    @State var thisAbyssData: SpiralAbyssDetail? = nil
    @State var lastAbyssData: SpiralAbyssDetail? = nil
    @State private var abyssDataViewSelection: AbyssDataType = .thisTerm

    var animation: Namespace.ID

    var body: some View {
        NavigationView {
            List {
                if let account = account {
                    if ((try? account.playerDetailResult?.get()) != nil) && (account.basicInfo != nil) {
                        successView()
                    } else if !account.fetchPlayerDetailComplete {
                        loadingView()
                    } else {
                        failureView()
                    }
                } else {
                    chooseAccountView()
                }
                Section {
                    VStack {
                        HStack {
                            Text("小工具")
                                .font(.footnote)
                            Spacer()
                        }
                    }
                    NavigationLink(destination: GenshinDictionary()) {
                        Text("原神中英日词典")
                    }
                    Text("原神计算器")
                    mapNavigationLink()
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
    func successView() -> some View {
        let playerDetail: PlayerDetail = try! account!.playerDetailResult!.get()
        let basicInfo: BasicInfos = account!.basicInfo!
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
                                            .scaledToFill()
                                            .offset(x: -75/3))
                                        .clipShape(Circle())
                                        .contentShape(Circle())
                                        .onTapGesture {
                                            simpleTaptic(type: .medium)
                                            withAnimation(.interactiveSpring(response: 0.25, dampingFraction: 1.0, blendDuration: 0)) {
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
                .onTapGesture {
                    simpleTaptic(type: .medium)
                    sheetType = .spiralAbyss
                }

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
    
    @ViewBuilder
    func characterSheetView() -> some View {
        let playerDetail = try! self.account!.playerDetailResult!.get()
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
        if let thisAbyssData = thisAbyssData, let lastAbyssData = lastAbyssData {
            NavigationView {
                VStack {
                    Picker("", selection: $abyssDataViewSelection) {
                        ForEach(AbyssDataType.allCases, id:\.self) { option in
                            Text(option.rawValue)
                        }
                    }
                    .pickerStyle(.segmented)
                    .padding()
                    switch abyssDataViewSelection {
                    case .thisTerm:
                        abyssDetailDataDisplayView(data: thisAbyssData)
                    case .lastTerm:
                        abyssDetailDataDisplayView(data: lastAbyssData)
                    }
                }
                .navigationTitle("深境螺旋详情")
                .navigationBarTitleDisplayMode(.inline)
            }
        } else {
            ProgressView()
                .onAppear {
                    // scheduleType = 1: 本期深渊 / = 2: 上期深渊
                    API.Features.fetchSpiralAbyssInfos(region: account!.config.server.region, serverID: account!.config.server.id, uid: account!.config.uid!, cookie: account!.config.cookie!, scheduleType: "1") { result in
                        switch result {
                        case .success(let resultData):
                            thisAbyssData = resultData
                        case .failure(_):
                            print("Fail")
                        }
                    }
                    API.Features.fetchSpiralAbyssInfos(region: account!.config.server.region, serverID: account!.config.server.id, uid: account!.config.uid!, cookie: account!.config.cookie!, scheduleType: "2") { result in
                        switch result {
                        case .success(let resultData):
                            lastAbyssData = resultData
                        case .failure(_):
                            print("Fail")
                        }
                    }
                }
        }
    }

    @ViewBuilder
    func abyssDetailDataDisplayView(data: SpiralAbyssDetail) -> some View {
        List {
            // 总体战斗结果概览
            Section {
                InfoPreviewer(title: "最深抵达", content: data.maxFloor)
                InfoPreviewer(title: "获得渊星", content: "\(data.totalStar)")
                InfoPreviewer(title: "战斗次数", content: "\(data.totalBattleTimes)")
                InfoPreviewer(title: "获胜次数", content: "\(data.totalWinTimes)")
            } header: {
                Text("战斗概览")
                    .font(.headline)
            }

            // 战斗数据榜
            Section {
                HStack {
                    Text("最强一击")
                    Spacer()
                    Text("\(data.damageRank.first?.value ?? -1)")
                    WebImage(urlStr: data.damageRank.first?.avatarIcon ?? "")
                        .frame(width: 35, height: 35)
                        .offset(x: -7, y: -7)
                        .scaledToFit()
                }
                HStack {
                    Text("最多击破数")
                    Spacer()
                    Text("\(data.defeatRank.first?.value ?? -1)")
                    WebImage(urlStr: data.defeatRank.first?.avatarIcon ?? "")
                        .frame(width: 35, height: 35)
                        .offset(x: -7, y: -7)
                        .scaledToFit()
                }
                HStack {
                    Text("承受最多伤害")
                    Spacer()
                    Text("\(data.takeDamageRank.first?.value ?? -1)")
                    WebImage(urlStr: data.takeDamageRank.first?.avatarIcon ?? "")
                        .frame(width: 35, height: 35)
                        .offset(x: -7, y: -7)
                        .scaledToFit()
                }
                HStack {
                    Text("元素战技释放数")
                    Spacer()
                    Text("\(data.normalSkillRank.first?.value ?? -1)")
                    WebImage(urlStr: data.normalSkillRank.first?.avatarIcon ?? "")
                        .frame(width: 35, height: 35)
                        .offset(x: -7, y: -7)
                        .scaledToFit()
                }
                HStack {
                    Text("元素爆发次数")
                    Spacer()
                    Text("\(data.energySkillRank.first?.value ?? -1)")
                    WebImage(urlStr: data.energySkillRank.first?.avatarIcon ?? "")
                        .frame(width: 35, height: 35)
                        .offset(x: -7, y: -7)
                        .scaledToFit()
                }
            } header: {
                Text("战斗数据榜")
                    .font(.headline)
            }

            ForEach(data.floors, id:\.index) { floorData in
                Section {
                    InfoPreviewer(title: "战斗结果", content: "\(floorData.star)/\(floorData.maxStar)")
                    ForEach(floorData.levels, id: \.index) { levelData in
                        VStack(alignment: .leading, spacing: 0) {
                            HStack(spacing: 0) {
                                Text("第\(levelData.index)间")
                                    .font(.subheadline)
                                Spacer()
                                ForEach(0 ..< levelData.star) { _ in
                                    Image("star.abyss")
                                        .resizable()
                                        .frame(width: 30, height: 30)
                                }
                            }
                            ForEach(levelData.battles, id:\.index) { battleData in
                                HStack(alignment: .top, spacing: 0) {
                                    switch battleData.index {
                                    case 1:
                                        Text("上半")
                                            .font(.caption)
                                    case 2:
                                        Text("下半")
                                            .font(.caption)
                                    default:
                                        Text("Unknown")
                                            .font(.caption)
                                    }
                                    ForEach(battleData.avatars, id:\.id) { avatarData in
                                        VStack(spacing: 0) {
                                            WebImage(urlStr: avatarData.icon)
                                                .frame(height: 100)
                                                .scaledToFit()
                                            Text("Lv.\(avatarData.level)")
                                                .font(.footnote)
                                        }
                                    }
                                }
                            }
                        }
                    }
                } header: {
                    Text("深境螺旋第\(floorData.index)层")
                        .font(.headline)
                }
            }
        }
        .listStyle(.sidebar)
    }

    @ViewBuilder
    func mapNavigationLink() -> some View {
        let mapURL: String = {
            if let account = account {
                switch account.config.server.region {
                case .cn:
                    return "https://webstatic.mihoyo.com/ys/app/interactive-map/index.html"
                case .global:
                    return "https://act.hoyolab.com/ys/app/interactive-map/index.html"
                }
            } else {
                if Locale.current.identifier == "zh_CN" {
                    return "https://webstatic.mihoyo.com/ys/app/interactive-map/index.html"
                } else {
                    return "https://act.hoyolab.com/ys/app/interactive-map/index.html"
                }
            }
        }()
        NavigationLink(destination: WebBroswerView(url: mapURL).navigationTitle("提瓦特大地图").navigationBarTitleDisplayMode(.inline)) {
            Text("提瓦特大地图")
        }
    }

    @ViewBuilder
    func selectAccountManuButton() -> some View {
        if accounts.count > 1 {
            Menu {
                ForEach(accounts, id:\.config.id) { account in
                    Button(account.config.name ?? "Name Error") {
                        showingAccountUUIDString = account.config.uuid!.uuidString
                        thisAbyssData = nil
                        lastAbyssData = nil
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

    @ViewBuilder
    func failureView() -> some View {
        ZStack {
            HStack {
                Text(account?.config.name ?? "").foregroundColor(.secondary)
                Spacer()
                selectAccountManuButton()
            }
            HStack {
                Spacer()
                Image(systemName: "exclamationmark.arrow.triangle.2.circlepath")
                    .foregroundColor(.red)
                    .onTapGesture {
                        viewModel.refreshPlayerDetail()
                    }
                Spacer()
            }
        }
    }

    @ViewBuilder
    func loadingView() -> some View {
        ZStack {
            HStack {
                Text(account?.config.name ?? "").foregroundColor(.secondary)
                Spacer()
                selectAccountManuButton()
            }
            HStack {
                Spacer()
                ProgressView()
                Spacer()
            }
        }
    }

    @ViewBuilder
    func chooseAccountView() -> some View {
        Menu {
            ForEach(accounts, id:\.config.id) { account in
                Button(account.config.name ?? "Name Error") {
                    showingAccountUUIDString = account.config.uuid!.uuidString
                }
            }
        } label: {
            Label("请先选择账号", systemImage: "arrow.left.arrow.right.circle")
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

private enum AbyssDataType: String, CaseIterable {
    case thisTerm = "本期深渊"
    case lastTerm = "上期深渊"
}
