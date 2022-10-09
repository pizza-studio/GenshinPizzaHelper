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

    var thisAbyssData: SpiralAbyssDetail? { account?.spiralAbyssDetail?.this }
    var lastAbyssData: SpiralAbyssDetail? { account?.spiralAbyssDetail?.last }
    @State private var abyssDataViewSelection: AbyssDataType = .thisTerm

    var animation: Namespace.ID

    var body: some View {
        NavigationView {
            List {
                if let account = account {
                    if let result = account.playerDetailResult {
                        switch result {
                        case .success(_):
                            successView()
                        case .failure(let error):
                            failureView(error: error)
                        }
                    } else if !account.fetchPlayerDetailComplete {
                        loadingView()
                    }
                } else {
                    chooseAccountView()
                }
                abyssAndPrimogemNavigator()
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
                    mapNavigationLink()
                    #if DEBUG
                    Text("原神计算器")
                    #endif
                }
            }
            .refreshable {
                if let account = account {
                    viewModel.refreshPlayerDetail(for: account)
                }
                viewModel.refreshAbyssDetail()
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
            .onChange(of: account) { newAccount in
                viewModel.refreshPlayerDetail(for: newAccount!)
            }
        }
        .navigationViewStyle(.stack)
    }

    @ViewBuilder
    func successView() -> some View {
        let playerDetail: PlayerDetail = try! account!.playerDetailResult!.get()
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


    }

    @ViewBuilder
    func abyssAndPrimogemNavigator() -> some View {
        if let basicInfo: BasicInfos = account?.basicInfo {
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
                        VStack(spacing: 0) {
                            Text("\(basicInfo.stats.spiralAbyss)")
                                .font(.largeTitle)
                            if let thisAbyssData = thisAbyssData {
                                HStack(spacing: 0) {
                                    Text("\(thisAbyssData.totalStar)")
                                    AbyssStarIcon()
                                        .frame(width: 30, height: 30)
                                }
                            } else {
                                ProgressView()
                                    .onTapGesture {
                                        viewModel.refreshAbyssDetail()
                                    }
                            }
                        }
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
                                Text("原石View占位")
                                    .font(.footnote)
                                Spacer()
                            }
                            .padding(.top, 5)
                            Divider()
                        }
                        Text("原石")
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
                        HomeSourceWebIcon(iconString: playerDetail.basicInfo.profilePictureAvatarIconString)
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
                        AbyssDetailDataDisplayView(data: thisAbyssData, charMap: viewModel.charMap!)
                    case .lastTerm:
                        AbyssDetailDataDisplayView(data: lastAbyssData, charMap: viewModel.charMap!)
                    }
                }
                .navigationTitle("深境螺旋详情")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("完成") {
                            sheetType = nil
                        }
                    }
                }
            }
        } else {
            ProgressView()
        }
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
    func failureView(error: PlayerDetail.PlayerDetailError) -> some View {
        Section {
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
                            if let account = account {
                                viewModel.refreshPlayerDetail(for: account)
                            }
                        }
                    Spacer()
                }
            }
        } footer: {
            switch error {
            case .failToGetLocalizedDictionary:
                Text("fail to get localized dictionary")
            case .failToGetCharacterDictionary:
                Text("fail to get character dictionary")
            case .failToGetCharacterData(let message):
                Text(message)
            case .refreshTooFast(let dateWhenRefreshable):
                if dateWhenRefreshable.timeIntervalSinceReferenceDate - Date().timeIntervalSinceReferenceDate > 0 {
                    let second = Int(dateWhenRefreshable.timeIntervalSinceReferenceDate - Date().timeIntervalSinceReferenceDate)
                    Text("请稍等\(second)秒再刷新")
                } else {
                    Text("请下滑刷新")
                }
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


