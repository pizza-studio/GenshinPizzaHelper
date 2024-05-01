//
//  AllAvatarListSheetView.swift
//  GenshinPizzaHepler
//
//  Created by 戴藏龙 on 2022/10/22.
//

import Flow
import GIPizzaKit
import HoYoKit
import SFSafeSymbols
import SwiftUI

// MARK: - AllAvatarListSheetView

struct AllAvatarListSheetView: View {
    // MARK: Internal

    @EnvironmentObject
    var vmDPV: DetailPortalViewModel

    var data: AllAvatarDetailModel

    @State
    var expanded: Bool = true

    var body: some View {
        List {
            Section {
                VStack(alignment: .leading, spacing: 3) {
                    Text(characterStats)
                    Text(weaponStats)
                }.font(.footnote)
            }.listRowMaterialBackground()
            Group {
                if expanded {
                    allAvatarListFull
                } else {
                    allAvatarListCondensed
                }
            }.listRowMaterialBackground()
        }
        .scrollContentBackground(.hidden)
        .listContainerBackground(fileNameOverride: vmDPV.currentAccountNamecardFileName)
        .navigationTitle("app.characters.title")
        .toolbar {
            ToolbarItemGroup(placement: .navigationBarTrailing) {
                Menu {
                    Picker("", selection: $expanded.animation()) {
                        Text("detailPortal.aalsv.expand.tabText").tag(true)
                        Text("detailPortal.aalsv.collapse.tabText").tag(false)
                    }
                    .labelsHidden()
                    .pickerStyle(.segmented)
                    .background(
                        RoundedRectangle(cornerRadius: 8).foregroundStyle(.thinMaterial)
                    )
                    Divider()
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
                    Image(systemSymbol: .arrowLeftArrowRightCircle)
                }
            }
        }
        .refreshable {
            vmDPV.refresh()
        }
    }

    @ViewBuilder
    var allAvatarListFull: some View {
        Section {
            ForEach(showingAvatars, id: \.id) { avatar in
                AvatarListItem(avatar: avatar, condensed: false)
                    .padding(.horizontal)
                    .padding(.vertical, 4)
                    .background {
                        if let asset = avatar.asset {
                            let bg = EnkaWebIcon(iconString: asset.namecard.fileName).scaledToFill()
                                .opacity(0.6)
                            if #unavailable(iOS 17) {
                                bg.frame(maxHeight: 63).clipped()
                            } else {
                                bg
                            }
                        }
                    }
            }
        }
        .textCase(.none)
        .listRowInsets(.init(top: 0, leading: 0, bottom: 0, trailing: 0))
    }

    @ViewBuilder
    var allAvatarListCondensed: some View {
        HFlow {
            ForEach(showingAvatars, id: \.id) { avatar in
                AvatarListItem(avatar: avatar, condensed: true)
                    .padding(.vertical, 4)
            }
        }
        .listRowInsets(.init(top: 4, leading: 4, bottom: 4, trailing: 4))
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

    // MARK: Private

    private enum AllAvatarListDisplayType: String, CaseIterable {
        case all = "app.characters.filter.all"
        case _5star = "app.characters.filter.5star"
        case _4star = "app.characters.filter.4star"
    }

    @Environment(\.dismiss)
    private var dismiss

    @State
    private var allAvatarListDisplayType: AllAvatarListDisplayType = .all

    private var characterStats: LocalizedStringKey {
        let a = data.avatars.count
        let b = data.avatars.filter { $0.rarity == 5 }.count
        let c = data.avatars.filter { $0.rarity == 4 }.count
        return "app.characters.count.character:\(a, specifier: "%lld")\(b, specifier: "%lld")\(c, specifier: "%lld")"
    }

    private var weaponStats: LocalizedStringKey {
        let d = goldNum(data: data).allGold
        let e = goldNum(data: data).charGold
        let f = goldNum(data: data).weaponGold
        return "app.characters.count.weapon:\(d, specifier: "%lld")\(e, specifier: "%lld")\(f, specifier: "%lld")"
    }

    private var showingAvatars: [AllAvatarDetailModel.Avatar] {
        switch allAvatarListDisplayType {
        case .all:
            return data.avatars
        case ._4star:
            return data.avatars.filter { $0.rarity == 4 }
        case ._5star:
            return data.avatars.filter { $0.rarity == 5 }
        }
    }
}

// MARK: - AvatarListItem

struct AvatarListItem: View {
    // MARK: Internal

    let avatar: AllAvatarDetailModel.Avatar

    @State
    var condensed: Bool

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
                verbatim: fetterTag,
                alignment: .bottomTrailing,
                enabled: !avatar.isProtagonist
            )
            if !condensed {
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
                    LocalizedStringKey("weapon.affix:\(avatar.weapon.affixLevel)"),
                    alignment: .topLeading
                )
                .corneredTag(
                    verbatim: "Lv.\(avatar.weapon.level)",
                    alignment: .bottomTrailing
                )
            }
        }
    }

    // MARK: Private

    private var fetterTag: String {
        condensed ? "" : "♡\(avatar.fetter)"
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
                Text("app.characters.ownedCharacters.title").font(.title)
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
                    Image(systemSymbol: .heartFill)
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
                    Text(verbatim: "Lv. \(avatar.level)")
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
                            Text(verbatim: "Lv. \(avatar.weapon.level)")
                                .font(.callout)
                                .fixedSize()
                            let affix = String(format: "weapon.affix:%lld", avatar.weapon.affixLevel).localized
                            Text(affix)
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
