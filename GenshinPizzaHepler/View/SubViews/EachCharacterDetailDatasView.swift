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
                            .padding(.bottom, 10)
                    }
                    GridRow {
                        weapon()
                            .padding(.bottom, 6)
                    }
                }
            } else {
                HStack {
                    avatarIconAndSkill()
                        .padding(.bottom, 10)
                }
                HStack {
                    weapon()
                        .padding(.bottom, 6)
                }
            }

            // Other prob
            let probRows = Group {
                AttributeLabel(iconString: "UI_Icon_MaxHp", name: "生命值", value: "\(avatar.fightPropMap.HP.rounded(toPlaces: 1))")
                AttributeLabel(iconString: "UI_Icon_CurAttack", name: "攻击力", value: "\(avatar.fightPropMap.ATK.rounded(toPlaces: 1))")
                AttributeLabel(iconString: "UI_Icon_CurDefense", name: "防御力", value: "\(avatar.fightPropMap.DEF.rounded(toPlaces: 1))")
                AttributeLabel(iconString: "UI_Icon_Element", name: "元素精通", value: "\(avatar.fightPropMap.elementalMastery.rounded(toPlaces: 1))")
                AttributeLabel(iconString: "UI_Icon_Intee_WindField_ClockwiseRotation", name: "元素充能效率", value: "\((avatar.fightPropMap.energyRecharge * 100).rounded(toPlaces: 2))%")
                if avatar.fightPropMap.healingBonus > 0 {
                    AttributeLabel(iconString: "UI_Icon_Heal", name: "治疗加成", value: "\((avatar.fightPropMap.healingBonus * 100).rounded(toPlaces: 2))%")
                }
                AttributeLabel(iconString: "UI_Icon_Critical", name: "暴击率", value: "\((avatar.fightPropMap.criticalRate * 100).rounded(toPlaces: 2))%")
                AttributeLabel(iconString: "UI_Icon_Critical", name: "暴击伤害", value: "\((avatar.fightPropMap.criticalDamage * 100.0).rounded(toPlaces: 2))%")
                switch avatar.element {
                case .wind:
                    AttributeLabel(iconString: "UI_Icon_Element_Wind", name: "风元素伤害加成", value: "\((avatar.fightPropMap.anemoDamage * 100.0).rounded(toPlaces: 2))%")
                case .ice:
                    AttributeLabel(iconString: "UI_Icon_Element_Ice", name: "冰元素伤害加成", value: "\((avatar.fightPropMap.cryoDamage * 100.0).rounded(toPlaces: 2))%")
                case .electric:
                    AttributeLabel(iconString: "UI_Icon_Element_Electric", name: "雷元素伤害加成", value: "\((avatar.fightPropMap.electroDamage * 100.0).rounded(toPlaces: 2))%")
                case .water:
                    AttributeLabel(iconString: "UI_Icon_Element_Water", name: "水元素伤害加成", value: "\((avatar.fightPropMap.hydroDamage * 100.0).rounded(toPlaces: 2))%")
                case .fire:
                    AttributeLabel(iconString: "UI_Icon_Element_Fire", name: "火元素伤害加成", value: "\((avatar.fightPropMap.pyroDamage * 100.0).rounded(toPlaces: 2))%")
                case .rock:
                    AttributeLabel(iconString: "UI_Icon_Element_Rock", name: "岩元素伤害加成", value: "\((avatar.fightPropMap.geoDamage * 100.0).rounded(toPlaces: 2))%")
                case .grass:
                    AttributeLabel(iconString: "UI_Icon_Element_Grass", name: "草元素伤害加成", value: "\((avatar.fightPropMap.dendroDamage * 100.0).rounded(toPlaces: 2))%")
                default:
                    EmptyView()
                }
                if avatar.fightPropMap.physicalDamage > 0 {
                    AttributeLabel(iconString: "UI_Icon_PhysicalAttackUp", name: "物理伤害加成", value: "\((avatar.fightPropMap.physicalDamage * 100.0).rounded(toPlaces: 2))%")
                }
            }
            if #available(iOS 16, *) {
                Grid(verticalSpacing: 3) {
                    probRows
                }
                .padding(.bottom, 10)
            } else {
                VStack(spacing: 3) {
                    probRows
                }
                .padding(.bottom, 10)
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
                            HomeSourceWebIcon(iconString: artifact.iconString)
                                .frame(maxWidth: 60, maxHeight: 60)
                            if artifact != avatar.artifacts.last {
                                Spacer()
                            }
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
                            if artifact != avatar.artifacts.last {
                                Spacer()
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
                            if artifact != avatar.artifacts.last {
                                Spacer()
                            }
                        }
                    }
                }
            } else {
                Divider()
                HStack {
                    ForEach(avatar.artifacts) { artifact in
                        VStack {
                            HomeSourceWebIcon(iconString: artifact.iconString)
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

@available(iOS 15.0, *)
struct AttributeLabel: View {
    let iconString: String
    let name: String
    let value: String

    let textColor: Color = .white
    let backgroundColor: Color = .white

    var body: some View {
        let image = Image(iconString)
            .resizable()
            .scaledToFit()
            .padding(.vertical, 1)
            .padding(.leading, 3)
        let nameView = Text(LocalizedStringKey(name))
        let valueView = Text(value)
            .foregroundColor(.primary)
            .padding(.horizontal)
            .background(
                Capsule()
                    .foregroundStyle(.gray)
                    .frame(height: 20)
                    .frame(maxWidth: 200)
                    .opacity(0.25)
            )
        if #available(iOS 16, *) {
            GridRow {
                image
                HStack {
                    nameView
                    Spacer()
                    valueView
                }
            }
//            GridRow {
//                Spacer()
//                nameView
//                image
//                valueView
//                Spacer()
//            }
            .frame(height: 20)
        } else {
            HStack {
                HStack {
                    image
                    nameView
                }
                Spacer()
                valueView
            }
        }
    }
}
