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
    let gachaViewModel: GachaViewModel = .shared

    @State var status: Status = .waitToStart
    @State var account: AccountConfiguration?

    var body: some View {
        List {
            switch status {
            case .waitToStart:
                Picker("Fetch whick Account", selection: $account) {
                    ForEach(viewModel.accounts.map( { $0.config } ), id: \.uid) { account in
                        Text(account.uid!)
                            .tag(account)
                    }
                }
                Button("Start") {
                    status = .running
                    let account = account!
                    gachaViewModel.getGachaAndSaveFor(account) { result in
                        switch result {
                        case .success(_):
                            self.status = .succeed
                        case .failure(let error):
                            self.status = .failure(error)
                        }
                    }
                }
                .disabled(account == nil)
            case .running:
                ProgressView()
            case .succeed:
                ForEach(gachaViewModel.gachaItems) { item in
                    VStack {
                        Text(item.name)
                        Text(item.id)
                    }
                }
            case .failure(let error):
                Text("ERROR: \(error.localizedDescription)")
            }

        }
        .onAppear {
            account = viewModel.accounts.first?.config
        }
    }

    enum Status {
        case waitToStart
        case running
        case succeed
        case failure(GetGachaError)
    }
}

