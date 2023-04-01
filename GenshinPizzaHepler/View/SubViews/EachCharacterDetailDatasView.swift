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
    // MARK: Internal

    static var spacingDelta: CGFloat {
        guard AppConfig.adaptiveSpacingInCharacterView else { return 0 }
        return ThisDevice.notchType != .none || ThisDevice.isPad ? 4 : 0
    }

    var avatar: PlayerDetail.Avatar

    var animation: Namespace.ID

    var body: some View {
        HStack(alignment: .top, spacing: 0) {
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
            VStack(spacing: 4 + Self.spacingDelta) {
                avatarIconAndSkill()
                weapon(fontSize: 15)
                Divider()
                probView(fontSize: 15)
                HStack(alignment: .top, spacing: Self.spacingDelta) {
                    artifactsDetailsView()
                }
            }
        }.padding()
    }

    @ViewBuilder
    func artifactsDetailsView() -> some View {
        ArtifactDetailView(avatar.artifacts).frame(maxWidth: .infinity)
    }

    @ViewBuilder
    func avatarIconAndSkill() -> some View {
        AvatarAndSkillView(avatar: avatar)
    }

    @ViewBuilder
    func weapon(fontSize: CGFloat = 15) -> some View {
        HStack(alignment: .center, spacing: 12) {
            // Weapon
            let weapon = avatar.weapon
            let maxHeight: CGFloat = 70
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
            .frame(width: maxHeight, height: maxHeight)
            .corneredTag(
                "Lv.\(weapon.level)",
                alignment: .bottom,
                textSize: ceil(fontSize * 0.86)
            )
            VStack(alignment: .leading, spacing: 2 + Self.spacingDelta) {
                AttributeLabel(
                    name: weapon.nameCorrected,
                    valueView: Text("精炼\(weapon.refinementRank)阶"),
                    fontSize: fontSize,
                    titleEmphasized: true
                )
                .padding(.bottom, 2)
                AttributeLabel(
                    name: weapon.mainAttribute.name
                        .convertPercentageMarkToUpMark,
                    value: avatar.weapon.mainAttribute.valueString,
                    fontSize: fontSize
                )
                if let subAttribute = weapon.subAttribute {
                    AttributeLabel(
                        name: subAttribute.name.convertPercentageMarkToUpMark,
                        value: subAttribute.valueString,
                        fontSize: fontSize
                    )
                }
            }
        }
    }

    @ViewBuilder
    func probView(fontSize: CGFloat = 15) -> some View {
        // Other prob
        let probRows = Group {
            AttributeLabel(
                iconString: "UI_Icon_MaxHp",
                name: "生命值上限",
                value: "\(avatar.fightPropMap.HP.rounded(toPlaces: 1))",
                fontSize: fontSize
            )
            AttributeLabel(
                iconString: "UI_Icon_CurAttack",
                name: "攻击力",
                value: "\(avatar.fightPropMap.ATK.rounded(toPlaces: 1))",
                fontSize: fontSize
            )
            AttributeLabel(
                iconString: "UI_Icon_CurDefense",
                name: "防御力",
                value: "\(avatar.fightPropMap.DEF.rounded(toPlaces: 1))",
                fontSize: fontSize
            )
            AttributeLabel(
                iconString: "UI_Icon_Element",
                name: "元素精通",
                value: "\(avatar.fightPropMap.elementalMastery.rounded(toPlaces: 1))",
                fontSize: fontSize
            )
            AttributeLabel(
                iconString: "UI_Icon_Intee_WindField_ClockwiseRotation",
                name: "元素充能效率",
                value: "\((avatar.fightPropMap.energyRecharge * 100).rounded(toPlaces: 2))%",
                fontSize: fontSize
            )
            if avatar.fightPropMap.healingBonus > 0 {
                AttributeLabel(
                    iconString: "UI_Icon_Heal",
                    name: "治疗加成",
                    value: "\((avatar.fightPropMap.healingBonus * 100).rounded(toPlaces: 2))%",
                    fontSize: fontSize
                )
            }
            AttributeLabel(
                iconString: "UI_Icon_CriticalRate",
                name: "暴击率",
                value: "\((avatar.fightPropMap.criticalRate * 100).rounded(toPlaces: 2))%",
                fontSize: fontSize
            )
            AttributeLabel(
                iconString: "UI_Icon_CriticalDamage",
                name: "暴击伤害",
                value: "\((avatar.fightPropMap.criticalDamage * 100.0).rounded(toPlaces: 2))%",
                fontSize: fontSize
            )
            switch avatar.element {
            case .anemo:
                AttributeLabel(
                    iconString: "UI_Icon_Element_Wind",
                    name: "风元素伤害加成",
                    value: "\((avatar.fightPropMap.anemoDamage * 100.0).rounded(toPlaces: 2))%",
                    fontSize: fontSize
                )
            case .cryo:
                AttributeLabel(
                    iconString: "UI_Icon_Element_Ice",
                    name: "冰元素伤害加成",
                    value: "\((avatar.fightPropMap.cryoDamage * 100.0).rounded(toPlaces: 2))%",
                    fontSize: fontSize
                )
            case .electro:
                AttributeLabel(
                    iconString: "UI_Icon_Element_Electric",
                    name: "雷元素伤害加成",
                    value: "\((avatar.fightPropMap.electroDamage * 100.0).rounded(toPlaces: 2))%",
                    fontSize: fontSize
                )
            case .hydro:
                AttributeLabel(
                    iconString: "UI_Icon_Element_Water",
                    name: "水元素伤害加成",
                    value: "\((avatar.fightPropMap.hydroDamage * 100.0).rounded(toPlaces: 2))%",
                    fontSize: fontSize
                )
            case .pyro:
                AttributeLabel(
                    iconString: "UI_Icon_Element_Fire",
                    name: "火元素伤害加成",
                    value: "\((avatar.fightPropMap.pyroDamage * 100.0).rounded(toPlaces: 2))%",
                    fontSize: fontSize
                )
            case .geo:
                AttributeLabel(
                    iconString: "UI_Icon_Element_Rock",
                    name: "岩元素伤害加成",
                    value: "\((avatar.fightPropMap.geoDamage * 100.0).rounded(toPlaces: 2))%",
                    fontSize: fontSize
                )
            case .dendro:
                AttributeLabel(
                    iconString: "UI_Icon_Element_Grass",
                    name: "草元素伤害加成",
                    value: "\((avatar.fightPropMap.dendroDamage * 100.0).rounded(toPlaces: 2))%",
                    fontSize: fontSize
                )
            default:
                EmptyView()
            }
            if avatar.fightPropMap.physicalDamage > 0 {
                AttributeLabel(
                    iconString: "UI_Icon_PhysicalAttackUp",
                    name: "物理伤害加成",
                    value: "\((avatar.fightPropMap.physicalDamage * 100.0).rounded(toPlaces: 2))%",
                    fontSize: fontSize
                )
            }
        }
        if #available(iOS 16, *) {
            Grid(verticalSpacing: 2 + Self.spacingDelta) {
                probRows
            }
        } else {
            VStack(spacing: 2 + Self.spacingDelta) {
                probRows
            }
        }
    }

    // MARK: Private

    private var adaptiveSpacingInCharacterView: Bool {
        AppConfig.adaptiveSpacingInCharacterView
    }
}

// MARK: - AttributeLabel

// @available(iOS 15.0, *)
struct AttributeLabel: View {
    // MARK: Lifecycle

    public init(
        iconString: String = "",
        name: String,
        value: String,
        fontSize: CGFloat = 15,
        titleEmphasized: Bool = false,
        textColor: Color = .primary,
        backgroundColor: Color = .gray
    ) {
        self.iconString = iconString
        self.name = name
        self.value = value
        self.valueView = Text(LocalizedStringKey(value))
        self.fontSize = fontSize
        self.titleEmphasized = titleEmphasized
        self.textColor = textColor
        self.backgroundColor = backgroundColor
    }

    public init(
        iconString: String = "",
        name: String,
        valueView: Text,
        fontSize: CGFloat = 15,
        titleEmphasized: Bool = false,
        textColor: Color = .primary,
        backgroundColor: Color = .gray
    ) {
        self.iconString = iconString
        self.name = name
        self.value = ""
        self.valueView = valueView
        self.fontSize = fontSize
        self.titleEmphasized = titleEmphasized
        self.textColor = textColor
        self.backgroundColor = backgroundColor
    }

    // MARK: Internal

    let iconString: String
    let name: String
    let value: String
    let fontSize: CGFloat
    let titleEmphasized: Bool
    let textColor: Color
    let backgroundColor: Color
    let valueView: Text?

    var body: some View {
        let image = Image(iconString)
            .resizable()
            .scaledToFit()
            .padding(.vertical, 1)
            .padding(.leading, 3)
        let nameView = Text(LocalizedStringKey(name))
            .font(.systemCondensed(
                size: fontSize,
                weight: titleEmphasized ? .heavy : .regular
            ))
            .fixedSize(horizontal: true, vertical: true)
            .minimumScaleFactor(0.5)
            .lineLimit(1)
        if #available(iOS 15.0, *) {
            let valueViewModified = valueView
                .font(.systemCondensed(size: fontSize, weight: .semibold))
                .foregroundColor(textColor)
                .fixedSize(horizontal: true, vertical: true)
                .minimumScaleFactor(0.5)
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
                    if !iconString.isEmpty {
                        image
                    }
                    HStack {
                        nameView
                        Spacer()
                        valueViewModified
                    }
                }
                .frame(height: fontSize + 6)
            } else {
                // Fallback on earlier versions
                HStack {
                    HStack {
                        if !iconString.isEmpty {
                            image
                        }
                        nameView
                    }
                    Spacer()
                    valueViewModified
                }
                .frame(height: fontSize + 6)
            }
        } else {
            // Fallback on earlier versions
            let valueViewModified = valueView
                .foregroundColor(textColor)
                .padding(.horizontal)
                .background(
                    Capsule()
                        .frame(height: 20)
                        .frame(maxWidth: 200)
                        .opacity(0.25)
                )
            HStack {
                HStack {
                    if !iconString.isEmpty {
                        image
                    }
                    nameView
                }
                Spacer()
                valueViewModified
            }
            .frame(height: fontSize + 6)
        }
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
            VStack(spacing: 4 + spacingDelta) {
                perArtifactDetailView(artifact)
            }
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
            enabled: AppConfig.showRarityAndLevelForArtifacts
        )
        VStack(spacing: 0 + spacingDelta) {
            Text(artifact.mainAttribute.name.convertPercentageMarkToUpMark)
                .font(.system(size: 11, weight: .bold))
            Text("\(artifact.mainAttribute.valueString)")
                .font(.systemCompressed(size: 18, weight: .heavy))
                .fixedSize(horizontal: false, vertical: true)
                .minimumScaleFactor(0.5)
        }
        ForEach(
            artifact.subAttributes,
            id: \.name
        ) { subAttribute in
            VStack(spacing: 0 + spacingDelta) {
                Text(subAttribute.name.convertPercentageMarkToUpMark)
                    .font(.system(size: 11))
                Text("\(subAttribute.valueString)")
                    .font(.systemCondensed(size: 16, weight: .bold))
                    .fixedSize(horizontal: false, vertical: true)
                    .minimumScaleFactor(0.5)
            }
        }
    }

    // MARK: Private

    private let artifacts: [PlayerDetail.Avatar.Artifact]

    private var spacingDelta: CGFloat {
        EachCharacterDetailDatasView.spacingDelta
    }
}

// MARK: - AvatarAndSkillView

// @available(iOS 15.0, *)
private struct AvatarAndSkillView: View {
    // MARK: Internal

    let avatar: PlayerDetail.Avatar

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
            VStack(alignment: .leading, spacing: 2 + spacingDelta) {
                HStack(alignment: .bottom) {
                    Text(avatar.nameCorrected)
                        .font(.system(size: 23, weight: .black))
                        .fixedSize(horizontal: false, vertical: true)
                        .minimumScaleFactor(0.5)
                        .lineLimit(1)
                    if ThisDevice.notchType == .none {
                        Spacer().frame(width: 24)
                    }
                }
                HStack(alignment: .center) {
                    VStack(alignment: .leading, spacing: 2 + spacingDelta) {
                        AttributeLabel(
                            name: "等级",
                            value: avatar.level.description
                        )
                        AttributeLabel(
                            name: "命之座",
                            valueView: Text("\(avatar.talentCount)命")
                        )
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

    // MARK: Private

    private var spacingDelta: CGFloat {
        EachCharacterDetailDatasView.spacingDelta
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
                    .font(.systemCondensed(size: textSize, weight: .medium))
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
        HStack(alignment: .firstTextBaseline, spacing: 0) {
            Text("\(level)").font(.system(size: 14, weight: .heavy))
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
