//
//  AbyssDataCollectionView.swift
//  GenshinPizzaHepler
//
//  Created by 戴藏龙 on 2022/10/16.
//

import SwiftUI

class AbyssDataCollectionViewModel: ObservableObject {
    @Published var showingType: ShowingData {
        didSet {
            getData()
        }
    }
    @Published var showingSheetType: ShowingData?

    enum ShowingData: String, CaseIterable, Identifiable {
        case abyssAvatarsUtilization = "角色深渊使用率"
        case fullStarHoldingRate = "满星玩家持有率"
        case holdingRate = "持有率"

        var id: String { self.rawValue }
    }

    // MARK: - 所有用户持有率
    @Published var avatarHoldingResult: AvatarHoldingReceiveDataFetchModelResult?
    @Published var holdingParam: AvatarHoldingAPIParameters = .init()
    private func getAvatarHoldingResult() {
        API.PSAServer.fetchHoldingRateData(queryStartDate: holdingParam.date, server: holdingParam.server) { result in
            self.avatarHoldingResult = result
        }
    }

    // MARK: - 满星用户持有率
    @Published var fullStaAvatarHoldingResult: AvatarHoldingReceiveDataFetchModelResult?
    @Published var fullStarHoldingParam: FullStarAPIParameters = .init()
    private func getFullStarHoldingResult() {
        API.PSAServer.fetchFullStarHoldingRateData(season: fullStarHoldingParam.season, server: fullStarHoldingParam.server) { result in
            self.fullStaAvatarHoldingResult = result
        }
    }

    // MARK: - 深渊使用率
    @Published var utilizationDataFetchModelResult: UtilizationDataFetchModelResult?
    @Published var utilizationParams: UtilizationAPIParameters = .init()
    private func getUtilizationResult() {
        API.PSAServer.fetchAbyssUtilizationData(season: utilizationParams.season, server: utilizationParams.server, floor: utilizationParams.floor) { result in
            self.utilizationDataFetchModelResult = result
        }
    }

    init() {
        showingType = .abyssAvatarsUtilization
        getData()
    }

    var paramsDescription: String {
        switch showingType {
        case .fullStarHoldingRate:
            return fullStarHoldingParam.describe()
        case .holdingRate:
            return holdingParam.describe()
        case .abyssAvatarsUtilization:
            return utilizationParams.describe()
        }
    }

    func getData() {
        switch showingType {
        case .abyssAvatarsUtilization:
            getUtilizationResult()
        case .holdingRate:
            getAvatarHoldingResult()
        case .fullStarHoldingRate:
            getFullStarHoldingResult()
        }
    }
}

struct AbyssDataCollectionView: View {
    @StateObject var abyssDataCollectionViewModel: AbyssDataCollectionViewModel = .init()

    var body: some View {
        if #available(iOS 16.0, *) {
            VStack {
                switch abyssDataCollectionViewModel.showingType {
                case .abyssAvatarsUtilization, .holdingRate, .fullStarHoldingRate:
                    ShowAvatarPercentageView().environmentObject(abyssDataCollectionViewModel)
                }
            }
            .sheet(item: $abyssDataCollectionViewModel.showingSheetType, content: { type in
                NavigationView {
                    switch type {
                    case .holdingRate:
                        AvatarHoldingParamsSettingSheet(params: $abyssDataCollectionViewModel.holdingParam)
                            .dismissableSheet(sheet: $abyssDataCollectionViewModel.showingSheetType) {
                                abyssDataCollectionViewModel.getData()
                            }
                    case .fullStarHoldingRate:
                        FullStarAvatarHoldingParamsSettingSheet(params: $abyssDataCollectionViewModel.fullStarHoldingParam)
                            .dismissableSheet(sheet: $abyssDataCollectionViewModel.showingSheetType) {
                                abyssDataCollectionViewModel.getData()
                            }
                    case .abyssAvatarsUtilization:
                        UtilizationParasSettingSheet(params: $abyssDataCollectionViewModel.utilizationParams)
                            .dismissableSheet(sheet: $abyssDataCollectionViewModel.showingSheetType) {
                                abyssDataCollectionViewModel.getData()
                            }
                    }
                }
            })
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Menu {
                        ForEach(AbyssDataCollectionViewModel.ShowingData.allCases, id: \.rawValue) { choice in
                            Button(choice.rawValue.localized) {
                                withAnimation {
                                    abyssDataCollectionViewModel.showingType = choice
                                }
                            }
                        }
                    } label: {
                        HStack {
                            Image(systemName: "arrow.left.arrow.right.circle")
                            Text(abyssDataCollectionViewModel.showingType.rawValue.localized)
                        }
                    }
                }
                ToolbarItem (placement: .navigationBarTrailing) {
                    Button {
                        abyssDataCollectionViewModel.showingSheetType = abyssDataCollectionViewModel.showingType
                    } label: {
                        Image(systemName: "slider.vertical.3")
                    }
                }
                ToolbarItemGroup(placement: .bottomBar) {
                    Menu {

                    } label: {
                        Text("所有服务器")
                    }
                    Spacer()
                    Menu {

                    } label: {
                        Text("12层")
                    }
                    Spacer()
                    DatePicker("", selection: $abyssDataCollectionViewModel.holdingParam.date, displayedComponents: .date)
                }
            }
            .toolbar(.hidden, for: .tabBar)
        } else {
            // Fallback on earlier versions
        }
    }
}

struct ShowAvatarPercentageView: View {
    @EnvironmentObject var viewModel: ViewModel
    @EnvironmentObject var abyssDataCollectionViewModel: AbyssDataCollectionViewModel
    var result: FetchHomeModelResult<AvatarPercentageModel>? {
        switch abyssDataCollectionViewModel.showingType {
        case .fullStarHoldingRate:
            return abyssDataCollectionViewModel.fullStaAvatarHoldingResult
        case .holdingRate:
            return abyssDataCollectionViewModel.avatarHoldingResult
        case .abyssAvatarsUtilization:
            return abyssDataCollectionViewModel.utilizationDataFetchModelResult
        }
    }

    let percentageFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .percent
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 2
        return formatter
    }()

    var body: some View {
        List {
            if let result = result, let charLoc = viewModel.charLoc, let charMap = viewModel.charMap {
                switch result {
                case .success(let data):
                    let data = data.data
                    Section {
                        ForEach(data.avatars.sorted(by: {
                            switch abyssDataCollectionViewModel.showingType {
                            case .abyssAvatarsUtilization:
                                return ($0.percentage ?? 0) > ($1.percentage ?? 0)
                            case .holdingRate, .fullStarHoldingRate:
                                return $0.charId < $1.charId
                            }
                        }), id: \.charId) { avatar in
                            let char = charMap["\(avatar.charId)"]
                            HStack {
                                Label {
                                    Text(charLoc["\(char?.NameTextMapHash ?? 0)"] ?? "unknow")
                                } icon: {
                                    EnkaWebIcon(iconString: char?.iconString ?? "")
                                        .background(
                                            EnkaWebIcon(iconString: char?.namecardIconString ?? "")
                                                .scaledToFill()
                                                .offset(x: -30/3)
                                        )
                                    .frame(width: 30, height: 30)
                                    .clipShape(Circle())
                                }
                                Spacer()
                                Text(percentageFormatter.string(from: (avatar.percentage ?? 0.0) as NSNumber)!)
                            }
                        }
                    } header: {
                        let dateString: String = {
                            let formatter = DateFormatter()
                            formatter.dateStyle = .medium
                            formatter.timeStyle = .medium
                            return formatter.string(from: Date())
                        }()
                        Text("共统计\(data.totalUsers)用户。\(abyssDataCollectionViewModel.paramsDescription)生成于\(dateString)。")
                    }
                case .failure(let error):
                    Text(error.localizedDescription)
                }
            } else {
                ProgressView()
            }
        }
    }
}

struct AvatarHoldingParamsSettingSheet: View {
    @Binding var params: AvatarHoldingAPIParameters
    var queryAllServer: Binding<Bool> {
        .init {
            switch params.serverChoice {
            case .all:
                return true
            case .server(_):
                return false
            }
        } set: { newValue in
            if newValue {
                params.serverChoice = .all
            } else {
                params.serverChoice = .server(.china)
            }
        }
    }
    var queryServer: Binding<Server> {
        .init {
            params.server ?? .china
        } set: { server in
            params.serverChoice = .server(server)
        }
    }

    var body: some View {
        List {
            Section {
                DatePicker("查询开始日", selection: $params.date, displayedComponents: .date)
            } footer: {
                let dateString: String = {
                    let formatter = DateFormatter()
                    formatter.dateStyle = .medium
                    formatter.timeStyle = .none
                    return formatter.string(from: params.date)
                }()
                Text("仅包含\(dateString)后提交数据的玩家")
            }

            Toggle("查询所有服务器", isOn: queryAllServer)
            if !queryAllServer.wrappedValue {
                Picker("服务器", selection: queryServer) {
                    ForEach(Server.allCases, id: \.rawValue) { server in
                        Text(server.rawValue).tag(server)
                    }
                }
            }
        }
    }
}

struct AvatarHoldingAPIParameters {
    var date: Date = Calendar.current.date(byAdding: .day, value: -30, to: Date())!
    var server: Server? {
        switch serverChoice {
        case .all:
            return nil
        case .server(let server):
            return server
        }
    }
    var serverChoice: ServerChoice = .all

    func describe() -> String {
        let dateString: String = {
            let formatter = DateFormatter()
            formatter.dateStyle = .medium
            formatter.timeStyle = .none
            return formatter.string(from: date)
        }()
        return "数据包含\(dateString)后提交数据的玩家；服务器：\(serverChoice.describe())。"
    }
}

struct FullStarAvatarHoldingParamsSettingSheet: View {
    @Binding var params: FullStarAPIParameters
    var queryAllServer: Binding<Bool> {
        .init {
            switch params.serverChoice {
            case .all:
                return true
            case .server(_):
                return false
            }
        } set: { newValue in
            if newValue {
                params.serverChoice = .all
            } else {
                params.serverChoice = .server(.china)
            }
        }
    }
    var queryServer: Binding<Server> {
        .init {
            params.server ?? .china
        } set: { server in
            params.serverChoice = .server(server)
        }
    }
    var queryDate: Binding<Date> {
        .init {
            params.date
        } set: { newDate in
            params.date = newDate
        }
    }

    var body: some View {
        List {
            Section {
                DatePicker("查询日期", selection: queryDate, displayedComponents: .date)
            } footer: {
                Text("对应深渊期数：\(params.season.describe())")
            }

            Toggle("查询所有服务器", isOn: queryAllServer)
            if !queryAllServer.wrappedValue {
                Picker("服务器", selection: queryServer) {
                    ForEach(Server.allCases, id: \.rawValue) { server in
                        Text(server.rawValue).tag(server)
                    }
                }
            }
        }
    }
}

struct FullStarAPIParameters {
    var date: Date = Date()
    var season: AbyssSeason {
        .from(date)
    }
    var server: Server? {
        switch serverChoice {
        case .all:
            return nil
        case .server(let server):
            return server
        }
    }
    var serverChoice: ServerChoice = .all

    func describe() -> String {
        "深渊期数：\(season.describe())；服务器：\(serverChoice.describe())。"
    }
}

struct UtilizationParasSettingSheet: View {
    @Binding var params: UtilizationAPIParameters
    var queryAllServer: Binding<Bool> {
        .init {
            switch params.serverChoice {
            case .all:
                return true
            case .server(_):
                return false
            }
        } set: { newValue in
            if newValue {
                params.serverChoice = .all
            } else {
                params.serverChoice = .server(.china)
            }
        }
    }
    var queryServer: Binding<Server> {
        .init {
            params.server ?? .china
        } set: { server in
            params.serverChoice = .server(server)
        }
    }
    var queryDate: Binding<Date> {
        .init {
            params.date
        } set: { newDate in
            params.date = newDate
        }
    }

    var body: some View {
        List {
            Section {
                DatePicker("查询日期", selection: queryDate, displayedComponents: .date)
            } footer: {
                Text("对应深渊期数：\(params.season.describe())")
            }

            Toggle("查询所有服务器", isOn: queryAllServer)
            if !queryAllServer.wrappedValue {
                Picker("服务器", selection: queryServer) {
                    ForEach(Server.allCases, id: \.rawValue) { server in
                        Text(server.rawValue).tag(server)
                    }
                }
            }
            Section {
                Picker("深渊层数", selection: $params.floor) {
                    ForEach(9...12, id: \.self) { number in
                        Text("\(number)").tag(number)
                    }
                }
            }
        }
    }
}

struct UtilizationAPIParameters {
    var date: Date = Date()
    var season: AbyssSeason { .from(date) }
    var server: Server? {
        switch serverChoice {
        case .all:
            return nil
        case .server(let server):
            return server
        }
    }
    var serverChoice: ServerChoice = .all

    var floor: Int = 12

    func describe() -> String {
        "仅包含满星玩家。深渊期数：\(season.describe())；服务器：\(serverChoice.describe())；层数：\(floor)层。"
    }
}



typealias AbyssSeason = Int
extension AbyssSeason {
    static func from(_ date: Date) -> Self {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyyMM"
        let yearMonth = Int(dateFormatter.string(from: date))! * 10
        if Calendar.current.component(.day, from: date) > 15 {
            return yearMonth + 1
        } else {
            return yearMonth
        }
    }

    static func now() -> Self {
        from(Date())
    }

    var startDateOfSeason: Date {
        let seasonString = String(self)
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMM"
        let yearMonth = formatter.date(from: String(seasonString.prefix(6)))!
        let year = Calendar.current.component(.year, from: yearMonth)
        let month = Calendar.current.component(.month, from: yearMonth)
        let day = {
            if String(seasonString.suffix(1)) == "0" {
                return 1
            } else {
                return 16
            }
        }()
        return Calendar.current.date(from: DateComponents(year: year, month: month, day: day))!
    }

    func describe() -> String {
        let seasonString = String(self)
//        let formatter = DateFormatter()
//        formatter.dateFormat = "yyyyMM"
//        let yearMonth = formatter.date(from: String(seasonString.prefix(6)))!
//        let year = Calendar.current.component(.year, from: yearMonth)
//        let month = Calendar.current.component(.month, from: yearMonth)
        let half = {
            if String(seasonString.suffix(1)) == "0" {
                return "上半月".localized
            } else {
                return "下半月".localized
            }
        }()
        return String(seasonString.prefix(6)) + half
    }
}

enum ServerChoice {
    case all
    case server(Server)

    func describe() -> String {
        switch self {
        case .all:
            return "所有服务器".localized
        case .server(let server):
            return server.rawValue
        }
    }
}

