//
//  CharacterDetailDatasView.swift
//  GenshinPizzaHelper
//
//  Created by Bill Haku on 2022/9/24.
//

import SwiftUI

@available(iOS 15, *)
struct EachCharacterDetailDatasView: View {
    var avatar: PlayerDetail.Avatar

    var body: some View {
        VStack {
            HStack(alignment: .center) {
                HStack {
                    EnkaWebIcon(iconString: avatar.iconString)
                        .frame(width: 85, height: 85)
                        .background(EnkaWebIcon(iconString: avatar.namecardIconString)
                            .scaledToFill())
                        .clipShape(Circle())
                        .padding(.trailing, 3)
                    VStack(alignment: .leading) {
                        let name = avatar.name.count > 10 ? avatar.name.replacingOccurrences(of: " ", with: "\n") : avatar.name
                        Text(name)
                            .font(.title2)
                            .bold()
                            .padding(.bottom, 2)
                            .lineLimit(2)
                            .fixedSize()
                        Text("等级：\(avatar.level)").font(.footnote)
                        Text("命之座：\(avatar.talentCount)命").font(.footnote)
                    }
                }
                Spacer()
                HStack {
                    ForEach(avatar.skills, id: \.iconString) { skill in
                        VStack(spacing: 0) {
                            EnkaWebIcon(iconString: skill.iconString)
                                .padding(.bottom, 0)
                            Text("\(skill.level)")
                        }
                    }
                }
                .frame(height: 60)
            }
            .padding(.bottom, 10)

            // Weapon
            HStack {
                let weapon = avatar.weapon
                let l: CGFloat = 85
                let r = l/2
                let squareSideLength = sqrt(2) * Double(r) * 0.9
                ZStack {
                    EnkaWebIcon(iconString: weapon.rankLevel.rectangularBackgroundIconString)
                        .scaledToFit()
                    EnkaWebIcon(iconString: weapon.awakenedIconString)
                        .scaledToFit()
                        .frame(width: squareSideLength, height: squareSideLength)

                }
                .clipShape(Circle())
                .frame(width: l, height: l)
                VStack(alignment: .leading) {
                    HStack {
                        Text(weapon.name).bold().font(.headline)
                        Spacer()
                        Text("精炼\(weapon.refinementRank)阶")
                            .padding(.horizontal)
                            .background(
                                Capsule()
                                    .fill(.gray)
                                    .opacity(0.25)
                            )
                    }
                    .padding(.bottom, 0.5)
                    InfoPreviewer(title: "等级", content: "\(avatar.weapon.level)", contentStyle: .capsule, textColor: .primary, backgroundColor: .gray)
                    InfoPreviewer(title: weapon.mainAttribute.name, content: "\(avatar.weapon.mainAttribute.valueString)", contentStyle: .capsule, textColor: .primary, backgroundColor: .gray)
                    InfoPreviewer(title: weapon.subAttribute.name, content: "\(avatar.weapon.subAttribute.valueString)", contentStyle: .capsule, textColor: .primary, backgroundColor: .gray)
                }
            }
            Divider()

            // Other prob
            Group {
                InfoPreviewer(title: "生命值", content: "\(avatar.fightPropMap.HP.rounded(toPlaces: 1))", contentStyle: .capsule, textColor: .primary, backgroundColor: .gray)
                InfoPreviewer(title: "攻击力", content: "\(avatar.fightPropMap.ATK.rounded(toPlaces: 1))", contentStyle: .capsule, textColor: .primary, backgroundColor: .gray)
                InfoPreviewer(title: "防御力", content: "\(avatar.fightPropMap.DEF.rounded(toPlaces: 1))", contentStyle: .capsule, textColor: .primary, backgroundColor: .gray)
                InfoPreviewer(title: "元素精通", content: "\(avatar.fightPropMap.elementalMastery.rounded(toPlaces: 1))", contentStyle: .capsule, textColor: .primary, backgroundColor: .gray)
                InfoPreviewer(title: "元素充能效率", content: "\((avatar.fightPropMap.energyRecharge * 100).rounded(toPlaces: 2))%", contentStyle: .capsule, textColor: .primary, backgroundColor: .gray)
                if avatar.fightPropMap.healingBonus > 0 {
                    InfoPreviewer(title: "治疗加成", content: "\((avatar.fightPropMap.healingBonus * 100).rounded(toPlaces: 2))%", contentStyle: .capsule, textColor: .primary, backgroundColor: .gray)
                }
                InfoPreviewer(title: "暴击率", content: "\((avatar.fightPropMap.criticalRate * 100).rounded(toPlaces: 2))%", contentStyle: .capsule, textColor: .primary, backgroundColor: .gray)
                InfoPreviewer(title: "暴击伤害", content: "\((avatar.fightPropMap.criticalDamage * 100.0).rounded(toPlaces: 2))%", contentStyle: .capsule, textColor: .primary, backgroundColor: .gray)
            }
            switch avatar.element {
            case .wind:
                InfoPreviewer(title: "风元素伤害加成", content: "\((avatar.fightPropMap.anemoDamage * 100.0).rounded(toPlaces: 2))%", contentStyle: .capsule, textColor: .primary, backgroundColor: .gray)
            case .ice:
                InfoPreviewer(title: "冰元素伤害加成", content: "\((avatar.fightPropMap.cryoDamage * 100.0).rounded(toPlaces: 2))%", contentStyle: .capsule, textColor: .primary, backgroundColor: .gray)
            case .electric:
                InfoPreviewer(title: "雷元素伤害加成", content: "\((avatar.fightPropMap.electroDamage * 100.0).rounded(toPlaces: 2))%", contentStyle: .capsule, textColor: .primary, backgroundColor: .gray)
            case .water:
                InfoPreviewer(title: "水元素伤害加成", content: "\((avatar.fightPropMap.hydroDamage * 100.0).rounded(toPlaces: 2))%", contentStyle: .capsule, textColor: .primary, backgroundColor: .gray)
            case .fire:
                InfoPreviewer(title: "火元素伤害加成", content: "\((avatar.fightPropMap.pyroDamage * 100.0).rounded(toPlaces: 2))%", contentStyle: .capsule, textColor: .primary, backgroundColor: .gray)
            case .rock:
                InfoPreviewer(title: "岩元素伤害加成", content: "\((avatar.fightPropMap.geoDamage * 100.0).rounded(toPlaces: 2))%", contentStyle: .capsule, textColor: .primary, backgroundColor: .gray)
            case .grass:
                InfoPreviewer(title: "草元素伤害加成", content: "\((avatar.fightPropMap.dendroDamage * 100.0).rounded(toPlaces: 2))%", contentStyle: .capsule, textColor: .primary, backgroundColor: .gray)
            default:
                EmptyView()
            }
            if avatar.fightPropMap.physicalDamage > 0 {
                InfoPreviewer(title: "物理伤害加成", content: "\((avatar.fightPropMap.physicalDamage * 100.0).rounded(toPlaces: 2))%", contentStyle: .capsule, textColor: .primary, backgroundColor: .gray)
            }
            artifactsDetailsView()
        }
        .padding()
    }

    @ViewBuilder
    func artifactsDetailsView() -> some View {
        if !avatar.artifacts.isEmpty {
            if #available(iOS 16, *) {
                Divider()
                Grid {
                    GridRow {
                        ForEach(avatar.artifacts) { artifact in
                            EnkaWebIcon(iconString: artifact.iconString)
                        }
                    }
                    GridRow {
                        ForEach(avatar.artifacts) { artifact in
                            VStack {
                                Text(artifact.mainAttribute.name)
                                    .font(.caption)
                                Text("\(artifact.mainAttribute.valueString)")
                                    .bold()
                            }
                        }
                    }
                    GridRow {
                        ForEach(avatar.artifacts) { artifact in
                            VStack {
                                ForEach(artifact.subAttributes, id:\.name) { subAttribute in
                                    Text(subAttribute.name)
                                        .font(.caption)
                                    Text("\(subAttribute.valueString)")
                                }
                            }
                        }
                    }
                }
            } else {
                Divider()
                HStack {
                    ForEach(avatar.artifacts) { artifact in
                        VStack {
                            EnkaWebIcon(iconString: artifact.iconString)
                            VStack {
                                Text(artifact.mainAttribute.name)
                                    .font(.caption)
                                Text("\(artifact.mainAttribute.valueString)")
                                    .bold()
                            }
                            VStack {
                                ForEach(artifact.subAttributes, id:\.name) { subAttribute in
                                    Text(subAttribute.name)
                                        .font(.caption)
                                    Text("\(subAttribute.valueString)")
                                }
                            }
                        }
                    }

                }
            }
        } else {
            EmptyView()
        }
    }
}
