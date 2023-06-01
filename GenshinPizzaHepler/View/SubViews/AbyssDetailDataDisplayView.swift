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
        if ThisDevice.isHDScreenRatio {
            let buffer = NSMutableString()
            buffer.append("深境螺旋第\(floorData.index)层".localized)
            buffer.append(" - ")
            buffer.append("获取渊星数".localized)
            buffer.append(": ")
            buffer.append("\(floorData.star)/\(floorData.maxStar)")
            return buffer.description
        }
        return "深境螺旋第\(floorData.index)层".localized
    }

    var body: some View {
        Section {
            let intSpacing: CGFloat = ThisDevice.isHDScreenRatio ? 0 : 2
            VStack(spacing: intSpacing) {
                if !ThisDevice.isHDScreenRatio {
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
    let levelData: SpiralAbyssDetail.Floor.Level
    let charMap: [String: ENCharacterMap.Character]

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(spacing: 0) {
                Text("第\(levelData.index)间")
                    .font(.subheadline)
                    .bold()
                Spacer()
                ForEach(0 ..< levelData.star, id: \.self) { _ in
                    AbyssStarIcon()
                        .frame(width: 25, height: 25)
                }
            }
            ForEach(levelData.battles, id: \.index) { battleData in
                AbyssBattleView(battleData: battleData, charMap: charMap)
            }
        }
    }
}

// MARK: - AbyssBattleView

private struct AbyssBattleView: View {
    let battleData: SpiralAbyssDetail.Floor.Level.Battle
    let charMap: [String: ENCharacterMap.Character]

    var body: some View {
        let intSpacing: CGFloat = ThisDevice.isHDScreenRatio ? 0 : 2
        HStack(alignment: .center, spacing: intSpacing) {
            switch battleData.index {
            case 1:
                Text("上半")
                    .font(.caption).fixedSize()
            case 2:
                Text("下半")
                    .font(.caption).fixedSize()
            default:
                Text("Unknown")
                    .font(.caption).fixedSize()
            }
            Spacer()
            ForEach(battleData.avatars, id: \.id) { avatarData in
                let charID: String = "\(avatarData.id)"
                if ThisDevice.isHDScreenRatio, let theChar = charMap[charID] {
                    theChar.decoratedIcon(55, cutTo: .shoulder)
                        .corneredTag("Lv.\(avatarData.level)", alignment: .bottom, textSize: 11)
                        .frame(height: 60)
                } else {
                    let charNameID: String = charMap.getNameID(id: charID)
                    let charNameCard = "UI_AvatarIcon_\(charNameID)_Card"
                    EnkaWebIcon(iconString: charNameCard)
                        .scaledToFit()
                        .frame(width: 65)
                        .corneredTag("Lv.\(avatarData.level)", alignment: .bottom, textSize: 11)
                }
                if avatarData.id != battleData.avatars.last!.id {
                    Spacer()
                }
            }
        }
    }
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
            if let avatarID = avatarID {
                let charIconString = charMap
                    .getSideIconString(id: "\(avatarID)")
                HomeSourceWebIcon(iconString: charIconString)
                    .frame(width: 35, height: 35)
                    .scaledToFit()
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
                Text("原神披萨小助手").bold().font(.footnote)
            }
        }
        .padding()
    }
}
