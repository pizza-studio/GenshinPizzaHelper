//
//  AbyssDetailDataDisplayView.swift
//  GenshinPizzaHepler
//
//  Created by 戴藏龙 on 2022/10/7.
//

import SwiftUI

struct AbyssDetailDataDisplayView: View {
    let data: SpiralAbyssDetail
    let charMap: [String: ENCharacterMap.Character]

    var body: some View {
        List {
            // 总体战斗结果概览
            Section {
                InfoPreviewer(title: "最深抵达", content: data.maxFloor)
                InfoPreviewer(title: "获得渊星", content: "\(data.totalStar)")
                InfoPreviewer(title: "战斗次数", content: "\(data.totalBattleTimes)")
                InfoPreviewer(title: "获胜次数", content: "\(data.totalWinTimes)")
            } header: {
                Text("战斗概览")
            }

            // 战斗数据榜
            Section {
                HStack {
                    Text("最强一击")
                    Spacer()
                    Text("\(data.damageRank.first?.value ?? -1)")
                    let charID = "\(data.damageRank.first?.avatarId ?? 0)"
                    let charIconString = charMap.getSideIconString(id: charID)
                    HomeSourceWebIcon(iconString: charIconString)
                        .frame(width: 35, height: 35)
                        .scaledToFit()
                }
                HStack {
                    Text("最多击破数")
                    Spacer()
                    Text("\(data.defeatRank.first?.value ?? -1)")
                    let charID = "\(data.defeatRank.first?.avatarId ?? 0)"
                    let charIconString = charMap.getSideIconString(id: charID)
                    HomeSourceWebIcon(iconString: charIconString)
                        .frame(width: 35, height: 35)
                        .scaledToFit()
                }
                HStack {
                    Text("承受最多伤害")
                    Spacer()
                    Text("\(data.takeDamageRank.first?.value ?? -1)")
                    let charID = "\(data.takeDamageRank.first?.avatarId ?? 0)"
                    let charIconString = charMap.getSideIconString(id: charID)
                    HomeSourceWebIcon(iconString: charIconString)
                        .frame(width: 35, height: 35)
                        .scaledToFit()
                }
                HStack {
                    Text("元素战技释放数")
                    Spacer()
                    Text("\(data.normalSkillRank.first?.value ?? -1)")
                    let charID = "\(data.normalSkillRank.first?.avatarId ?? 0)"
                    let charIconString = charMap.getSideIconString(id: charID)
                    HomeSourceWebIcon(iconString: charIconString)
                        .frame(width: 35, height: 35)
                        .scaledToFit()
                }
                HStack {
                    Text("元素爆发次数")
                    Spacer()
                    Text("\(data.energySkillRank.first?.value ?? -1)")
                    let charID = "\(data.energySkillRank.first?.avatarId ?? 0)"
                    let charIconString = charMap.getSideIconString(id: charID)
                    HomeSourceWebIcon(iconString: charIconString)
                        .frame(width: 35, height: 35)
                        .scaledToFit()
                }
            } header: {
                Text("战斗数据榜")
            }

            ForEach(data.floors.reversed(), id:\.index) { floorData in
                AbyssFloorView(floorData: floorData, charMap: charMap)
            }
        }
        .listStyle(.sidebar)
    }
}

struct AbyssFloorView: View {
    let floorData: SpiralAbyssDetail.Floor
    let charMap: [String: ENCharacterMap.Character]

    var body: some View {
        Section {
            HStack {
                Label(title: {Text("获取渊星数")}) {
                    AbyssStarIcon()
                }
                Spacer()
                Text("\(floorData.star)/\(floorData.maxStar)")
            }
            ForEach(floorData.levels, id: \.index) { levelData in
                AbyssLevelView(levelData: levelData, charMap: charMap)
            }
        } header: {
            Text("深境螺旋第\(floorData.index)层")
        }
    }
}

struct AbyssLevelView: View {
    let levelData: SpiralAbyssDetail.Floor.Level
    let charMap: [String: ENCharacterMap.Character]

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(spacing: 0) {
                Text("第\(levelData.index)间")
                    .font(.subheadline)
                Spacer()
                ForEach(0 ..< levelData.star, id:\.self) { _ in
                    AbyssStarIcon()
                        .frame(width: 30, height: 30)
                }
            }
            ForEach(levelData.battles, id:\.index) { battleData in
                AbyssBattleView(battleData: battleData, charMap: charMap)
            }
        }
    }
}

struct AbyssBattleView: View {
    let battleData: SpiralAbyssDetail.Floor.Level.Battle
    let charMap: [String: ENCharacterMap.Character]

    var body: some View {
        HStack(alignment: .top, spacing: 0) {
            switch battleData.index {
            case 1:
                Text("上半")
                    .font(.caption)
            case 2:
                Text("下半")
                    .font(.caption)
            default:
                Text("Unknown")
                    .font(.caption)
            }
            ForEach(battleData.avatars, id:\.id) { avatarData in
                let charID: String = "\(avatarData.id)"
                let charNameID: String = charMap.getNameID(id: charID)
                let charNameCard: String = "UI_AvatarIcon_\(charNameID)_Card"
                VStack(spacing: 0) {
                    EnkaWebIcon(iconString: charNameCard)
                        .scaledToFit()
                        .frame(width: 65)
                    Text("Lv.\(avatarData.level)")
                        .font(.footnote)
                }
                if avatarData.id != battleData.avatars.last!.id {
                    Spacer()
                }
            }
        }
    }
}

struct AbyssStarIcon: View {
    var body: some View {
        Image("star.abyss").resizable().scaledToFit()
    }
}
