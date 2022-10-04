//
//  CharacterDetailView.swift
//  GenshinPizzaHepler
//
//  Created by 戴藏龙 on 2022/10/3.
//

import SwiftUI

@available(iOS 15, *)
struct CharacterDetailView: View {
    @EnvironmentObject var viewModel: ViewModel
    var account: Account
    var playerDetail: PlayerDetail { account.playerDetail! }
    @State var showingCharacterName: String
    var avatar: PlayerDetail.Avatar {
        account.playerDetail!.avatars.first(where: { avatar in
            avatar.name == showingCharacterName
        })!
    }

    var body: some View {
        TabView(selection: $showingCharacterName) {
            ForEach(playerDetail.avatars, id: \.name) { avatar in
                EachCharacterDetailDatasView(avatar: avatar)
            }
        }
        .tabViewStyle(.page)
        .onTapGesture {
            withAnimation(.easeInOut) {
                viewModel.showCharacterDetailOfAccount = nil
            }
        }
        .background(
            EnkaWebIcon(iconString: avatar.namecardIconString)
                .scaledToFill()
                .ignoresSafeArea(.all)
                .overlay(.thinMaterial)
        )
    }
}


