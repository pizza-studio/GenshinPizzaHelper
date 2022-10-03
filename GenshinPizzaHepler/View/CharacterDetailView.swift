//
//  CharacterDetailView.swift
//  GenshinPizzaHepler
//
//  Created by 戴藏龙 on 2022/10/3.
//

import SwiftUI

struct CharacterDetailView: View {
    @EnvironmentObject var viewModel: ViewModel
    var account: Account
    var playerDetail: PlayerDetail { account.playerDetail! }
    @State var showingCharacterName: String

    var body: some View {
        TabView(selection: $showingCharacterName) {
            ForEach(playerDetail.avatars, id: \.name) { avatar in
                EachCharacterDetailDatasView(avatar: avatar)
            }
        }
        .tabViewStyle(.page)
        .onTapGesture {
            viewModel.showCharacterDetailOfAccount = nil
        }
        .background(Color.yellow.ignoresSafeArea())
    }
}


