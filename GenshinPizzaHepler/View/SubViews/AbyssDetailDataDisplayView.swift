//
//  AbyssDetailDataDisplayView.swift
//  GenshinPizzaHepler
//
//  Created by 戴藏龙 on 2022/10/7.
//

import GIPizzaKit
import HBMihoyoAPI
import HoYoKit
import SwiftUI

// MARK: - AbyssDetailDataDisplayView

struct AbyssDetailDataDisplayView: View {
    // MARK: Lifecycle

    public init(currentData: SpiralAbyssDetail, previousStatus: DetailPortalViewModel.Status<SpiralAbyssDetail>) {
        self.currentData = currentData
        self.previousStatus = previousStatus
    }

    // MARK: Internal

    let currentData: SpiralAbyssDetail
    let previousStatus: DetailPortalViewModel.Status<SpiralAbyssDetail>

    @Environment(\.horizontalSizeClass)
    var horizontalSizeClass

    var body: some View {
        List {
            // 战斗数据榜
            if !data.rankDataMissing {
                if OS.type == .macOS || horizontalSizeClass != .compact {
                    statisticViewNormal
                } else {
                    statisticViewCompact
                }
            } else {
                Text("app.abyss.noData").listRowMaterialBackground()
            }

            ForEach(data.floors.reversed(), id: \.index) { floorData in
                AbyssFloorView(floorData: floorData).listRowMaterialBackground()
            }
        }
        .listStyle(.insetGrouped)
        .scrollContentBackground(.hidden)
        .listContainerBackground(fileNameOverride: NameCard.UI_NameCardPic_Sj1_P.fileName)
        .navigationTitle("app.abyss.info.title")
        .toolbar {
            if previousData != nil {
                ToolbarItem(
                    placement: .navigationBarTrailing
                ) {
                    Picker("", selection: $season.animation()) {
                        Text("abyss.detailDataDisplayView.season.current")
                            .tag(AccountSpiralAbyssDetail.WhichSeason.this)
                        Text("abyss.detailDataDisplayView.season.previous")
                            .tag(AccountSpiralAbyssDetail.WhichSeason.last)
                    }
                    .labelsHidden()
                    .pickerStyle(.segmented)
                    .background(
                        RoundedRectangle(cornerRadius: 8).foregroundStyle(.thinMaterial)
                    )
                }
            }
            if OS.type == .macOS {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("sys.done") {
                        dismiss()
                    }
                }
            }
        }
        .toolbarSavePhotoButton(
            placement: .navigationBarTrailing,
            visible: !data.rankDataMissing
        ) {
            AbyssShareView(data: data)
        }
    }

    @ViewBuilder
    var statisticViewNormal: some View {
        // 总体战斗结果概览
        Section {
            VStack {
                Grid {
                    GridRow {
                        AbyssValueCellView(
                            value: data.maxFloor, description: "app.abyss.info.deepest", avatar: {}
                        )
                        AbyssValueCellView(
                            value: "\(data.totalBattleTimes)",
                            description: "app.abyss.info.battle", avatar: {}
                        )
                        AbyssValueCellView(
                            value: "\(data.totalWinTimes)",
                            description: "app.abyss.info.win", avatar: {}
                        )
                    }
                    GridRow {
                        AbyssValueCellView(
                            value: "\(data.totalStar)", description: "app.abyss.info.star", avatar: {}
                        )
                        AbyssValueCellView(
                            value: sayNullableInt(data.takeDamageRank.first?.value),
                            description: "app.abyss.info.mostDamageTaken",
                            avatar: {
                                makeAvatar(data.takeDamageRank.first?.avatarId)
                            }
                        )
                        AbyssValueCellView(
                            value: sayNullableInt(data.damageRank.first?.value),
                            description: "app.abyss.info.strongest",
                            avatar: {
                                makeAvatar(data.damageRank.first?.avatarId)
                            }
                        )
                    }
                    GridRow {
                        AbyssValueCellView(
                            value: sayNullableInt(data.defeatRank.first?.value),
                            description: "app.abyss.info.mostDefeats",
                            avatar: {
                                makeAvatar(data.defeatRank.first?.avatarId)
                            }
                        )
                        AbyssValueCellView(
                            value: sayNullableInt(data.normalSkillRank.first?.value),
                            description: "app.abyss.info.mostESkills",
                            avatar: {
                                makeAvatar(data.normalSkillRank.first?.avatarId)
                            }
                        )
                        AbyssValueCellView(
                            value: sayNullableInt(data.energySkillRank.first?.value),
                            description: "app.abyss.info.mostQSkills",
                            avatar: {
                                makeAvatar(data.energySkillRank.first?.avatarId)
                            }
                        )
                    }
                }
                .frame(maxWidth: .infinity)
            }
        } header: {
            Text("app.abyss.info.summary")
                .secondaryColorVerseBackground()
        }
        .listRowMaterialBackground()
    }

    @ViewBuilder
    var statisticViewCompact: some View {
        // 总体战斗结果概览
        Section {
            InfoPreviewer(title: "app.abyss.info.deepest", content: data.maxFloor)
            InfoPreviewer(title: "app.abyss.info.star", content: "\(data.totalStar)")
            InfoPreviewer(
                title: "app.abyss.info.battle",
                content: "\(data.totalBattleTimes)"
            )
            InfoPreviewer(title: "app.abyss.info.win", content: "\(data.totalWinTimes)")
        } header: {
            Text("app.abyss.info.summary")
                .secondaryColorVerseBackground()
        }
        .listRowMaterialBackground()

        Section {
            BattleDataInfoProvider(
                name: "app.abyss.info.strongest",
                value: data.damageRank.first?.value,
                avatarID: data.damageRank.first?.avatarId
            )
            BattleDataInfoProvider(
                name: "app.abyss.info.mostDefeats",
                value: data.defeatRank.first?.value,
                avatarID: data.defeatRank.first?.avatarId
            )
            BattleDataInfoProvider(
                name: "app.abyss.info.mostDamageTaken",
                value: data.takeDamageRank.first?.value,
                avatarID: data.takeDamageRank.first?.avatarId
            )
            BattleDataInfoProvider(
                name: "app.abyss.info.mostESkills",
                value: data.normalSkillRank.first?.value,
                avatarID: data.normalSkillRank.first?.avatarId
            )
            BattleDataInfoProvider(
                name: "app.abyss.info.mostQSkills",
                value: data.energySkillRank.first?.value,
                avatarID: data.energySkillRank.first?.avatarId
            )
        } header: {
            Text("app.abyss.info.notableStats")
                .secondaryColorVerseBackground()
        }
        .listRowMaterialBackground()
    }

    @ViewBuilder
    func makeAvatar(_ id: Int?) -> some View {
        CharacterAsset.match(id: id ?? -213).decoratedIcon(48, cutTo: .face)
            .frame(width: 52, alignment: .center)
    }

    func sayNullableInt(_ int: Int?) -> String {
        int?.description ?? "-1"
    }

    // MARK: Private

    @State
    private var season: AccountSpiralAbyssDetail.WhichSeason = .this

    @Environment(\.dismiss)
    private var dismiss

    private var previousData: SpiralAbyssDetail? {
        switch previousStatus {
        case .fail, .progress: return nil
        case let .succeed(dataPrev): return dataPrev
        }
    }

    private var data: SpiralAbyssDetail {
        switch season {
        case .this:
            return currentData
        case .last:
            return previousData ?? currentData
        }
    }
}

// MARK: - AbyssFloorView

private struct AbyssFloorView: View {
    let floorData: SpiralAbyssDetail.Floor

    var foldableTitleText: String {
        let initials = String(
            format: NSLocalizedString("app.abyss.info.floor", comment: ""),
            floorData.index
        )
        if ThisDevice.isHDPhoneOrPodTouch || OS.type == .macOS {
            let buffer = NSMutableString()
            buffer.append(initials)
            buffer.append(" - ")
            buffer.append("app.abyss.star.obtained".localized)
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
                        Label(title: { Text("app.abyss.star.obtained") }) {
                            AbyssStarIcon()
                        }
                        Spacer()
                        Text("\(floorData.star)/\(floorData.maxStar)")
                    }
                    Divider().frame(height: 3)
                }
                ForEach(floorData.levels, id: \.index) { levelData in
                    AbyssLevelView(levelData: levelData)
                }
            }
        } header: {
            Text(foldableTitleText)
                .secondaryColorVerseBackground()
        }
    }
}

// MARK: - AbyssLevelView

private struct AbyssLevelView: View {
    // MARK: Internal

    let levelData: SpiralAbyssDetail.Floor.Level

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(spacing: 0) {
                if ThisDevice.isSmallestSlideOverWindowWidth || ThisDevice.isSmallestHDScreenPhone {
                    Text("第\(levelData.index)间")
                        .font(.subheadline)
                        .bold()
                        .frame(minHeight: 20)
                    Spacer()
                    ForEach(0 ..< levelData.star, id: \.self) { _ in
                        Text(verbatim: "✡︎")
                    }
                } else {
                    Text("第\(levelData.index)间")
                        .font(.subheadline)
                        .bold()
                        .frame(minHeight: 25)
                    Spacer()
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
                            AbyssBattleView(battleData: battleData)
                        }
                    }
                } else {
                    ForEach(levelData.battles, id: \.index) { battleData in
                        AbyssBattleView(battleData: battleData)
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

    var decoratedIconSize: CGFloat {
        (ThisDevice.isSmallestSlideOverWindowWidth || ThisDevice.isSmallestHDScreenPhone) ? 45 : 55
    }

    var body: some View {
        let intSpacing: CGFloat = ThisDevice.isHDPhoneOrPodTouch ? 0 : 2
        let size = decoratedIconSize
        let hasTermLabel = !(
            ThisDevice.isThinnestSplitOnPad || ThisDevice.isSmallestSlideOverWindowWidth || ThisDevice
                .isSmallestHDScreenPhone || OS.type == .macOS
        )
        HStack(alignment: .center, spacing: intSpacing) {
            Spacer().frame(minWidth: 0)
            Group {
                if hasTermLabel {
                    HStack {
                        switch battleData.index {
                        case 1:
                            Text("app.abyss.half.1")
                                .font(.system(size: UIFont.smallSystemFontSize, design: .monospaced)).fixedSize()
                        case 2:
                            Text("app.abyss.half.2")
                                .font(.system(size: UIFont.smallSystemFontSize, design: .monospaced)).fixedSize()
                        default:
                            Text("sys.unknown")
                                .font(.system(size: UIFont.smallSystemFontSize, design: .monospaced)).fixedSize()
                        }
                        Spacer()
                    }
                }
            }
            ForEach(battleData.avatars, id: \.id) { avatarData in
                let theAsset = CharacterAsset.match(id: avatarData.id)
                if ThisDevice.isHDPhoneOrPodTouch {
                    theAsset.decoratedIcon(size, cutTo: .head, roundRect: true)
                        .corneredTag(verbatim: "\(avatarData.level)", alignment: .bottomTrailing, textSize: 11)
                        .frame(height: size + 5)
                } else {
                    theAsset.cardIcon(size / 0.74)
                        .corneredTag(verbatim: "Lv.\(avatarData.level)", alignment: .bottom, textSize: 11)
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

    var body: some View {
        HStack {
            Text(name.localized)
            Spacer()
            Text("\(value ?? -1)").foregroundColor(.primary.opacity(0.7))
            CharacterAsset.match(id: avatarID ?? -213).decoratedIcon(32, cutTo: .face)
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

    var body: some View {
        if let floor = data.floors.last {
            ShareAbyssFloorView(floorData: floor)
        } else {
            Text("No Data")
        }
    }
}

// MARK: - ShareAbyssFloorView

private struct ShareAbyssFloorView: View {
    let floorData: SpiralAbyssDetail.Floor

    var body: some View {
        VStack {
            Text("深境螺旋第\(floorData.index)层").font(.title).bold()
            HStack {
                AbyssStarIcon()
                    .frame(width: 30, height: 30)
                Text("app.abyss.star.obtained")
                Spacer()
                Text("\(floorData.star)/\(floorData.maxStar)")
            }
            .font(.headline)
            ForEach(floorData.levels, id: \.index) { levelData in
                AbyssLevelView(levelData: levelData)
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
        .foregroundStyle(.white)
        .listContainerBackground(fileNameOverride: NameCard.UI_NameCardPic_Sj1_P.fileName)
        .environment(\.colorScheme, .dark)
    }
}

// MARK: - AbyssValueCellView

private struct AbyssValueCellView<Avatar: View>: View {
    let value: String
    let description: LocalizedStringKey
    @ViewBuilder
    let avatar: () -> Avatar

    var body: some View {
        HStack(alignment: .center) {
            VStack(alignment: .center) {
                Text(verbatim: value)
                    .lineLimit(1)
                    .font(.title)
                    .fontWeight(.heavy)
                    .fontWidth(.compressed)
                    .minimumScaleFactor(0.3)
                Text(description)
                    .lineLimit(1)
                    .font(.caption)
                    .minimumScaleFactor(0.3)
            }
            .frame(maxWidth: .infinity)
            avatar()
        }
        .frame(maxWidth: .infinity)
        .padding(8)
        .background(
            .regularMaterial,
            in: RoundedRectangle(cornerRadius: 8, style: .circular)
        )
    }
}
