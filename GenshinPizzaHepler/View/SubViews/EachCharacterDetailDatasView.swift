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

    var animation: Namespace.ID

    var body: some View {
        VStack {
            if #available(iOS 16, *) {
                Grid {
                    GridRow {
                        avatarIconAndSkill()
                            .padding(.bottom)
                    }
                    GridRow {
                        weapon()
                            .padding(.bottom)
                    }
                }
            } else {
                HStack {
                    avatarIconAndSkill()
                        .padding(.bottom)
                }
                HStack {
                    weapon()
                        .padding(.bottom)
                }
            }

            // Other prob
            VStack(spacing: 3) {
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
                                    .bold()
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
                                        .font(.callout)
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
                                        .font(.footnote)
                                    Text("\(subAttribute.valueString)")
                                        .font(.footnote)
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

    @ViewBuilder
    func avatarIconAndSkill() -> some View {
        EnkaWebIcon(iconString: avatar.iconString)
            .frame(width: 85, height: 85)
            .background(EnkaWebIcon(iconString: avatar.namecardIconString)
                .scaledToFill()
                .offset(x: -85/3))
            .clipShape(Circle())
            .padding(.trailing, 3)
            .matchedGeometryEffect(id: "character.\(avatar.name)", in: animation)
        HStack(alignment: .bottom) {
            VStack(alignment: .leading) {
                let name = avatar.name.count > 10 ? avatar.name.replacingOccurrences(of: " ", with: "\n") : avatar.name
                Text(name)
                    .font(.title2)
                    .bold()
                    .lineLimit(2)
                    .fixedSize()
                    .padding(.top)
                Spacer()
                VStack(spacing: 2) {
                    HStack {
                        Text("等级")
                        Spacer()
                        Text("\(avatar.level)")
                            .padding(.horizontal)
                            .background(
                                Capsule()
                                    .fill(.gray)
                                    .opacity(0.25)
                            )
                    }.font(.footnote)
                    HStack {
                        Text("命之座")
                        Spacer()
                        Text("\(avatar.talentCount)命")
                            .padding(.horizontal)
                            .background(
                                Capsule()
                                    .fill(.gray)
                                    .opacity(0.25)
                            )
                    }.font(.footnote)
                }
                .padding(.bottom)
            }
            .frame(height: 85)
            .padding(.trailing, 3)
            Spacer()
            if #available(iOS 16, *) {
                Grid(verticalSpacing: 1) {
                    GridRow {
                        ForEach(avatar.skills, id: \.iconString) { skill in
                            VStack(spacing: 0) {
                                EnkaWebIcon(iconString: skill.iconString)
                                    .padding(.bottom, 0)
                            }
                        }
                    }
                    GridRow {
                        ForEach(avatar.skills, id: \.iconString) { skill in
                            VStack(spacing: 0) {
                                Text("\(skill.level)").font(.caption)
                            }
                        }
                    }
                }
                .frame(height: 60)
                .padding(.bottom, 10)
            } else {
                HStack {
                    ForEach(avatar.skills, id: \.iconString) { skill in
                        VStack(spacing: 0) {
                            EnkaWebIcon(iconString: skill.iconString)
                                .padding(.bottom, 0)
                            Text("\(skill.level)").font(.caption)
                        }
                    }
                }
                .frame(height: 60)
                .padding(.bottom, 10)
            }

        }
    }

    @ViewBuilder
    func weapon() -> some View {
        // Weapon
        let weapon = avatar.weapon
        let l: CGFloat = 85
        ZStack {
            EnkaWebIcon(iconString: weapon.rankLevel.rectangularBackgroundIconString)
                .scaledToFit()
                .scaleEffect(1.1)
                .offset(y: 10)
                .clipShape(Circle())
            EnkaWebIcon(iconString: weapon.awakenedIconString)
                .scaledToFit()
        }
        .frame(height: l)
        VStack(alignment: .leading, spacing: 3) {
            HStack(alignment: .lastTextBaseline) {
                Text(weapon.name).bold()
                    .font(.headline)
                Spacer()
                Text("精炼\(weapon.refinementRank)阶")
                    .font(.caption)
                    .padding(.horizontal)
                    .background(
                        Capsule()
                            .fill(.gray)
                            .opacity(0.25)
                    )
            }
            Spacer()
            HStack {
                Text(weapon.mainAttribute.name)
                Spacer()
                Text("\(avatar.weapon.mainAttribute.valueString)")
                    .padding(.horizontal)
                    .background(
                        Capsule()
                            .fill(.gray)
                            .opacity(0.25)
                    )
            }.font(.callout)
            HStack {
                Text(weapon.subAttribute.name)
                Spacer()
                Text("\(avatar.weapon.subAttribute.valueString)")
                    .padding(.horizontal)
                    .background(
                        Capsule()
                            .fill(.gray)
                            .opacity(0.25)
                    )
            }.font(.footnote)
        }
        .padding(.vertical)
        .frame(height: l)
    }
}
