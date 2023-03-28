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
                            withAnimation {
                                self.status = .succeed
                            }
                        case .failure(let error):
                            withAnimation {
                                self.status = .failure(error)
                            }
                        }
                    }
                }
                .disabled(account == nil)
            }
            .disabled(status == .running)

            switch status {
            case .waitToStart:
                EmptyView()
            case .running:
                Section {

                    HStack {
                        Text("正在获取...请等待")
                        Spacer()
                        ProgressView()
                    }
                    HStack {
                        Text("卡池：")
                        Spacer()
                        Text("\(observer.gachaType.localizedDescription())")
                    }
                    HStack {
                        Text("页码：")
                        Spacer()
                        Text("\(observer.page)")
                    }
                    HStack {
                        Text("获取到新纪录：")
                        Spacer()
                        Text("\(observer.newItemCount)条")
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
                    Label {
                        Text("获取祈愿记录成功")
                    } icon: {
                        Image(systemName: "checkmark.circle")
                            .foregroundColor(.green)
                    }
                    Text("成功保存：\(observer.newItemCount)条新记录")
                    Text("请返回上一级查看")
                }
                Section {
                    ForEach(gachaViewModel.gachaItems) { item in
                        VStack(alignment: .leading) {
                            Text(item.name)
                            Text(item.id)
                                .foregroundColor(.gray)
                        }
                    }
                }
            case .failure(let error):
                Section {
                    Label {
                        Text("获取祈愿记录失败")
                    } icon: {
                        Image(systemName: "xmark.circle")
                            .foregroundColor(.red)
                    }
                    Text("ERROR: \(error.localizedDescription)")
                }
            }
        }
        .onAppear {
            account = viewModel.accounts.first?.config
        }
        .navigationBarBackButtonHidden(status == .running)
    }

    enum Status: Equatable {
        case waitToStart
        case running
        case succeed
        case failure(GetGachaError)
    }
}
