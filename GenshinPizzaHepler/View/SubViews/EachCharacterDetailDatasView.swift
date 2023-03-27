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
        HStack(alignment: .top, spacing: 8) {
//            if [.pad, .mac].contains(UIDevice.current.userInterfaceIdiom) {
//                VStack(spacing: 4) {
//                    avatarIconAndSkill()
//                    VStack(alignment: .leading) {
//                        artifactsDetailsView()
//                    }
//                }
//                VStack(spacing: 4) {
//                    probView()
//                    weapon()
//                }
//            } 上述内容回头再弄
            VStack(spacing: 4) {
                avatarIconAndSkill()
                weapon()
                Divider()
                probView()
                HStack(alignment: .top, spacing: 0) {
                    artifactsDetailsView()
                }
            }
        }.padding()
    }

    @ViewBuilder
    func artifactsDetailsView() -> some View {
        ArtifactDetailView(avatar.artifacts)
    }

    @ViewBuilder
    func avatarIconAndSkill() -> some View {
        AvatarAndSkillView(avatar: avatar)
    }

    @ViewBuilder
    func weapon() -> some View {
        HStack(alignment: .center, spacing: 12) {
            // Weapon
            let weapon = avatar.weapon
            let l: CGFloat = 70
            ZStack {
                EnkaWebIcon(
                    iconString: weapon.rankLevel
                        .rectangularBackgroundIconString
                )
                .scaledToFit()
                .scaleEffect(1.4)
                .offset(y: 10)
                .clipShape(Circle())
                EnkaWebIcon(iconString: weapon.awakenedIconString)
                    .scaledToFit()
            }
            .frame(height: l)
            .corneredTag(
                "Lv.\(weapon.level)",
                alignment: .bottom,
                textSize: 13
            )
            VStack(alignment: .leading, spacing: 1) {
                HStack(alignment: .firstTextBaseline) {
                    Text(weapon.nameCorrected)
                        .font(.system(size: 15, weight: .heavy))
                        .fixedSize(horizontal: false, vertical: true)
                        .minimumScaleFactor(0.5)
                        .lineLimit(1)
                    Spacer()
                    Text("精炼\(weapon.refinementRank)阶")
                        .font(.system(size: 15))
                        .padding(.horizontal)
                        .background(
                            Capsule()
                                .fill(.gray)
                                .opacity(0.25)
                        )
                }
                .padding(.bottom, 2)
                HStack {
                    Text(
                        weapon.mainAttribute.name
                            .convertPercentageMarkToUpMark
                    )
                    Spacer()
                    Text("\(avatar.weapon.mainAttribute.valueString)")
                        .padding(.horizontal)
                        .background(
                            Capsule()
                                .fill(.gray)
                                .opacity(0.25)
                        )
                }.font(.system(size: 15))
                if let subAttribute = weapon.subAttribute {
                    HStack {
                        Text(subAttribute.name.convertPercentageMarkToUpMark)
                        Spacer()
                        Text("\(subAttribute.valueString)")
                            .padding(.horizontal)
                            .background(
                                Capsule()
                                    .fill(.gray)
                                    .opacity(0.25)
                            )
                    }.font(.system(size: 15))
                }
            }
        }
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
            case .anemo:
                AttributeLabel(
                    iconString: "UI_Icon_Element_Wind",
                    name: "风元素伤害加成",
                    value: "\((avatar.fightPropMap.anemoDamage * 100.0).rounded(toPlaces: 2))%"
                )
            case .cryo:
                AttributeLabel(
                    iconString: "UI_Icon_Element_Ice",
                    name: "冰元素伤害加成",
                    value: "\((avatar.fightPropMap.cryoDamage * 100.0).rounded(toPlaces: 2))%"
                )
            case .electro:
                AttributeLabel(
                    iconString: "UI_Icon_Element_Electric",
                    name: "雷元素伤害加成",
                    value: "\((avatar.fightPropMap.electroDamage * 100.0).rounded(toPlaces: 2))%"
                )
            case .hydro:
                AttributeLabel(
                    iconString: "UI_Icon_Element_Water",
                    name: "水元素伤害加成",
                    value: "\((avatar.fightPropMap.hydroDamage * 100.0).rounded(toPlaces: 2))%"
                )
            case .pyro:
                AttributeLabel(
                    iconString: "UI_Icon_Element_Fire",
                    name: "火元素伤害加成",
                    value: "\((avatar.fightPropMap.pyroDamage * 100.0).rounded(toPlaces: 2))%"
                )
            case .geo:
                AttributeLabel(
                    iconString: "UI_Icon_Element_Rock",
                    name: "岩元素伤害加成",
                    value: "\((avatar.fightPropMap.geoDamage * 100.0).rounded(toPlaces: 2))%"
                )
            case .dendro:
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
        }.font(.system(size: 15))
        if #available(iOS 16, *) {
            Grid(verticalSpacing: 1) {
                probRows
            }
        } else {
            VStack(spacing: 1) {
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

// MARK: - ArtifactDetailView

// @available(iOS 15.0, *)
internal struct ArtifactDetailView: View {
    // MARK: Lifecycle

    public init(_ artifacts: [PlayerDetail.Avatar.Artifact]) {
        self.artifacts = artifacts
    }

    // MARK: Internal

    var body: some View {
        ForEach(artifacts) { artifact in
            // if [.pad, .mac].contains(UIDevice.current.userInterfaceIdiom) 回头再弄
            VStack(spacing: 4) {
                perArtifactDetailView(artifact)
            }
            .frame(maxWidth: UIScreen.main.bounds.size.width / 5)
        }
    }

    @ViewBuilder
    func perArtifactDetailView(
        _ artifact: PlayerDetail.Avatar
            .Artifact
    )
        -> some View {
        ZStack {
            HomeSourceWebIcon(
                iconString: artifact
                    .iconString
            )
        }
        .frame(width: 60, height: 60)
        .corneredTag(
            "Lv.\(artifact.level) ☆\(artifact.rankLevel.rawValue)",
            alignment: .bottom,
            enabled: showRarityAndLevelForArtifacts
        )
        VStack(spacing: 0) {
            Text(artifact.mainAttribute.name.convertPercentageMarkToUpMark)
                .font(.system(size: 11, weight: .bold))
            Text("\(artifact.mainAttribute.valueString)")
                .font(.system(size: 16, weight: .heavy))
        }
        ForEach(
            artifact.subAttributes,
            id: \.name
        ) { subAttribute in
            VStack(spacing: 0) {
                Text(subAttribute.name.convertPercentageMarkToUpMark)
                    .font(.system(size: 11))
                Text("\(subAttribute.valueString)")
                    .font(.system(size: 16, weight: .bold))
            }
        }
    }

    // MARK: Private

    @AppStorage(
        "showRarityAndLevelForArtifacts",
        store: UserDefaults(suiteName: "group.GenshinPizzaHelper")
    )
    private var showRarityAndLevelForArtifacts: Bool = true
    private let artifacts: [PlayerDetail.Avatar.Artifact]
}

// MARK: - AvatarAndSkillView

// @available(iOS 15.0, *)
private struct AvatarAndSkillView: View {
    let avatar: PlayerDetail.Avatar

    var hasNotch: Bool {
        guard let scene = UIApplication.shared.connectedScenes.first,
              let windowSceneDelegate = scene
              .delegate as? UIWindowSceneDelegate,
              let window = windowSceneDelegate.window else {
            return false
        }

        return window?.safeAreaInsets.top ?? 0 > 20
    }

    var body: some View {
        HStack(alignment: .bottom) {
            EnkaWebIcon(iconString: avatar.iconString)
                .frame(width: 85, height: 85)
                .background(
                    EnkaWebIcon(iconString: avatar.namecardIconString)
                        .scaledToFill()
                        .offset(x: -85 / 3)
                )
                .clipShape(Circle())
                .padding(.trailing, 3)
            VStack(alignment: .leading, spacing: 2) {
                HStack(alignment: .bottom) {
                    Text(avatar.nameCorrected)
                        .font(.system(size: 23, weight: .black))
                        .fixedSize(horizontal: false, vertical: true)
                        .minimumScaleFactor(0.5)
                        .lineLimit(1)
                    if !hasNotch {
                        Spacer().frame(width: 24)
                    }
                }
                HStack(alignment: .center) {
                    VStack(alignment: .leading, spacing: 1) {
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
                    .font(.system(size: 15))
                    HStack(alignment: .lastTextBaseline, spacing: 2) {
                        ForEach(avatar.skills, id: \.self) { skill in
                            VStack(spacing: 0) {
                                EnkaWebIcon(iconString: skill.iconString)
                                skill.levelDisplay
                            }
                        }
                    }.frame(width: 120)
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
        guard !string.isEmpty else { return EmptyView() }
        if #available(macCatalyst 15.0, iOS 15.0, *) {
            return overlay(alignment: alignment) {
                Text(enabled ? string : "")
                    .font(.system(size: textSize, weight: .medium))
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

// MARK: - Convert trailing percentage mark into a rised arrow mark.

extension String {
    fileprivate var convertPercentageMarkToUpMark: String {
        guard let last = last, ["％", "%"].contains(last) else {
            return self
        }
        return dropLast(1).description
    }
}
