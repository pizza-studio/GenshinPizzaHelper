//
//  ToolsView.swift
//  GenshinPizzaHepler
//
//  Created by Bill Haku on 2022/9/17.
//

import SwiftUI
import SwiftPieChart

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
    @State var ledgerData: LedgerData? = nil

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
                    Link(destination: isInstallation(urlString: "aliceworkshop://") ? URL(string: "aliceworkshop://app/import?uid=\(account?.config.uid ?? "")")! : URL(string: "https://apps.apple.com/us/app/id1620751192")!) {
                        VStack(alignment: .leading) {
                            Text("原神计算器")
                                .foregroundColor(.primary)
                            Text(isInstallation(urlString: "aliceworkshop://") ? "由爱丽丝工坊提供" : "由爱丽丝工坊提供（未安装）")
                                .font(.footnote)
                                .foregroundColor(.secondary)
                        }
                    }
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
        .onAppear {
            if self.ledgerData == nil {
                DispatchQueue.global().async {
                    API.Features.fetchLedgerInfos(month: 0, uid: account!.config.uid!, serverID: account!.config.server.id, region: account!.config.server.region, cookie: account!.config.cookie!) { result in
                        switch result {
                        case .success(let result):
                            self.ledgerData = result
                        case .failure(_):
                            print("fetch ledger data fail")
                        }
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
                                    Image("star.abyss")
                                        .resizable()
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
                        if ledgerData != nil {
                            simpleTaptic(type: .medium)
                            sheetType = .spiralAbyss
                        }
                    }

                    VStack {
                        VStack {
                            HStack {
                                Text("今日入账")
                                    .font(.footnote)
                                Spacer()
                            }
                            .padding(.top, 5)
                            Divider()
                        }
                        if let ledgerData = ledgerData {
                            VStack {
                                Text("\(ledgerData.dayData.currentPrimogems)")
                                    .font(.largeTitle)
                                Text("\(ledgerData.dayData.currentMora)")
                            }
                            .frame(height: 120)
                            .padding(.bottom, 10)
                        } else {
                            ProgressView()
                                .frame(height: 120)
                                .padding(.bottom, 10)
                        }
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
                Section(header: Text("今日入账")) {
                    InfoPreviewer(title: "原石收入", content: "\(ledgerData?.dayData.currentPrimogems ?? -1)")
                    InfoPreviewer(title: "摩拉收入", content: "\(ledgerData?.dayData.currentMora ?? -1)")
                    if let lastPrimogem = ledgerData?.dayData.lastPrimogems {
                        InfoPreviewer(title: "昨日原石收入", content: "\(lastPrimogem)")
                    }
                    if let lastMora = ledgerData?.dayData.lastMora {
                        InfoPreviewer(title: "昨日摩拉收入", content: "\(lastMora)")
                    }
                }

                Section {
                    InfoPreviewer(title: "原石收入", content: "\(ledgerData?.monthData.currentPrimogems ?? -1)(\(ledgerData?.monthData.primogemsRate ?? ledgerData?.monthData.primogemRate ?? -1))")
                    InfoPreviewer(title: "摩拉收入", content: "\(ledgerData?.monthData.currentMora ?? -1)(\(ledgerData?.monthData.lastMora ?? -1))")
                } header: {
                    Text("本月账单")
                } footer: {
                    if let ledgerData = ledgerData {
                        PieChartView(
                            values: ledgerData.monthData.groupBy.map { Double($0.num) },
                            names: ledgerData.monthData.groupBy.map { $0.action },
                            formatter: { value in String(format: "%.0f", value)},
                            colors: [.blue, .green, .orange, .yellow, .purple, .gray, .brown, .cyan],
                            backgroundColor: Color(UIColor.systemGroupedBackground),
                            innerRadiusFraction: 0.6
                        )
                        .padding(.vertical)
                        .frame(height: 600)
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
        let isHoYoLAB: Bool = {
            if let account = account {
                switch account.config.server.region {
                case .cn:
                    return false
                case .global:
                    return true
                }
            } else {
                if Locale.current.identifier == "zh_CN" {
                    return false
                } else {
                    return true
                }
            }
        }()
        NavigationLink(destination:
                        TeyvatMapWebView(isHoYoLAB: isHoYoLAB)
            .navigationTitle("提瓦特大地图")
            .navigationBarTitleDisplayMode(.inline)
        ) {
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

    func isInstallation(urlString:String?) -> Bool {
            let url = URL(string: urlString!)
            if url == nil {
                return false
            }
            if UIApplication.shared.canOpenURL(url!) {
                return true
            }
            return false
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
