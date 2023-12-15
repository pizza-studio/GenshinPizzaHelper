//
//  AbyssDetailDataDisplayView.swift
//  GenshinPizzaHepler
//
//  Created by 戴藏龙 on 2022/10/7.
//

import GIPizzaKit
import HBMihoyoAPI
import HoYoKit
import SwiftUI

// MARK: - AbyssDetailDataDisplayView

struct AbyssDetailDataDisplayView: View {
    let data: SpiralAbyssDetail

    var body: some View {
        List {
            // 战斗数据榜
            if !data.rankDataMissing {
                // 总体战斗结果概览
                Section {
                    InfoPreviewer(title: "app.abyss.info.deepest", content: data.maxFloor)
                    InfoPreviewer(title: "app.abyss.info.star", content: "\(data.totalStar)")
                    InfoPreviewer(
                        title: "app.abyss.info.battle",
                        content: "\(data.totalBattleTimes)"
                    )
                    InfoPreviewer(title: "app.abyss.info.win", content: "\(data.totalWinTimes)")
                } header: {
                    Text("app.abyss.info.summary")
                }
                .listRowMaterialBackground()

                Section {
                    BattleDataInfoProvider(
                        name: "app.abyss.info.strongest",
                        value: data.damageRank.first?.value,
                        avatarID: data.damageRank.first?.avatarId
                    )
                    BattleDataInfoProvider(
                        name: "app.abyss.info.mostDefeats",
                        value: data.defeatRank.first?.value,
                        avatarID: data.defeatRank.first?.avatarId
                    )
                    BattleDataInfoProvider(
                        name: "app.abyss.info.mostDamageTaken",
                        value: data.takeDamageRank.first?.value,
                        avatarID: data.takeDamageRank.first?.avatarId
                    )
                    BattleDataInfoProvider(
                        name: "app.abyss.info.mostESkills",
                        value: data.normalSkillRank.first?.value,
                        avatarID: data.normalSkillRank.first?.avatarId
                    )
                    BattleDataInfoProvider(
                        name: "app.abyss.info.mostQSkills",
                        value: data.energySkillRank.first?.value,
                        avatarID: data.energySkillRank.first?.avatarId
                    )
                } header: {
                    Text("app.abyss.info.notableStats")
                }
                .listRowMaterialBackground()
            } else {
                Text("app.abyss.noData").listRowMaterialBackground()
            }

            ForEach(data.floors.reversed(), id: \.index) { floorData in
                AbyssFloorView(floorData: floorData).listRowMaterialBackground()
            }
        }
        .listStyle(.insetGrouped)
        .scrollContentBackground(.hidden)
        .listContainerBackground(fileNameOverride: NameCard.UI_NameCardPic_Sj1_P.fileName)
        .navigationTitle("app.abyss.info.title")
        .toolbarSavePhotoButton(visible: !data.rankDataMissing) {
            AbyssShareView(data: data)
        }
    }
}

// MARK: - AbyssFloorView

private struct AbyssFloorView: View {
    let floorData: SpiralAbyssDetail.Floor

    var foldableTitleText: String {
        let initials = String(
            format: NSLocalizedString("app.abyss.info.floor", comment: ""),
            floorData.index
        )
        if ThisDevice.isHDPhoneOrPodTouch || OS.type == .macOS {
            let buffer = NSMutableString()
            buffer.append(initials)
            buffer.append(" - ")
            buffer.append("app.abyss.star.obtained".localized)
            buffer.append(": ")
            buffer.append("\(floorData.star)/\(floorData.maxStar)")
            return buffer.description
        }
        return initials
    }

    var body: some View {
        Section {
            let intSpacing: CGFloat = ThisDevice.isHDPhoneOrPodTouch ? 0 : 2
            VStack(spacing: intSpacing) {
                if !(ThisDevice.isHDPhoneOrPodTouch || OS.type == .macOS) {
                    HStack {
                        Label(title: { Text("app.abyss.star.obtained") }) {
                            AbyssStarIcon()
                        }
                        Spacer()
                        Text("\(floorData.star)/\(floorData.maxStar)")
                    }
                    Divider().frame(height: 3)
                }
                ForEach(floorData.levels, id: \.index) { levelData in
                    AbyssLevelView(levelData: levelData)
                }
            }
        } header: {
            Text(foldableTitleText)
        }
    }
}

// MARK: - AbyssLevelView

private struct AbyssLevelView: View {
    // MARK: Internal

    let levelData: SpiralAbyssDetail.Floor.Level

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(spacing: 0) {
                if ThisDevice.isSmallestSlideOverWindowWidth || ThisDevice.isSmallestHDScreenPhone {
                    Text("第\(levelData.index)间")
                        .font(.subheadline)
                        .bold()
                        .frame(minHeight: 20)
                    Spacer()
                    ForEach(0 ..< levelData.star, id: \.self) { _ in
                        Text(verbatim: "✶")
                    }
                } else {
                    Text("第\(levelData.index)间")
                        .font(.subheadline)
                        .bold()
                        .frame(minHeight: 25)
                    Spacer()
                    ForEach(0 ..< levelData.star, id: \.self) { _ in
                        AbyssStarIcon()
                            .frame(width: 25, height: 25)
                    }
                }
            }
            Group {
                if (OS.type == .iPadOS && (!ThisDevice.isSplitOrSlideOver || ThisDevice.isWidestSplitOnPad)) || OS
                    .type == .macOS {
                    HStack {
                        ForEach(levelData.battles, id: \.index) { battleData in
                            AbyssBattleView(battleData: battleData)
                        }
                    }
                } else {
                    ForEach(levelData.battles, id: \.index) { battleData in
                        AbyssBattleView(battleData: battleData)
                    }
                }
            }.environmentObject(orientation)
        }
    }

    // MARK: Private

    @StateObject
    private var orientation = ThisDevice.DeviceOrientation()
}

// MARK: - AbyssBattleView

private struct AbyssBattleView: View {
    // MARK: Internal

    let battleData: SpiralAbyssDetail.Floor.Level.Battle

    var decoratedIconSize: CGFloat {
        (ThisDevice.isSmallestSlideOverWindowWidth || ThisDevice.isSmallestHDScreenPhone) ? 45 : 55
    }

    var body: some View {
        let intSpacing: CGFloat = ThisDevice.isHDPhoneOrPodTouch ? 0 : 2
        let size = decoratedIconSize
        let hasTermLabel = !(
            ThisDevice.isThinnestSplitOnPad || ThisDevice.isSmallestSlideOverWindowWidth || ThisDevice
                .isSmallestHDScreenPhone || OS.type == .macOS
        )
        HStack(alignment: .center, spacing: intSpacing) {
            Spacer().frame(minWidth: 0)
            Group {
                if hasTermLabel {
                    HStack {
                        switch battleData.index {
                        case 1:
                            Text("app.abyss.half.1")
                                .font(.system(size: UIFont.smallSystemFontSize, design: .monospaced)).fixedSize()
                        case 2:
                            Text("app.abyss.half.2")
                                .font(.system(size: UIFont.smallSystemFontSize, design: .monospaced)).fixedSize()
                        default:
                            Text("sys.unknown")
                                .font(.system(size: UIFont.smallSystemFontSize, design: .monospaced)).fixedSize()
                        }
                        Spacer()
                    }
                }
            }
            ForEach(battleData.avatars, id: \.id) { avatarData in
                let theAsset = CharacterAsset.match(id: avatarData.id)
                if ThisDevice.isHDPhoneOrPodTouch {
                    theAsset.decoratedIcon(size, cutTo: .head, roundRect: true)
                        .corneredTag("\(avatarData.level)", alignment: .bottomTrailing, textSize: 11)
                        .frame(height: size + 5)
                } else {
                    theAsset.cardIcon(size / 0.74)
                        .corneredTag("Lv.\(avatarData.level)", alignment: .bottom, textSize: 11)
                        .padding(.vertical, 2)
                }
                if avatarData.id != battleData.avatars.last!.id {
                    Spacer().frame(minWidth: 0)
                }
            }
            Spacer().frame(minWidth: 0, maxWidth: hasTermLabel ? .infinity : nil)
        }.environmentObject(orientation)
    }

    // MARK: Private

    @StateObject
    private var orientation = ThisDevice.DeviceOrientation()
}

// MARK: - BattleDataInfoProvider

private struct BattleDataInfoProvider: View {
    let name: String
    let value: Int?
    let avatarID: Int?

    var body: some View {
        HStack {
            Text(name.localized)
            Spacer()
            Text("\(value ?? -1)").foregroundColor(.init(UIColor.systemGray))
            CharacterAsset.match(id: avatarID ?? -213).decoratedIcon(32, cutTo: .face)
        }
    }
}

// MARK: - AbyssStarIcon

struct AbyssStarIcon: View {
    @Environment(\.colorScheme)
    var colorSheme

    var body: some View {
        switch colorSheme {
        case .light:
            Image("star.abyss.dark").resizable().scaledToFit()
        case .dark:
            Image("star.abyss").resizable().scaledToFit()
        @unknown default:
            Image("star.abyss").resizable().scaledToFit()
        }
    }
}

// MARK: - AbyssShareView

struct AbyssShareView: View {
    let data: SpiralAbyssDetail

    var body: some View {
        if let floor = data.floors.last {
            ShareAbyssFloorView(floorData: floor)
        } else {
            Text("No Data")
        }
    }
}

// MARK: - ShareAbyssFloorView

private struct ShareAbyssFloorView: View {
    let floorData: SpiralAbyssDetail.Floor

    var body: some View {
        VStack {
            Text("深境螺旋第\(floorData.index)层").font(.title).bold()
            HStack {
                AbyssStarIcon()
                    .frame(width: 30, height: 30)
                Text("app.abyss.star.obtained")
                Spacer()
                Text("\(floorData.star)/\(floorData.maxStar)")
            }
            .font(.headline)
            ForEach(floorData.levels, id: \.index) { levelData in
                AbyssLevelView(levelData: levelData)
            }
            HStack {
                Image("AppIconHD")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 20, height: 20)
                    .clipShape(RoundedRectangle(cornerRadius: 5))
                Text("app.title.full").bold().font(.footnote)
            }
        }
        .padding()
        .foregroundStyle(.white)
        .listContainerBackground(fileNameOverride: NameCard.UI_NameCardPic_Sj1_P.fileName)
        .environment(\.colorScheme, .dark)
    }
}
