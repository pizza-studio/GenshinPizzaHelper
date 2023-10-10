//
//  AllAvatarListSheetView.swift
//  GenshinPizzaHepler
//
//  Created by 戴藏龙 on 2022/10/22.
//

import HBMihoyoAPI
import HBPizzaHelperAPI
import SwiftUI

// MARK: - AllAvatarListSheetView

struct AllAvatarListSheetView: View {
    @EnvironmentObject
    var viewModel: ViewModel
    @State
    var allAvatarInfo: AllAvatarDetailModel?
    @State
    private var allAvatarListDisplayType: AllAvatarListDisplayType = .all

    let account: Account

    @Binding
    var sheetType: SheetTypesForDetailPortalView?

    var showingAvatars: [AllAvatarDetailModel.Avatar] {
        switch allAvatarListDisplayType {
        case .all:
            return allAvatarInfo?.avatars ?? []
        case ._4star:
            return allAvatarInfo?.avatars.filter { $0.rarity == 4 } ?? []
        case ._5star:
            return allAvatarInfo?.avatars.filter { $0.rarity == 5 } ?? []
        }
    }

    var body: some View {
        if let allAvatarInfo = allAvatarInfo {
            List {
                Section {
                    VStack(alignment: .leading, spacing: 3) {
                        Text(
                            "共拥有\(allAvatarInfo.avatars.count)名角色，其中五星角色\(allAvatarInfo.avatars.filter { $0.rarity == 5 }.count)名，四星角色\(allAvatarInfo.avatars.filter { $0.rarity == 4 }.count)名。"
                        )
                        Text(
                            "共获得\(goldNum(data: allAvatarInfo).allGold)金，其中角色\(goldNum(data: allAvatarInfo).charGold)金，武器\(goldNum(data: allAvatarInfo).weaponGold)金。（未统计旅行者和无人装备的五星武器）"
                        )
                    }.font(.footnote)
                }

                Section {
                    ForEach(showingAvatars, id: \.id) { avatar in
                        AvatarListItem(avatar: avatar)
                            .padding(.horizontal)
                            .padding(.vertical, 4)
                            .background {
                                if let asset = avatar.asset {
                                    EnkaWebIcon(iconString: asset.namecard.fileName).scaledToFill().opacity(0.6)
                                }
                            }
                    }
                }
                .textCase(.none)
                .listRowInsets(.init(top: 0, leading: 0, bottom: 0, trailing: 0))
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
                        ForEach(
                            AllAvatarListDisplayType.allCases,
                            id: \.rawValue
                        ) { choice in
                            Button(choice.rawValue.localized) {
                                withAnimation {
                                    allAvatarListDisplayType = choice
                                }
                            }
                        }
                    } label: {
                        Image(systemName: "arrow.left.arrow.right.circle")
                    }
                }
            }
            .sectionSpacing(UIFont.systemFontSize)
        } else {
            ProgressView()
                .onAppear {
                    MihoyoAPI.fetchAllAvatarInfos(
                        region: account.config.server.region,
                        serverID: account.config.server.id,
                        uid: account.config.uid!,
                        cookie: account.config.cookie!
                    ) { result in
                        switch result {
                        case let .success(data):
                            allAvatarInfo = data
                        case .failure:
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
        case _5star = "五星角色"
        case _4star = "四星角色"
    }

    func goldNum(data: AllAvatarDetailModel)
        -> (allGold: Int, charGold: Int, weaponGold: Int) {
        var charGold = 0
        var weaponGold = 0
        for avatar in data.avatars {
            if avatar.id == 10000005 || avatar.id == 10000007 {
                continue
            }
            if avatar.rarity == 5 {
                charGold += 1
                charGold += avatar.activedConstellationNum
            }
            if avatar.weapon.rarity == 5 {
                weaponGold += avatar.weapon.affixLevel
            }
        }
        return (charGold + weaponGold, charGold, weaponGold)
    }
}

// MARK: - AvatarListItem

struct AvatarListItem: View {
    let avatar: AllAvatarDetailModel.Avatar

    var body: some View {
        HStack(spacing: 3) {
            ZStack(alignment: .bottomLeading) {
                Group {
                    if let asset = avatar.asset {
                        asset.decoratedIcon(55, cutTo: .head)
                    } else {
                        WebImage(urlStr: avatar.icon)
                    }
                }
                .frame(width: 55, height: 55)
                .clipShape(Circle())
            }
            .frame(width: 75, alignment: .leading)
            .corneredTag(
                verbatim: "Lv.\(avatar.level)",
                alignment: .topTrailing
            )
            .corneredTag(
                "detailPortal.ECDDV.constellation.unit:\(avatar.activedConstellationNum)",
                alignment: .trailing
            )
            .corneredTag(
                verbatim: "♡\(avatar.fetter)",
                alignment: .bottomTrailing,
                enabled: !avatar.isProtagonist
            )
            VStack(spacing: 3) {
                HStack(alignment: .lastTextBaseline, spacing: 5) {
                    Text(avatar.nameCorrected)
                        .font(.systemCompressed(size: 20, weight: .bold))
                        .fixedSize(horizontal: true, vertical: false)
                        .minimumScaleFactor(0.5)
                        .lineLimit(1)
                    Spacer()
                }
                HStack(spacing: 0) {
                    ForEach(avatar.reliquaries, id: \.id) { reliquary in
                        Group {
                            WebImage(urlStr: reliquary.icon)
                                .scaledToFit()
                        }
                        .frame(width: 20, height: 20)
                    }
                    Spacer().frame(height: 20)
                }
            }
            ZStack(alignment: .bottomLeading) {
                Group {
                    EnkaWebIcon(
                        iconString: RankLevel(
                            rawValue: avatar
                                .weapon.rarity
                        )?
                            .squaredBackgroundIconString ?? ""
                    )
                    .opacity(0.5)
                    .scaledToFit()
                    .scaleEffect(1.1)
                    .clipShape(Circle())
                    WebImage(urlStr: avatar.weapon.icon)
                        .scaledToFit()
                }
                .frame(width: 50, height: 50)
            }
            .corneredTag(
                "精\(avatar.weapon.affixLevel)",
                alignment: .topLeading
            )
            .corneredTag(
                verbatim: "Lv.\(avatar.weapon.level)",
                alignment: .bottomTrailing
            )
        }
    }
}

// MARK: - AllAvatarListShareView

private struct AllAvatarListShareView: View {
    let accountName: String
    let showingAvatars: [AllAvatarDetailModel.Avatar]

    var eachColumnAvatars: [[AllAvatarDetailModel.Avatar]] {
        let chunkSize = 16 // 每列的角色数
        return stride(from: 0, to: showingAvatars.count, by: chunkSize).map {
            Array(showingAvatars[
                $0 ..<
                    min($0 + chunkSize, showingAvatars.count)
            ])
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            // Title
            HStack(alignment: .lastTextBaseline) {
                Text("\(accountName)").font(.title).bold()
                Text("的所有角色").font(.title)
            }
            .padding(.bottom, 9)
            // 正文
            HStack(alignment: .top) {
                ForEach(eachColumnAvatars, id: \.first!.id) { columnAvatars in
                    let view = VStack(alignment: .leading) {
                        ForEach(columnAvatars, id: \.id) { avatar in
                            AvatarListItemShare(
                                avatar: avatar
                            )
                        }
                    }
                    if columnAvatars != eachColumnAvatars.last {
                        view.padding(.trailing)
                    } else {
                        view
                    }
                }
            }
            HStack {
                Spacer()
                Image("AppIconHD")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 20, height: 20)
                    .clipShape(RoundedRectangle(cornerRadius: 5))
                Text("app.title.full").bold().font(.footnote)
            }
            .padding(.top, 2)
        }
        .padding()
    }
}

// MARK: - AvatarListItemShare

private struct AvatarListItemShare: View {
    let avatar: AllAvatarDetailModel.Avatar

    var body: some View {
        HStack {
            ZStack(alignment: .bottomLeading) {
                CharacterAsset.match(id: avatar.id).decoratedIcon(55, cutTo: .head)
                    .frame(width: 55, height: 55)
                    .clipShape(Circle())
                ZStack {
                    Image(systemName: "heart.fill")
                        .foregroundColor(Color(UIColor.darkGray))
                        .blendMode(.hardLight)
                    Text("\(avatar.fetter)")
                        .font(.caption2)
                        .foregroundColor(.white)
                }
            }
            .layoutPriority(2)
            VStack(alignment: .leading, spacing: 3) {
                HStack(alignment: .lastTextBaseline, spacing: 5) {
                    Text(avatar.nameCorrected)
                        .font(.system(size: 20, weight: .medium))
                        // .fixedSize(horizontal: true, vertical: false)
                        // .minimumScaleFactor(0.7)
                        .lineLimit(1)
                        .layoutPriority(1)
                    Spacer()
                    Text("Lv. \(avatar.level)")
                        .layoutPriority(1)
                        .fixedSize()
                        .font(.callout)
                    Text("detailPortal.ECDDV.constellation.unit:\(avatar.activedConstellationNum)")
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
                HStack(spacing: 0) {
                    HStack(spacing: 0) {
                        ZStack {
                            EnkaWebIcon(
                                iconString: RankLevel(
                                    rawValue: avatar
                                        .weapon.rarity
                                )?
                                    .squaredBackgroundIconString ?? ""
                            )
                            .scaledToFit()
                            .scaleEffect(1.1)
                            .clipShape(Circle())
                            if let iconString = URL(string: avatar.weapon.icon)?
                                .lastPathComponent.split(separator: ".").first {
                                EnkaWebIcon(
                                    iconString: String(iconString) +
                                        "_Awaken"
                                ).scaledToFit()
                            } else {
                                WebImage(urlStr: avatar.weapon.icon)
                                    .scaledToFit()
                            }
                        }
                        .frame(width: 25, height: 25)
                        .padding(.trailing, 3)
                        HStack(alignment: .lastTextBaseline, spacing: 5) {
                            Text("Lv. \(avatar.weapon.level)")
                                .font(.callout)
                                .fixedSize()
                            Text("精\(avatar.weapon.affixLevel)")
                                .font(.caption)
                                .padding(.horizontal, 5)
                                .background(
                                    Capsule()
                                        .foregroundColor(Color(
                                            UIColor
                                                .systemGray
                                        ))
                                        .opacity(0.2)
                                )
                                .fixedSize()
                        }
                    }
                    Spacer()
                    ForEach(avatar.reliquaries, id: \.id) { reliquary in
                        Group {
                            if let iconString = URL(string: reliquary.icon)?
                                .lastPathComponent.split(separator: ".").first {
                                EnkaWebIcon(iconString: String(iconString))
                                    .scaledToFit()
                            } else {
                                WebImage(urlStr: reliquary.icon)
                            }
                        }
                        .frame(width: 25, height: 25)
                    }
                }
            }
        }
    }
}

// MARK: - AllAvatarDetailModel.Avatar.nameCorrected Extension.

extension AllAvatarDetailModel.Avatar {
    /// 经过错字订正处理的角色姓名
    fileprivate var nameCorrected: String {
        CharacterAsset(rawValue: id)?.localized.localizedWithFix ?? "EnkaID-\(id)"
    }
}
