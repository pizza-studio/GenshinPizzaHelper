//
//  EachCharacterDetailDataView.swift
//  GenshinPizzaHelper
//
//  Created by Bill Haku on 2022/9/24.
//

import Defaults
import GIPizzaKit
import SwiftUI

// MARK: - EachAvatarStatView

struct EachAvatarStatView: View {
    // MARK: Lifecycle

    init(avatar: PlayerDetail.Avatar) {
        self.avatar = avatar
    }

    // MARK: Internal

    static var spacingDelta: CGFloat {
        ThisDevice.useAdaptiveSpacing ? spacingDeltaAmount : 0
    }

    var avatar: PlayerDetail.Avatar

    var body: some View {
        HStack(alignment: .top, spacing: 0) {
            VStack(spacing: 6.5 + Self.spacingDelta) {
                AvatarAndSkillView(avatar: avatar, fontSize: 25)
                    .padding(.bottom, 2)
                ZStack {
                    Color.black.opacity(0.1).cornerRadius(14)
                    VStack(spacing: 6.5 + Self.spacingDelta) {
                        weapon(fontSize: 25)
                        probView(fontSize: 25)
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 10)
                }.fixedSize(horizontal: false, vertical: true)
                HStack(alignment: .top, spacing: Self.spacingDelta) {
                    artifactsDetailsView()
                }
            }
        }.padding(Self.spacingDeltaAmount * 7)
            .padding(.vertical, Self.spacingDeltaAmount * 5)
    }

    @ViewBuilder
    func artifactsDetailsView() -> some View {
        enumerateArtifacts().frame(maxWidth: .infinity)
    }

    @ViewBuilder
    func weapon(fontSize: CGFloat = 25) -> some View {
        HStack(alignment: .center, spacing: 19) {
            // Weapon
            let weapon = avatar.weapon
            let maxHeight: CGFloat = fontSize * 4.3 + Self.spacingDelta * 2
            ZStack {
                EnkaWebIcon(
                    iconString: weapon.rankLevel
                        .rectangularBackgroundIconString
                )
                .scaledToFit()
                .scaleEffect(1.4)
                .offset(
                    y: (maxHeight * 1.4 - maxHeight) /
                        2
                )
                .clipShape(Circle())
                EnkaWebIcon(iconString: weapon.awakenedIconString)
                    .scaledToFit()
            }
            .frame(width: maxHeight, height: maxHeight)
            .corneredTag(
                verbatim: "Lv.\(weapon.level)",
                alignment: .bottom,
                textSize: ceil(fontSize * 0.86)
            )
            VStack(alignment: .leading, spacing: 3.3 + Self.spacingDelta) {
                AttributeLabel(
                    name: weapon.nameCorrected,
                    valueView: Text("detailPortal.EASV.refineRank:\(weapon.refinementRank)"),
                    fontSize: fontSize,
                    titleEmphasized: true,
                    hasDash: false
                )
                AttributeLabel(
                    name: weapon.mainAttribute.name
                        .percentageMarksTrimmed,
                    value: avatar.weapon.mainAttribute.valueString,
                    fontSize: fontSize,
                    hasDash: false
                )
                if let subAttribute = weapon.subAttribute {
                    AttributeLabel(
                        name: subAttribute.name.percentageMarksTrimmed,
                        value: subAttribute.valueString,
                        fontSize: fontSize,
                        hasDash: false
                    )
                }
            }
        }
    }

    @ViewBuilder
    func probView(fontSize: CGFloat = 25) -> some View {
        VStack(spacing: 3.3 + Self.spacingDelta) {
            ForEach(avatar.getProbBackendDataPairs(useAdaptiveSpacing: ThisDevice.useAdaptiveSpacing)) { probData in
                AttributeLabel(
                    iconString: probData.iconString,
                    name: probData.name,
                    value: probData.value,
                    fontSize: fontSize
                )
            }
        }
    }

    @ViewBuilder
    func enumerateArtifacts(fontSize: CGFloat = 25) -> some View {
        ForEach(
            Array(avatar.artifacts.enumerated()),
            id: \.offset
        ) { seqIndex, artifact in
            VStack(spacing: 6.5 + Self.spacingDelta) {
                perArtifactDetailView(
                    artifact,
                    seqIndex: seqIndex,
                    fontSize: fontSize
                )
            }
        }
    }

    @ViewBuilder
    func perArtifactDetailView(
        _ artifact: PlayerDetail.Avatar.Artifact,
        seqIndex: Int,
        fontSize: CGFloat = 25
    )
        -> some View {
        HomeSourceWebIcon(
            iconString: artifact
                .iconString
        )
        .scaledToFit()
        .frame(width: fontSize * 4, height: fontSize * 4 + Self.spacingDelta)
        .corneredTag(
            verbatim: "Lv.\(artifact.level) ☆\(artifact.rankLevel.rawValue)",
            alignment: .bottom,
            textSize: fontSize * 0.72,
            enabled: Defaults[.showRarityAndLevelForArtifacts]
        )
        .corneredTag(
            // TODO: i18n malfunction.
            "detailPortal.EASV.scoreUnit:\(String(format: "%.0f", artifact.score ?? -1))",
            alignment: .topLeading,
            textSize: fontSize * 0.72,
            enabled: artifact.score != nil && Defaults[.artifactRatingOptions].contains(.enabled)
        )
        VStack(spacing: 0 + Self.spacingDelta) {
            Text(artifact.mainAttribute.name.percentageMarksTrimmed)
                .font(.system(size: fontSize * 0.73, weight: .bold))
            Text("\(artifact.mainAttribute.valueString)")
                .font(.systemCompressed(size: fontSize * 1.2, weight: .heavy))
                .fixedSize(horizontal: false, vertical: true)
                .minimumScaleFactor(0.5)
        }
        ForEach(
            artifact.subAttributes,
            id: \.name
        ) { subAttribute in
            VStack(spacing: 0 + Self.spacingDelta) {
                Text(subAttribute.name.percentageMarksTrimmed)
                    .font(.system(size: fontSize * 0.73))
                Text("\(subAttribute.valueString)")
                    .font(.systemCondensed(
                        size: fontSize * 1.05,
                        weight: .bold
                    ))
                    .fixedSize(horizontal: false, vertical: true)
                    .minimumScaleFactor(0.5)
            }
        }
    }

    // MARK: Private

    private static let spacingDeltaAmount: CGFloat = 5
}

// MARK: - AttributeLabel

struct AttributeLabel: View {
    // MARK: Lifecycle

    public init(
        iconString: String = "",
        iconStringSecondary: String? = nil,
        name: String,
        value: String,
        fontSize: CGFloat = 25,
        titleEmphasized: Bool = false,
        textColor: Color = .primary,
        backgroundColor: Color = .gray,
        hasDash: Bool = true
    ) {
        self.secondaryIconString = iconStringSecondary
        self.iconString = iconString
        self.name = name
        self.value = value
        self.valueView = Text(LocalizedStringKey(value))
        self.fontSize = fontSize
        self.titleEmphasized = titleEmphasized
        self.textColor = textColor
        self.backgroundColor = backgroundColor
        self.hasDash = hasDash
    }

    public init(
        iconString: String = "",
        iconStringSecondary: String? = nil,
        name: String,
        valueView: Text,
        fontSize: CGFloat = 25,
        titleEmphasized: Bool = false,
        textColor: Color = .primary,
        backgroundColor: Color = .gray,
        hasDash: Bool = true
    ) {
        self.secondaryIconString = iconStringSecondary
        self.iconString = iconString
        self.name = name
        self.value = ""
        self.valueView = valueView
        self.fontSize = fontSize
        self.titleEmphasized = titleEmphasized
        self.textColor = textColor
        self.backgroundColor = backgroundColor
        self.hasDash = hasDash
    }

    // MARK: Internal

    let iconString: String
    let secondaryIconString: String?
    let name: String
    let value: String
    let fontSize: CGFloat
    let titleEmphasized: Bool
    let textColor: Color
    let backgroundColor: Color
    let valueView: Text?
    let hasDash: Bool

    var image: some View {
        guard !iconString.isEmpty else {
            return AnyView(EmptyView())
        }
        let result = Image(iconString)
            .resizable()
            .scaledToFit()
            .frame(width: fontSize + 3, height: fontSize + 3)
            .padding(.leading, 3)
        return AnyView(result)
    }

    var secondaryImage: some View {
        guard let secondaryIconString = secondaryIconString,
              !secondaryIconString.isEmpty else {
            return AnyView(EmptyView())
        }
        let result = Image(secondaryIconString)
            .resizable()
            .scaledToFit()
            .frame(width: fontSize + 3, height: fontSize + 3)
        return AnyView(result)
    }

    var nameView: some View {
        Text(LocalizedStringKey(name))
            .font(.systemCondensed(
                size: fontSize,
                weight: titleEmphasized ? .heavy : .regular
            ))
            .fixedSize(horizontal: true, vertical: true)
            .minimumScaleFactor(0.5)
            .lineLimit(1)
    }

    var dashSpacer: some View {
        guard hasDash else { return AnyView(Spacer()) }
        return AnyView(
            Color.white.opacity(0.1)
                .frame(maxWidth: .infinity, maxHeight: 0.5)
        )
    }

    var body: some View {
        let valueViewModified = valueView
            .font(.systemCondensed(size: fontSize, weight: .semibold))
            .foregroundColor(textColor)
            .fixedSize(horizontal: true, vertical: true)
            .minimumScaleFactor(0.5)
            .padding(.horizontal, fontSize / 2)
            .padding(.vertical, fontSize / 4)
            .background(
                Capsule()
                    .fill(Color.white.opacity(0.1))
                    .frame(height: fontSize / 3 * 4)
            )
        HStack {
            HStack {
                HStack(spacing: 0) {
                    image
                    secondaryImage
                }
                nameView
            }
            dashSpacer
            valueViewModified
        }
        .frame(height: fontSize / 3 * 4)
    }
}

// MARK: - AvatarAndSkillView

private struct AvatarAndSkillView: View {
    // MARK: Internal

    let avatar: PlayerDetail.Avatar
    let fontSize: CGFloat

    var body: some View {
        HStack(alignment: .bottom, spacing: fontSize / 2) {
            avatar.characterAsset.decoratedIcon(fontSize * 5.6, cutTo: .shoulder)
                .padding(.trailing, fontSize / 5)
            VStack(alignment: .leading, spacing: 3.3 + spacingDelta) {
                HStack(alignment: .bottom) {
                    Text(avatar.nameCorrectedAndTruncated)
                        .font(.system(size: fontSize * 1.45, weight: .black))
                        .fixedSize(horizontal: false, vertical: true)
                        .minimumScaleFactor(0.5)
                        .lineLimit(1)
                    // if ThisDevice.notchType == .none { Spacer().frame(width: fontSize * 1.56) }
                }
                HStack(alignment: .center, spacing: fontSize / 2) {
                    VStack(
                        alignment: .leading,
                        spacing: 3.3 + spacingDelta / 2
                    ) {
                        AttributeLabel(
                            name: "detailPortal.EASV.characterLevel",
                            value: avatar.level.description,
                            hasDash: false
                        )
                        AttributeLabel(
                            name: "detailPortal.EASV.constellation",
                            valueView: Text("detailPortal.EASV.constellation.unit:\(avatar.constellation)"),
                            hasDash: false
                        )
                    }
                    .font(.system(size: fontSize))
                    HStack(alignment: .lastTextBaseline, spacing: 3.3) {
                        ForEach(avatar.skills, id: \.self) { skill in
                            ZStack(alignment: .bottom) {
                                VStack {
                                    ZStack(alignment: .center) {
                                        Color.black.opacity(0.1)
                                            .clipShape(Circle())
                                        EnkaWebIcon(
                                            iconString: skill
                                                .iconString
                                        )
                                        .scaledToFit().scaleEffect(0.8)
                                    }.frame(
                                        width: fontSize * 2.6,
                                        height: fontSize * 2.6
                                    )
                                    Spacer()
                                }
                                // 这里不用 corneredTag，因为要动态调整图示与等级数字之间的显示距离。
                                // 而且 skill.levelDisplay 也不是纯文本，而是 some View。
                                ZStack(alignment: .center) {
                                    Color.black.opacity(0.1)
                                        .clipShape(Capsule())
                                    skill.levelDisplay(size: fontSize * 0.9)
                                        .padding(.horizontal, 4)
                                }.frame(height: fontSize)
                                    .fixedSize()
                            }.frame(
                                width: fontSize * 2.6,
                                height: fontSize * 3.1 + spacingDelta / 2
                            )
                        }
                    }.frame(width: 192)
                }
            }.fixedSize(horizontal: false, vertical: true)
        }
        .frame(height: fontSize * 5.6)
    }

    // MARK: Private

    private var spacingDelta: CGFloat {
        EachAvatarStatView.spacingDelta
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
    func levelDisplay(size: CGFloat) -> some View {
        HStack(alignment: .firstTextBaseline, spacing: 0) {
            Text("\(level)").font(.system(size: size * 0.93, weight: .heavy))
            if isLevelAdjusted {
                Text("+\(levelAdjusted - level)")
                    .font(.system(size: size * 0.8, weight: .heavy))
            }
        }
    }
}

// MARK: - Convert trailing percentage mark into a rised arrow mark.

extension String {
    fileprivate var percentageMarksTrimmed: String {
        if !contains("％"), !contains("%") { return self }
        return replacingOccurrences(of: "％", with: "")
            .replacingOccurrences(of: "%", with: "")
    }
}
