//
//  AbyssDataCollectionView.swift
//  GenshinPizzaHepler
//
//  Created by 戴藏龙 on 2022/10/16.
//

import SwiftUI

struct AbyssDataCollectionView: View {
    @State var showingDataType: ShowingData = .abyssAvatarsUtilization

    var body: some View {
        NavigationView {
            switch showingDataType {
            case .abyssAvatarsUtilization:
                ShowAvatarPercentageView(type: .abyssAvatarsUtilization)
            case .fullStarHoldingRate:
                ShowAvatarPercentageView(type: .fullStarHoldingRate)
            case .holdingRate:
                ShowAvatarPercentageView(type: .holdingRate)
            }
        }
        .toolbar {
            ToolbarItemGroup(placement: .principal) {
                Menu {
                    ForEach(ShowingData.allCases, id: \.rawValue) { choice in
                        Button(choice.rawValue.localized) {
                            withAnimation {
                                showingDataType = choice
                            }
                        }
                    }
                } label: {
                    HStack {
                        Image(systemName: "arrow.left.arrow.right.circle")
                        Text(showingDataType.rawValue.localized)
                    }
                }
            }
        }
    }

    enum ShowingData: String, CaseIterable {
        case abyssAvatarsUtilization = "角色深渊使用率"
        case fullStarHoldingRate = "满星持有率"
        case holdingRate = "持有率"
    }
}

struct ShowAvatarPercentageView: View {
    @EnvironmentObject var viewModel: ViewModel
    @State var result: FetchHomeModelResult<AvatarPercentageModel>?

    let percentageFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .percent
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 2
        return formatter
    }()

    let type: DataType

    var body: some View {
        List {
            if let result = result, let charLoc = viewModel.charLoc, let charMap = viewModel.charMap {
                switch result {
                case .success(let data):
                    let data = data.data
                    Section {
                        ForEach(data.avatars.sorted(by: {
                            $0.charId < $1.charId
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
                        Text("共统计\(data.totalUsers)用户")
                    }
                case .failure(let error):
                    Text(error.localizedDescription)
                }
            } else {
                ProgressView()
            }
        }
        .onAppear {
            withAnimation {
                switch type {
                case .holdingRate:
                    API.PSAServer.fetchHoldingRateData(queryStartDate: nil) { result in
                        self.result = result
                    }
                case .fullStarHoldingRate:
                    API.PSAServer.fetchFullStarHoldingRateData { result in
                        self.result = result
                    }
                case .abyssAvatarsUtilization:
                    API.PSAServer.fetchAbyssUtilizationData { result in
                        self.result = result
                    }
                }
            }
        }
    }
    enum DataType {
        case holdingRate
        case fullStarHoldingRate
        case abyssAvatarsUtilization
    }
}
