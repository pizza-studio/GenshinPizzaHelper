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
            VStack {
                Picker("数据类型", selection: $showingDataType) {
                    ForEach(ShowingData.allCases, id:\.self) { option in
                        Text(option.rawValue.localized)
                    }
                }
                .pickerStyle(.menu)
                .padding()
                switch showingDataType {
                case .abyssAvatarsUtilization:
                    AbyssAvatarsUtilizationView()
                case .fullStarHoldingRate:
                    HoldingRateView(type: .fullStarHoldingRate)
                case .holdingRate:
                    HoldingRateView(type: .holdingRate)
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

struct HoldingRateView: View {
    @EnvironmentObject var viewModel: ViewModel
    @State var result: FetchHomeModelResult<AvatarPercentageModel>?

    let type: DataType

    var body: some View {
        List {
            if let result = result {
                switch result {
                case .success(let data):
                    let data = data.data
                    Section {
                        ForEach(data.avatars, id: \.charId) { avatar in
                            HStack {
                                if let charLoc = viewModel.charLoc, let charMap = viewModel.charMap {
                                    let nameHash: Int = charMap["\(avatar.charId)"]?.NameTextMapHash ?? 0
                                    Text(charLoc["\(nameHash)"] ?? "Unknow")
                                }
                                Spacer()
                                Text("\(avatar.percentage ?? 0)")
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
            switch type {
            case .holdingRate:
                API.PSAServer.fetchHoldingRateData(queryStartDate: nil) { result in
                    self.result = result
                }
            case .fullStarHoldingRate:
                API.PSAServer.fetchFullStarHoldingRateData { result in
                    self.result = result
                }
            }

        }
    }
    enum DataType {
        case holdingRate
        case fullStarHoldingRate
    }
}

struct AbyssAvatarsUtilizationView: View {
    @State var data: UtilizationData?

    var body: some View {
        List {
            Text("施工中")
        }
    }
}

