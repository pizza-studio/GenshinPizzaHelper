//
//  AbyssDetailDataDisplayView.swift
//  GenshinPizzaHepler
//
//  Created by 戴藏龙 on 2022/10/7.
//

import HBMihoyoAPI
import HBPizzaHelperAPI
import SwiftUI

// MARK: - AbyssDetailDataDisplayView

struct AbyssDetailDataDisplayView: View {
    let data: SpiralAbyssDetail
    let charMap: [String: ENCharacterMap.Character]

    var body: some View {
        List {
            // 总体战斗结果概览
            Section {
                InfoPreviewer(title: "最深抵达", content: data.maxFloor)
                InfoPreviewer(title: "获得渊星", content: "\(data.totalStar)")
                InfoPreviewer(
                    title: "战斗次数",
                    content: "\(data.totalBattleTimes)"
                )
                InfoPreviewer(title: "获胜次数", content: "\(data.totalWinTimes)")
            } header: {
                Text("战斗概览")
            }

            // 战斗数据榜
            if !data.damageRank.isEmpty, !data.defeatRank.isEmpty,
               !data.takeDamageRank.isEmpty, !data.normalSkillRank.isEmpty,
               !data.energySkillRank.isEmpty {
                Section {
                    BattleDataInfoProvider(
                        name: "最强一击",
                        value: data.damageRank.first?.value,
                        avatarID: data.damageRank.first?.avatarId,
                        charMap: charMap
                    )
                    BattleDataInfoProvider(
                        name: "最多击破数",
                        value: data.defeatRank.first?.value,
                        avatarID: data.defeatRank.first?.avatarId,
                        charMap: charMap
                    )
                    BattleDataInfoProvider(
                        name: "承受最多伤害",
                        value: data.takeDamageRank.first?.value,
                        avatarID: data.takeDamageRank.first?.avatarId,
                        charMap: charMap
                    )
                    BattleDataInfoProvider(
                        name: "元素战技释放数",
                        value: data.normalSkillRank.first?.value,
                        avatarID: data.normalSkillRank.first?.avatarId,
                        charMap: charMap
                    )
                    BattleDataInfoProvider(
                        name: "元素爆发次数",
                        value: data.energySkillRank.first?.value,
                        avatarID: data.energySkillRank.first?.avatarId,
                        charMap: charMap
                    )
                } header: {
                    Text("战斗数据榜")
                }
            } else {
                Text("暂无本期深渊数据")
            }

            ForEach(data.floors.reversed(), id: \.index) { floorData in
                AbyssFloorView(floorData: floorData, charMap: charMap)
            }
        }
        .listStyle(.sidebar)
    }
}

// MARK: - AbyssFloorView

private struct AbyssFloorView: View {
    let floorData: SpiralAbyssDetail.Floor
    let charMap: [String: ENCharacterMap.Character]

    var foldableTitleText: String {
        let initials = String(
            format: NSLocalizedString("第%lld层", comment: ""),
            floorData.index
        )
        if ThisDevice.isHDPhoneOrPodTouch || OS.type == .macOS {
            let buffer = NSMutableString()
            buffer.append(initials)
            buffer.append(" - ")
            buffer.append("获取渊星数".localized)
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
                        Label(title: { Text("获取渊星数") }) {
                            AbyssStarIcon()
                        }
                        Spacer()
                        Text("\(floorData.star)/\(floorData.maxStar)")
                    }
                    Divider().frame(height: 3)
                }
                ForEach(floorData.levels, id: \.index) { levelData in
                    AbyssLevelView(levelData: levelData, charMap: charMap)
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
    let charMap: [String: ENCharacterMap.Character]

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(spacing: 0) {
                Text("第\(levelData.index)间")
                    .font(.subheadline)
                    .bold()
                Spacer()
                if ThisDevice.isSmallestHDScreenPhone {
                    ForEach(0 ..< levelData.star, id: \.self) { _ in
                        Text(verbatim: "✶")
                    }
                } else {
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
                            AbyssBattleView(battleData: battleData, charMap: charMap)
                        }
                    }
                } else {
                    ForEach(levelData.battles, id: \.index) { battleData in
                        AbyssBattleView(battleData: battleData, charMap: charMap)
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
    let charMap: [String: ENCharacterMap.Character]

    var decoratedIconSize: CGFloat {
        ThisDevice.isSmallestHDScreenPhone ? 45 : 55
    }

    var body: some View {
        let intSpacing: CGFloat = ThisDevice.isHDPhoneOrPodTouch ? 0 : 2
        let size = decoratedIconSize
        let hasTermLabel = !(ThisDevice.isThinnestSplitOnPad || ThisDevice.isSmallestHDScreenPhone || OS.type == .macOS)
        HStack(alignment: .center, spacing: intSpacing) {
            Spacer().frame(minWidth: 0)
            Group {
                if hasTermLabel {
                    HStack {
                        switch battleData.index {
                        case 1:
                            Text("上半")
                                .font(.system(size: UIFont.smallSystemFontSize, design: .monospaced)).fixedSize()
                        case 2:
                            Text("下半")
                                .font(.system(size: UIFont.smallSystemFontSize, design: .monospaced)).fixedSize()
                        default:
                            Text("Unknown")
                                .font(.system(size: UIFont.smallSystemFontSize, design: .monospaced)).fixedSize()
                        }
                        Spacer()
                    }
                }
            }
            ForEach(battleData.avatars, id: \.id) { avatarData in
                let charID: String = "\(avatarData.id)"
                if let theChar = charMap[charID] {
                    if ThisDevice.isHDPhoneOrPodTouch {
                        theChar.asset.decoratedIcon(size, cutTo: .shoulder, roundRect: true)
                            .corneredTag("Lv.\(avatarData.level)", alignment: .bottom, textSize: 11)
                            .frame(height: size + 5)
                    } else {
                        if let charAsset = CharacterAsset(rawValue: avatarData.id) {
                            charAsset.cardIcon(size / 0.74)
                                .corneredTag("Lv.\(avatarData.level)", alignment: .bottom, textSize: 11)
                                .padding(.vertical, 2)
                        } else {
                            theChar.asset.cardIcon(size / 0.74)
                                .corneredTag("Lv.\(avatarData.level)", alignment: .bottom, textSize: 11)
                                .padding(.vertical, 2)
                        }
                    }
                } else {
                    let charNameID: String = charMap.getNameID(id: charID)
                    let charNameCard = "UI_AvatarIcon_\(charNameID)"
                    EnkaWebIcon(iconString: charNameCard)
                        .scaledToFill()
                        .frame(width: size, height: size / 0.74)
                        .clipped()
                        .scaledToFit()
                        .background(Color.gray)
                        .clipShape(RoundedRectangle(cornerRadius: size / 10))
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
    let charMap: [String: ENCharacterMap.Character]

    var body: some View {
        HStack {
            Text(name.localized)
            Spacer()
            Text("\(value ?? -1)").foregroundColor(.init(UIColor.systemGray))
            if let avatarID = avatarID, let character = charMap[avatarID.description] {
                character.asset.decoratedIcon(32, cutTo: .face)
            }
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
    let charMap: [String: ENCharacterMap.Character]

    var body: some View {
        if let floor = data.floors.last {
            ShareAbyssFloorView(floorData: floor, charMap: charMap)
        } else {
            Text("No Data")
        }
    }
}

// MARK: - ShareAbyssFloorView

private struct ShareAbyssFloorView: View {
    let floorData: SpiralAbyssDetail.Floor
    let charMap: [String: ENCharacterMap.Character]

    var body: some View {
        VStack {
            Text("深境螺旋第\(floorData.index)层").font(.title).bold()
            HStack {
                AbyssStarIcon()
                    .frame(width: 30, height: 30)
                Text("获取渊星数")
                Spacer()
                Text("\(floorData.star)/\(floorData.maxStar)")
            }
            .font(.headline)
            ForEach(floorData.levels, id: \.index) { levelData in
                AbyssLevelView(levelData: levelData, charMap: charMap)
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
    }
}
