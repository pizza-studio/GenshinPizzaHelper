//
//  GetGachaView.swift
//  GenshinPizzaHepler
//
//  Created by 戴藏龙 on 2023/3/28.
//

import SwiftUI

struct GetGachaView: View {
    @EnvironmentObject
    var viewModel: ViewModel
    @StateObject
    var gachaViewModel: GachaViewModel = .shared
    @StateObject
    var observer: GachaFetchProgressObserver = .shared

    @State var status: Status = .waitToStart
    @State var account: AccountConfiguration?

    var body: some View {
        List {
            Section {
                Picker("选择账号", selection: $account) {
                    ForEach(viewModel.accounts.map( { $0.config } ), id: \.uid) { account in
                        Text("\(account.name!) (\(account.uid!))" )
                            .tag(account)
                    }
                }
                Button("获取祈愿记录") {
                    status = .running
                    let account = account!
                    gachaViewModel.getGachaAndSaveFor(account, observer: observer) { result in
                        switch result {
                        case .success(_):
                            self.status = .succeed
                        case .failure(let error):
                            self.status = .failure(error)
                        }
                    }
                }
            }
            .disabled((account == nil) || (status == .running))

            switch status {
            case .waitToStart:
                EmptyView()
            case .running:
                Section {
                    HStack {
                        Text("正在获取\(observer.page)页")
                        Spacer()
                        ProgressView()
                    }
                }
                if let items = observer.currentItems {
                    Section {
                        ForEach(items) { item in
                            VStack(alignment: .leading) {
                                Text(item.name)
                                    .foregroundColor(.init(UIColor.darkGray))
                                Text(item.time)
                                    .foregroundColor(.init(UIColor.lightGray))
                            }
                        }
                    } header: {
                        Text("成功获取到一批...")
                    }
                }
            case .succeed:
                Section {
                    ForEach(gachaViewModel.gachaItems) { item in
                        VStack(alignment: .leading) {
                            Text(item.name)
                                .foregroundColor(.init(UIColor.darkGray))
                            Text(item.id)
                                .foregroundColor(.init(UIColor.lightGray))
                        }
                    }
                } header: {
                    Text("获取祈愿记录成功")
                }
            case .failure(let error):
                Text("ERROR: \(error.localizedDescription)")
            }

        }
        .onAppear {
            account = viewModel.accounts.first?.config
        }
    }

    enum Status: Equatable {
        case waitToStart
        case running
        case succeed
        case failure(GetGachaError)
    }
}
