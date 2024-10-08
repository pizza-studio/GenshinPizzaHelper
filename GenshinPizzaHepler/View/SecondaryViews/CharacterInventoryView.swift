//
//  AllAvatarListSheetView.swift
//  GenshinPizzaHepler
//
//  Created by 戴藏龙 on 2022/10/22.
//

import GIPizzaKit
import HoYoKit
import SFSafeSymbols
import SwiftUI

// MARK: - CharacterInventoryView

struct CharacterInventoryView: View {
    // MARK: Lifecycle

    public init(data: CharacterInventoryModel) {
        self.data = data
    }

    // MARK: Internal

    var body: some View {
        List {
            Section {
                VStack(alignment: .leading, spacing: 3) {
                    Text(characterStats)
                    if expanded {
                        Text(goldStats)
                    }
                }.font(.footnote)
            }.listRowMaterialBackground()
            Group {
                if expanded {
                    renderAllAvatarListFull()
                } else {
                    renderAllAvatarListCondensed()
                }
            }.listRowMaterialBackground()
        }
        .scrollContentBackground(.hidden)
        .listContainerBackground(fileNameOverride: vmDPV.currentAccountNamecardFileName)
        .navigationTitle("app.characters.title")
        .toolbar {
            ToolbarItemGroup(placement: .navigationBarTrailing) {
                Picker("", selection: $expanded.animation()) {
                    Text("detailPortal.inventoryView.expand.tabText").tag(true)
                    Text("detailPortal.inventoryView.collapse.tabText").tag(false)
                }
                .pickerStyle(.menu)
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
                    Image(systemSymbol: .arrowLeftArrowRightCircle)
                }
            }
        }
        .refreshable {
            vmDPV.refresh()
        }
    }

    @ViewBuilder
    func renderAllAvatarListFull() -> some View {
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
                    .compositingGroup()
            }
        }
        .textCase(.none)
        .listRowInsets(.init(top: 0, leading: 0, bottom: 0, trailing: 0))
    }

    @ViewBuilder
    func renderAllAvatarListCondensed() -> some View {
        StaggeredGrid(
            columns: lineCapacity, outerPadding: false,
            scroll: false, spacing: 2, list: showingAvatars
        ) { avatar in
            // WIDTH: 70, HEIGHT: 63
            AvatarListItem(avatar: avatar, condensed: true)
                .padding(.vertical, 4)
                .compositingGroup()
        }
        .environmentObject(orientation)
        .overlay {
            GeometryReader { geometry in
                Color.clear.onAppear {
                    containerSize = geometry.size
                }.onChange(of: geometry.size) { newSize in
                    containerSize = newSize
                }
            }
        }
    }

    func goldNum(data: CharacterInventoryModel)
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

    private let data: CharacterInventoryModel

    @State
    private var allAvatarListDisplayType: AllAvatarListDisplayType = .all
    @State
    private var expanded: Bool = false
    @State
    private var containerSize: CGSize = .init(width: 320, height: 320)
    @StateObject
    private var orientation = ThisDevice.DeviceOrientation()
    @Environment(\.dismiss)
    private var dismiss
    @EnvironmentObject
    private var vmDPV: DetailPortalViewModel

    private var characterStats: LocalizedStringKey {
        let a = data.avatars.count
        let b = data.avatars.filter { $0.rarity == 5 }.count
        let c = data.avatars.filter { $0.rarity == 4 }.count
        return "app.characters.count.character:\(a, specifier: "%lld")\(b, specifier: "%lld")\(c, specifier: "%lld")"
    }

    private var goldStats: LocalizedStringKey {
        let d = goldNum(data: data).allGold
        let e = goldNum(data: data).charGold
        let f = goldNum(data: data).weaponGold
        return "app.characters.count.golds:\(d, specifier: "%lld")\(e, specifier: "%lld")\(f, specifier: "%lld")"
    }

    private var showingAvatars: [CharacterInventoryModel.Avatar] {
        switch allAvatarListDisplayType {
        case .all:
            return data.avatars
        case ._4star:
            return data.avatars.filter { $0.rarity == 4 }
        case ._5star:
            return data.avatars.filter { $0.rarity == 5 }
        }
    }

    private var lineCapacity: Int {
        Int(floor((containerSize.width - 20) / 70))
    }
}

// MARK: - AvatarListItem

struct AvatarListItem: View {
    // MARK: Internal

    let avatar: CharacterInventoryModel.Avatar

    @State
    var condensed: Bool

    var body: some View {
        HStack(spacing: condensed ? 0 : 3) {
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
            .frame(width: condensed ? 70 : 75, alignment: .leading)
            .corneredTag(
                verbatim: "Lv.\(avatar.level)",
                alignment: .topTrailing
            )
            .corneredTag(
                "detailPortal.EASV.constellation.unit:\(avatar.activedConstellationNum)",
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
    let showingAvatars: [CharacterInventoryModel.Avatar]

    var eachColumnAvatars: [[CharacterInventoryModel.Avatar]] {
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
    let avatar: CharacterInventoryModel.Avatar

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
                    Text("detailPortal.EASV.constellation.unit:\(avatar.activedConstellationNum)")
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
                            EnkaWebIcon(
                                iconString: "gi_weapon_\(avatar.weapon.id)"
                            ).scaledToFit()
                        }
                        .frame(width: 25, height: 25)
                        .padding(.trailing, 3)
                        HStack(alignment: .lastTextBaseline, spacing: 5) {
                            Text(verbatim: "Lv. \(avatar.weapon.level)")
                                .font(.callout)
                                .fixedSize()
                            let affix = String(format: "weapon.affix:%lld".localized, avatar.weapon.affixLevel)
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

// MARK: - CharacterInventoryModel.Avatar.nameCorrected Extension.

extension CharacterInventoryModel.Avatar {
    /// 经过错字订正处理的角色姓名
    fileprivate var nameCorrected: String {
        CharacterAsset(rawValue: id)?.localized.localizedWithFix ?? "EnkaID-\(id)"
    }
}
