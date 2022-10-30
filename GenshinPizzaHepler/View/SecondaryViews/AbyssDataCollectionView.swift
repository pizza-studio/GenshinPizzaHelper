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

    enum ShowingData: String, CaseIterable, Identifiable {
        case abyssAvatarsUtilization = "深渊角色使用率"
        case teamUtilization = "深渊队伍使用率"
        case fullStarHoldingRate = "满星玩家持有率"
        case holdingRate = "角色持有率"

        var id: String { self.rawValue }
    }

    // MARK: - 所有用户持有率
    @Published var avatarHoldingResult: AvatarHoldingReceiveDataFetchModelResult?
    @Published var holdingParam: AvatarHoldingAPIParameters = .init() {
        didSet { getAvatarHoldingResult() }
    }
    private func getAvatarHoldingResult() {
        API.PSAServer.fetchHoldingRateData(queryStartDate: holdingParam.date, server: holdingParam.server) { result in
            withAnimation {
                self.avatarHoldingResult = result
            }
        }
    }

    // MARK: - 满星用户持有率
    @Published var fullStaAvatarHoldingResult: AvatarHoldingReceiveDataFetchModelResult?
    @Published var fullStarHoldingParam: FullStarAPIParameters = .init() {
        didSet { getFullStarHoldingResult() }
    }
    private func getFullStarHoldingResult() {
        API.PSAServer.fetchFullStarHoldingRateData(season: fullStarHoldingParam.season, server: fullStarHoldingParam.server) { result in
            withAnimation {
                self.fullStaAvatarHoldingResult = result
            }
        }
    }

    // MARK: - 深渊使用率
    @Published var utilizationDataFetchModelResult: UtilizationDataFetchModelResult?
    @Published var utilizationParams: UtilizationAPIParameters = .init() {
        didSet { getUtilizationResult() }
    }
    private func getUtilizationResult() {
        API.PSAServer.fetchAbyssUtilizationData(season: utilizationParams.season, server: utilizationParams.server, floor: utilizationParams.floor) { result in
            withAnimation {
                self.utilizationDataFetchModelResult = result
            }
        }
    }

    // MARK: - 深渊队伍使用率
    @Published var teamUtilizationDataFetchModelResult: TeamUtilizationDataFetchModelResult?
    @Published var teamUtilizationParams: TeamUtilizationAPIParameters = .init() {
        didSet { getTeamUtilizationResult() }
    }
    private func getTeamUtilizationResult() {
        API.PSAServer.fetchTeamUtilizationData(season: teamUtilizationParams.season, server: teamUtilizationParams.server, floor: teamUtilizationParams.floor) { result in
            self.teamUtilizationDataFetchModelResult = result
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
        case .teamUtilization:
            return teamUtilizationParams.describe()
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
        case .teamUtilization:
            getTeamUtilizationResult()
        }
    }
}

struct AbyssDataCollectionView: View {
    @StateObject var abyssDataCollectionViewModel: AbyssDataCollectionViewModel = .init()

    var body: some View {
        VStack {
            switch abyssDataCollectionViewModel.showingType {
            case .abyssAvatarsUtilization, .holdingRate, .fullStarHoldingRate:
                ShowAvatarPercentageView().environmentObject(abyssDataCollectionViewModel)
            case .teamUtilization:
                ShowTeamPercentageView().environmentObject(abyssDataCollectionViewModel)
            }
        }
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
            ToolbarItemGroup(placement: .bottomBar) {
                switch abyssDataCollectionViewModel.showingType {
                case .holdingRate:
                    AvatarHoldingParamsSettingBar(params: $abyssDataCollectionViewModel.holdingParam)
                case .fullStarHoldingRate:
                    FullStarAvatarHoldingParamsSettingBar(params: $abyssDataCollectionViewModel.fullStarHoldingParam)
                case .abyssAvatarsUtilization:
                    UtilizationParasSettingBar(params: $abyssDataCollectionViewModel.utilizationParams)
                case .teamUtilization:
                    TeamUtilizationParasSettingBar(params: $abyssDataCollectionViewModel.teamUtilizationParams)
                }
            }
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
        default:
            return nil
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
                            case .abyssAvatarsUtilization, .teamUtilization:
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
                        Text("共统计\(data.totalUsers)用户\(abyssDataCollectionViewModel.paramsDescription)")
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

struct ShowTeamPercentageView: View {
    @EnvironmentObject var viewModel: ViewModel
    @EnvironmentObject var abyssDataCollectionViewModel: AbyssDataCollectionViewModel
    var result: TeamUtilizationDataFetchModelResult? {
        abyssDataCollectionViewModel.teamUtilizationDataFetchModelResult
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
            if let result = result, let charMap = viewModel.charMap {
                switch result {
                case .success(let data):
                    let data = data.data
                    let teams: [TeamUtilizationData.Team] = {
                        switch abyssDataCollectionViewModel.teamUtilizationParams.half {
                        case .all:
                            return data.teams
                        case .firstHalf:
                            return data.teamsFH
                        case .secondHalf:
                            return data.teamsSH
                        }
                    }()
                    Section {
                        ForEach(teams.sorted(by: { $0.percentage > $1.percentage }), id: \.team.hashValue) { team in
                            HStack {
                                Label {
                                    Text("")
                                } icon: {
                                    ForEach(team.team.sorted(by: <), id: \.self) { avatarId in
                                        let char = charMap["\(avatarId)"]
                                        EnkaWebIcon(iconString: char?.iconString ?? "")
                                            .background(
                                                EnkaWebIcon(iconString: char?.namecardIconString ?? "")
                                                    .scaledToFill()
                                                    .offset(x: -30/3)
                                            )
                                        .frame(width: 40, height: 40)
                                        .clipShape(Circle())
                                    }
                                }
                                Spacer()
                                Text(percentageFormatter.string(from: (team.percentage) as NSNumber)!)
                            }
                        }
                    } header: {
                        Text("共统计\(data.totalUsers)用户\(abyssDataCollectionViewModel.paramsDescription)")
                    }
                case .failure(let error):
                    Text(error.localizedDescription)
                }
            } else {
                ProgressView()
            }
        }.listStyle(.insetGrouped)
    }
}


struct AvatarHoldingParamsSettingBar: View {
    @Binding var params: AvatarHoldingAPIParameters

    var body: some View {
        Menu {
            Button("所有服务器") { params.serverChoice = .all }
            ForEach(Server.allCases, id: \.rawValue) { server in
                Button("\(server.rawValue)") { params.serverChoice = .server(server) }
            }
        } label: {
            Text(params.serverChoice.describe())
        }
        Spacer()
        DatePicker("", selection: $params.date, displayedComponents: [.date])
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
        return "·仅自\(dateString)后提交的数据"
    }
}

struct FullStarAvatarHoldingParamsSettingBar: View {
    @Binding var params: FullStarAPIParameters

    var body: some View {
        Menu {
            Button("所有服务器") { params.serverChoice = .all }
            ForEach(Server.allCases, id: \.rawValue) { server in
                Button("\(server.rawValue)") { params.serverChoice = .server(server) }
            }
        } label: {
            Text(params.serverChoice.describe())
        }
        Spacer()
        Menu {
            ForEach(AbyssSeason.choices(), id: \.hashValue) { season in
                Button("\(season.describe())") { params.season = season }
            }
        } label: {
            Text(params.season.describe())
        }
    }
}

struct FullStarAPIParameters {
    var season: AbyssSeason = .now()
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
        ""
    }
}

struct UtilizationParasSettingBar: View {
    @Binding var params: UtilizationAPIParameters

    var body: some View {
        Menu {
            Button("所有服务器") { params.serverChoice = .all }
            ForEach(Server.allCases, id: \.rawValue) { server in
                Button("\(server.rawValue)") { params.serverChoice = .server(server) }
            }
        } label: {
            Text(params.serverChoice.describe())
        }
        Spacer()
        Menu {
            ForEach((9...12).reversed(), id: \.self) { number in
                Button("\(number)层") {
                    params.floor = number
                }
            }
        } label: {
            Text("\(params.floor)层")
        }
        Spacer()
        Menu {
            ForEach(AbyssSeason.choices(), id: \.hashValue) { season in
                Button("\(season.describe())") { params.season = season }
            }
        } label: {
            Text(params.season.describe())
        }
    }
}

struct UtilizationAPIParameters {
    var season: AbyssSeason = .from(Date())
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
        "·仅包含满星玩家"
    }
}

struct TeamUtilizationParasSettingBar: View {
    @Binding var params: TeamUtilizationAPIParameters

    var body: some View {
        Menu {
            Button("所有服务器") { params.serverChoice = .all }
            ForEach(Server.allCases, id: \.rawValue) { server in
                Button("\(server.rawValue)") { params.serverChoice = .server(server) }
            }
        } label: {
            Text(params.serverChoice.describe())
        }
        Spacer()
        Menu {
            ForEach((9...12).reversed(), id: \.self) { number in
                Button("\(number)层") {
                    params.floor = number
                }
            }
        } label: {
            Text("\(params.floor)层")
        }
        Spacer()
        Menu {
            ForEach(AbyssSeason.choices(), id: \.hashValue) { season in
                Button("\(season.describe())") { params.season = season }
            }
        } label: {
            Text(params.season.describe())
        }
        Spacer()
        Menu {
            ForEach(TeamUtilizationAPIParameters.Half.allCases, id: \.rawValue) { half in
                Button("\(half.rawValue.localized)") {
                    withAnimation {
                        params.half = half
                    }
                }
            }
        } label: {
            Text(params.half.rawValue.localized)
        }
    }
}

struct TeamUtilizationAPIParameters {
    var season: AbyssSeason = .from(Date())
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
        "·仅包含满星玩家"
    }
    var half: Half = .all

    enum Half: String, CaseIterable {
        case all = "整层"
        case secondHalf = "下半"
        case firstHalf = "上半"
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
                return "上".localized
            } else {
                return "下".localized
            }
        }()
        return String(seasonString.prefix(6).prefix(4)) + " " + String(seasonString.prefix(6).suffix(2)) + "月" + half
    }

    static func choices(from date: Date = Date()) -> [AbyssSeason] {
        var choices = [Self]()
        var date = date
        // TODO: - 正式版修改此处为11月1日
        let startDate = Calendar.current.date(from: DateComponents(year: 2022, month: 10, day: 16))!
        // 以下仅判断本月
        if Calendar.current.dateComponents([.day], from: date).day! >= 16 {
            choices.append(date.yyyyMM()*10+1)
        }
        choices.append(date.yyyyMM()*10)
        date = Calendar.current.date(byAdding: .month, value: -1, to: date)!
        while date >= startDate {
            choices.append(date.yyyyMM()*10+1)
            choices.append(date.yyyyMM()*10)
            date = Calendar.current.date(byAdding: .month, value: -1, to: date)!
        }
        return choices
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

extension Date {
    func yyyyMM() -> Int {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMM"
        return Int(formatter.string(from: self))!
    }
}
