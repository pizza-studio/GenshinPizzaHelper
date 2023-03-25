//
//  CharacterDetailDatasView.swift
//  GenshinPizzaHelper
//
//  Created by Bill Haku on 2022/9/24.
//

import SwiftUI

// MARK: - EachCharacterDetailDatasView

// @available(iOS 15, *)
struct EachCharacterDetailDatasView: View {
    var avatar: PlayerDetail.Avatar

    var animation: Namespace.ID

    var body: some View {
        let spacing: CGFloat = 4
        VStack {
            if #available(iOS 16, *) {
                Grid {
                    GridRow {
                        avatarIconAndSkill()
                            .padding(.bottom, spacing)
                    }
                    GridRow {
                        weapon()
                            .padding(.bottom, spacing)
                    }
                }
            } else {
                HStack {
                    avatarIconAndSkill()
                        .padding(.bottom, spacing)
                }
                HStack {
                    weapon()
                        .padding(.bottom, spacing)
                }
            }
            probView()
                .padding(.bottom, spacing)
            artifactsDetailsView()
        }
        .padding()
    }

    @ViewBuilder
    func artifactsDetailsView() -> some View {
        if !avatar.artifacts.isEmpty {
            if true { // 这行先不用清除掉，可以减少接下来的 macOS 适配时的 commit 熵。
                HStack {
                    ForEach(avatar.artifacts) { artifact in
                        VStack {
                            ZStack {
                                HomeSourceWebIcon(
                                    iconString: artifact
                                        .iconString
                                )
                            }
                            .frame(width: 60, height: 60)
                            .corneredTag(
                                "Lv.\(artifact.level) ☆\(artifact.rankLevel.rawValue)",
                                alignment: .bottom
                            )
                            VStack {
                                Text(artifact.mainAttribute.name)
                                    .font(.system(size: 11, weight: .bold))
                                Text("\(artifact.mainAttribute.valueString)")
                                    .font(.system(size: 16, weight: .heavy))
                                Spacer().frame(height: 6)
                            }
                            VStack {
                                ForEach(
                                    artifact.subAttributes,
                                    id: \.name
                                ) { subAttribute in
                                    Text(subAttribute.name)
                                        .font(.system(size: 11))
                                    Text("\(subAttribute.valueString)")
                                        .font(.system(size: 16, weight: .bold))
                                    Spacer().frame(height: 4)
                                }
                            }
                        }
                        .frame(maxWidth: UIScreen.main.bounds.size.width / 5)
                    }
                }
            }
        } else {
            EmptyView()
        }
    }

    @ViewBuilder
    func avatarIconAndSkill() -> some View {
        AvatarAndSkillView(avatar: avatar)
    }

    @ViewBuilder
    func weapon() -> some View {
        // Weapon
        let weapon = avatar.weapon
        let l: CGFloat = 80
        ZStack {
            EnkaWebIcon(
                iconString: weapon.rankLevel
                    .rectangularBackgroundIconString
            )
            .scaledToFit()
            .scaleEffect(1.1)
            .offset(y: 10)
            .clipShape(Circle())
            EnkaWebIcon(iconString: weapon.awakenedIconString)
                .scaledToFit()
        }
        .frame(height: l)
        .corneredTag(
            "Lv.\(weapon.level)",
            alignment: .bottomTrailing,
            textSize: 13
        )
        VStack(alignment: .leading, spacing: 3) {
            HStack(alignment: .firstTextBaseline) {
                Text(weapon.name)
                    .bold()
                    .font(.system(size: 22))
                    .fixedSize(horizontal: false, vertical: true)
                Spacer()
                Text("精炼\(weapon.refinementRank)阶")
                    .font(.system(size: 16))
                    .padding(.horizontal)
                    .background(
                        Capsule()
                            .fill(.gray)
                            .opacity(0.25)
                    )
            }
            .padding(.bottom, 2)
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
            }.font(.system(size: 18))
            if let subAttribute = weapon.subAttribute {
                HStack {
                    Text(subAttribute.name)
                    Spacer()
                    Text("\(subAttribute.valueString)")
                        .padding(.horizontal)
                        .background(
                            Capsule()
                                .fill(.gray)
                                .opacity(0.25)
                        )
                }.font(.system(size: 16))
            }
        }
        .frame(height: l)
    }

    @ViewBuilder
    func probView() -> some View {
        // Other prob
        let probRows = Group {
            AttributeLabel(
                iconString: "UI_Icon_MaxHp",
                name: "生命值上限",
                value: "\(avatar.fightPropMap.HP.rounded(toPlaces: 1))"
            )
            AttributeLabel(
                iconString: "UI_Icon_CurAttack",
                name: "攻击力",
                value: "\(avatar.fightPropMap.ATK.rounded(toPlaces: 1))"
            )
            AttributeLabel(
                iconString: "UI_Icon_CurDefense",
                name: "防御力",
                value: "\(avatar.fightPropMap.DEF.rounded(toPlaces: 1))"
            )
            AttributeLabel(
                iconString: "UI_Icon_Element",
                name: "元素精通",
                value: "\(avatar.fightPropMap.elementalMastery.rounded(toPlaces: 1))"
            )
            AttributeLabel(
                iconString: "UI_Icon_Intee_WindField_ClockwiseRotation",
                name: "元素充能效率",
                value: "\((avatar.fightPropMap.energyRecharge * 100).rounded(toPlaces: 2))%"
            )
            if avatar.fightPropMap.healingBonus > 0 {
                AttributeLabel(
                    iconString: "UI_Icon_Heal",
                    name: "治疗加成",
                    value: "\((avatar.fightPropMap.healingBonus * 100).rounded(toPlaces: 2))%"
                )
            }
            AttributeLabel(
                iconString: "UI_Icon_CriticalRate",
                name: "暴击率",
                value: "\((avatar.fightPropMap.criticalRate * 100).rounded(toPlaces: 2))%"
            )
            AttributeLabel(
                iconString: "UI_Icon_CriticalDamage",
                name: "暴击伤害",
                value: "\((avatar.fightPropMap.criticalDamage * 100.0).rounded(toPlaces: 2))%"
            )
            switch avatar.element {
            case .wind:
                AttributeLabel(
                    iconString: "UI_Icon_Element_Wind",
                    name: "风元素伤害加成",
                    value: "\((avatar.fightPropMap.anemoDamage * 100.0).rounded(toPlaces: 2))%"
                )
            case .ice:
                AttributeLabel(
                    iconString: "UI_Icon_Element_Ice",
                    name: "冰元素伤害加成",
                    value: "\((avatar.fightPropMap.cryoDamage * 100.0).rounded(toPlaces: 2))%"
                )
            case .electric:
                AttributeLabel(
                    iconString: "UI_Icon_Element_Electric",
                    name: "雷元素伤害加成",
                    value: "\((avatar.fightPropMap.electroDamage * 100.0).rounded(toPlaces: 2))%"
                )
            case .water:
                AttributeLabel(
                    iconString: "UI_Icon_Element_Water",
                    name: "水元素伤害加成",
                    value: "\((avatar.fightPropMap.hydroDamage * 100.0).rounded(toPlaces: 2))%"
                )
            case .fire:
                AttributeLabel(
                    iconString: "UI_Icon_Element_Fire",
                    name: "火元素伤害加成",
                    value: "\((avatar.fightPropMap.pyroDamage * 100.0).rounded(toPlaces: 2))%"
                )
            case .rock:
                AttributeLabel(
                    iconString: "UI_Icon_Element_Rock",
                    name: "岩元素伤害加成",
                    value: "\((avatar.fightPropMap.geoDamage * 100.0).rounded(toPlaces: 2))%"
                )
            case .grass:
                AttributeLabel(
                    iconString: "UI_Icon_Element_Grass",
                    name: "草元素伤害加成",
                    value: "\((avatar.fightPropMap.dendroDamage * 100.0).rounded(toPlaces: 2))%"
                )
            default:
                EmptyView()
            }
            if avatar.fightPropMap.physicalDamage > 0 {
                AttributeLabel(
                    iconString: "UI_Icon_PhysicalAttackUp",
                    name: "物理伤害加成",
                    value: "\((avatar.fightPropMap.physicalDamage * 100.0).rounded(toPlaces: 2))%"
                )
            }
        }.font(.system(size: 16))
        if #available(iOS 16, *) {
            Grid(verticalSpacing: 3) {
                probRows
            }
        } else {
            VStack(spacing: 3) {
                probRows
            }
        }
    }
}

// MARK: - AttributeLabel

// @available(iOS 15.0, *)
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
        if #available(iOS 15.0, *) {
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
            if #available(iOS 16.0, *) {
                GridRow {
                    image
                    HStack {
                        nameView
                        Spacer()
                        valueView
                    }
                }
                .frame(height: 20)
            } else {
                // Fallback on earlier versions
                HStack {
                    HStack {
                        image
                        nameView
                    }
                    Spacer()
                    valueView
                }
            }
        } else {
            // Fallback on earlier versions
            let valueView = Text(value)
                .foregroundColor(.primary)
                .padding(.horizontal)
                .background(
                    Capsule()
                        .frame(height: 20)
                        .frame(maxWidth: 200)
                        .opacity(0.25)
                )
            HStack {
                HStack {
                    image
                    nameView
                }
                Spacer()
                valueView
            }
        }
        if #available(iOS 16, *) {
        } else {}
    }
}

// MARK: - AvatarAndSkillView

// @available(iOS 15.0, *)
private struct AvatarAndSkillView: View {
    let avatar: PlayerDetail.Avatar

    var body: some View {
        EnkaWebIcon(iconString: avatar.iconString)
            .frame(width: 85, height: 85)
            .background(
                EnkaWebIcon(iconString: avatar.namecardIconString)
                    .scaledToFill()
                    .offset(x: -85 / 3)
            )
            .clipShape(Circle())
            .padding(.trailing, 3)
//            .matchedGeometryEffect(id: "character.\(avatar.name)", in: animation)
        HStack(alignment: .lastTextBaseline) {
            VStack(alignment: .leading, spacing: 6) {
                Text(avatar.name)
                    .font(.system(size: 25))
                    .bold()
                    .fixedSize(horizontal: false, vertical: true)
                    .minimumScaleFactor(0.5)
                    .lineLimit(2)
                VStack(spacing: 4) {
                    HStack {
                        Text("等级")
                        Spacer()
                        Text("\(avatar.level)")
                            .frame(minWidth: 42)
                            .padding(.horizontal, 4)
                            .background(
                                Capsule()
                                    .fill(.gray)
                                    .opacity(0.25)
                            )
                    }
                    HStack {
                        Text("命之座")
                        Spacer()
                        Text("\(avatar.talentCount)命")
                            .frame(minWidth: 42)
                            .padding(.horizontal, 4)
                            .background(
                                Capsule()
                                    .fill(.gray)
                                    .opacity(0.25)
                            )
                    }
                }
                .font(.system(size: 16))
            }
            if #available(iOS 16, *) {
                Grid(verticalSpacing: 1) {
                    GridRow {
                        ForEach(avatar.skills, id: \.self) { skill in
                            EnkaWebIcon(iconString: skill.iconString)
                        }
                    }
                    GridRow {
                        ForEach(avatar.skills, id: \.self) { skill in
                            VStack(spacing: 0) {
                                skill.levelDisplay
                            }
                        }
                    }
                }
            } else {
                HStack {
                    ForEach(avatar.skills, id: \.self) { skill in
                        VStack(spacing: 0) {
                            Spacer()
                            EnkaWebIcon(iconString: skill.iconString)
                            skill.levelDisplay
                            Spacer()
                        }
                    }
                }
            }
        }
        .frame(height: 85)
    }
}

// MARK: - Trailing Text Label

extension View {
    fileprivate func corneredTag(
        _ string: String,
        alignment: Alignment,
        textSize: CGFloat = 11,
        opacity: CGFloat = 1,
        enabled: Bool = true
    )
        -> some View {
        if #available(macCatalyst 15.0, iOS 15.0, *) {
            return overlay(alignment: alignment) {
                Text(enabled ? string : "")
                    .font(.system(size: textSize))
                    .padding(.horizontal, 3)
                    .background(
                        Capsule()
                            .foregroundStyle(.ultraThinMaterial)
                            .opacity(enabled ? 0.7 : 0)
                    )
                    .opacity(opacity)
            }
        } else {
            return EmptyView()
        }
    }
}

// MARK: - Artifact Extension (SwiftUI)

extension PlayerDetail.Avatar.Artifact {
    var rankedBackgroundColor: Color {
        switch rankLevel {
        case .five: return .orange
        case .four: return .purple
        case .three: return .blue
        default: return .clear
        }
    }
}

// MARK: - Skill Extension (SwiftUI)

extension PlayerDetail.Avatar.Skill {
    var isLevelAdjusted: Bool {
        levelAdjusted != level
    }

    var levelDisplay: some View {
        HStack(alignment: .center, spacing: 1) {
            Text("\(level)").font(.system(size: 14, weight: .black))
            if isLevelAdjusted {
                Text("+\(levelAdjusted - level)")
                    .font(.system(size: 12, weight: .heavy))
            }
        }
    }
}
