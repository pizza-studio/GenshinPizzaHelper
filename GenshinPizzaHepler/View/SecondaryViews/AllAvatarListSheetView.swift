//
//  AllAvatarListSheetView.swift
//  GenshinPizzaHepler
//
//  Created by 戴藏龙 on 2022/10/22.
//

import SwiftUI

@available(iOS 15.0, *)
struct AllAvatarListSheetView: View {
    @EnvironmentObject var viewModel: ViewModel
    @State var allAvatarInfo: AllAvatarDetailModel? = nil
    @State private var allAvatarListDisplayType: AllAvatarListDisplayType = .all

    let account: Account

    @Binding var sheetType: ToolsView.SheetTypes?

    var showingAvatars: [AllAvatarDetailModel.Avatar] {
        switch allAvatarListDisplayType {
        case .all:
            return allAvatarInfo?.avatars ?? []
        case ._4star:
            return allAvatarInfo?.avatars.filter({$0.rarity == 4}) ?? []
        case ._5star:
            return allAvatarInfo?.avatars.filter({$0.rarity == 5}) ?? []
        }
    }

    var body: some View {
        if let allAvatarInfo = allAvatarInfo {
            List {
                Section {
                    ForEach(showingAvatars, id: \.id) { avatar in
                        AvatarListItem(avatar: avatar)
                    }
                } header: {
                    Text("共拥有\(allAvatarInfo.avatars.count)名角色，其中五星角色\(allAvatarInfo.avatars.filter{ $0.rarity == 5 }.count)名，四星角色\(allAvatarInfo.avatars.filter{ $0.rarity == 4 }.count)名。")
                }
            }
            .navigationTitle("我的角色")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("完成") {
                        sheetType = nil
                    }
                }
                ToolbarItemGroup(placement: .navigationBarLeading) {
                    Menu {
                        ForEach(AllAvatarListDisplayType.allCases, id: \.rawValue) { choice in
                            Button(choice.rawValue) { allAvatarListDisplayType = choice }
                        }
                    } label: {
                        Image(systemName: "arrow.left.arrow.right.circle")
                    }
                }
            }
        } else {
            ProgressView()
                .onAppear {
                    API.Features.fetchAllAvatarInfos(region: account.config.server.region, serverID: account.config.server.id, uid: account.config.uid!, cookie: account.config.cookie!) { result in
                        switch result {
                        case .success(let data):
                            self.allAvatarInfo = data
                        case .failure(_):
                            break
                        }
                    }
                }
                .navigationTitle("我的角色")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("完成") {
                            sheetType = nil
                        }
                    }
                }
        }
    }

    private enum AllAvatarListDisplayType: String, CaseIterable {
        case all = "全部角色"
        case _5star = "5星角色"
        case _4star = "4星角色"
    }
}

@available(iOS 15.0, *)
struct AvatarListItem: View {
    @EnvironmentObject var viewModel: ViewModel
    let avatar: AllAvatarDetailModel.Avatar

    var body: some View {
        HStack {
            ZStack(alignment: .bottomLeading) {
                Group {
                    if let charMap = viewModel.charMap, let char = charMap["\(avatar.id)"] {
                        EnkaWebIcon(iconString: char.iconString)
                            .background(content: {
                                if let charMap = viewModel.charMap, let char = charMap["\(avatar.id)"] {
                                    EnkaWebIcon(iconString: char.namecardIconString)
                                        .scaledToFill()
                                        .offset(x: -55/3)
                                } else { EmptyView() }
                            })
                    } else {
                        WebImage(urlStr: avatar.icon)
                    }
                }
                .frame(width: 55, height: 55)
                .clipShape(Circle())
                Image(systemName: "heart.fill")
                    .overlay {
                        Text("\(avatar.fetter)")
                            .font(.caption2)
                            .foregroundColor(.white)
                    }
                    .foregroundColor(Color(UIColor.darkGray))
                    .blendMode(.hardLight)
            }
            VStack (spacing: 3) {
                HStack (alignment: .lastTextBaseline, spacing: 5) {
                    Text(avatar.name)
                        .font(.system(size: 20, weight: .medium))
//                        .fixedSize(horizontal: true, vertical: false)
                        .minimumScaleFactor(0.5)
                        .lineLimit(1)
                    Spacer()
                    Text("Lv. \(avatar.level)")
                        .layoutPriority(1)
                        .fixedSize()
                        .font(.callout)
                    Text("\(avatar.activedConstellationNum)命")
                        .font(.caption)
                        .padding(.horizontal, 5)
                        .background(
                            Capsule()
                                .foregroundColor(Color(UIColor.systemGray))
                                .opacity(0.2)
                        )
                        .layoutPriority(1)
                        .fixedSize()
                }
                HStack (spacing: 0) {
                    HStack(spacing: 0) {
                        ZStack {
                            EnkaWebIcon(iconString: RankLevel(rawValue: avatar.weapon.rarity)?.squaredBackgroundIconString ?? "")
                                .scaledToFit()
                                .scaleEffect(1.1)
                                .clipShape(Circle())
                            WebImage(urlStr: avatar.weapon.icon)
                                .scaledToFit()
                        }
                        .frame(width: 25, height: 25)
                        .padding(.trailing, 3)
                        HStack(alignment: .lastTextBaseline, spacing: 5) {
                            Text("Lv. \(avatar.weapon.level)")
                                .font(.callout)
                            Text("精\(avatar.weapon.affixLevel)")
                                .font(.caption)
                                .padding(.horizontal, 5)
                                .background(
                                    Capsule()
                                        .foregroundColor(Color(UIColor.systemGray))
                                        .opacity(0.2)
                                )
                        }
                    }
                    Spacer()
                    ForEach(avatar.reliquaries, id: \.id) { reliquary in
                        WebImage(urlStr: reliquary.icon)
                            .frame(width: 25, height: 25)
                    }
                }
            }
        }
    }
}


