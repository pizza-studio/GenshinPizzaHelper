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

    public init(currentSeason: SpiralAbyssDetail, previousSeason: SpiralAbyssDetail?) {
        self.currentData = currentSeason
        self.previousData = previousSeason
    }

    // MARK: Internal

    let currentData: SpiralAbyssDetail
    let previousData: SpiralAbyssDetail?

    @Namespace
    var animation

    var body: some View {
        GeometryReader { geometry in
            coreBodyView.onAppear {
                containerSize = geometry.size
            }.onChange(of: geometry.size) { newSize in
                containerSize = newSize
            }
        }
    }

    @ViewBuilder
    var coreBodyView: some View {
        List {
            // 战斗数据榜
            if !data.rankDataMissing {
                Section {
                    StaggeredGrid(
                        columns: columns,
                        outerPadding: false,
                        scroll: false,
                        list: data.summarizedIntoCells(compact: columns % 2 == 0),
                        content: { currentCell in
                            AbyssValueCellView(cellData: currentCell)
                                .matchedGeometryEffect(id: currentCell.id, in: animation)
                        }
                    )
                    .animation(.easeInOut, value: columns)
                } header: {
                    Text("app.abyss.info.summary")
                        .secondaryColorVerseBackground()
                }
                .listRowMaterialBackground()
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
        .environmentObject(orientation)
    }

    // MARK: Private

    @Environment(\.horizontalSizeClass)
    private var horizontalSizeClass

    @StateObject
    private var orientation = ThisDevice.DeviceOrientation()

    @State
    private var containerSize: CGSize = .zero

    @State
    private var season: AccountSpiralAbyssDetail.WhichSeason = .this

    @Environment(\.dismiss)
    private var dismiss

    private var columns: Int {
        min(max(Int(floor($containerSize.wrappedValue.width / 200)), 2), 4)
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
            ForEach(guardedAvatars, id: \.id) { avatarData in
                let theAsset = CharacterAsset.match(id: avatarData.id)
                ZStack {
                    if ThisDevice.isHDPhoneOrPodTouch {
                        theAsset.decoratedIcon(size, cutTo: .head, roundRect: true)
                            .corneredTag(verbatim: "\(avatarData.level)", alignment: .bottomTrailing, textSize: 11)
                            .frame(height: size + 5)
                    } else {
                        theAsset.cardIcon(size / 0.74)
                            .corneredTag(verbatim: "Lv.\(avatarData.level)", alignment: .bottom, textSize: 11)
                            .padding(.vertical, 2)
                    }
                }.opacity(theAsset == .Paimon ? 0 : 1)
                if avatarData.id != battleData.avatars.last!.id {
                    Spacer().frame(minWidth: 0)
                }
            }
            Spacer().frame(minWidth: 0, maxWidth: hasTermLabel ? .infinity : nil)
        }.environmentObject(orientation)
    }

    var guardedAvatars: [SpiralAbyssDetail.Floor.Level.Battle.Avatar] {
        var result = battleData.avatars
        while result.count < 4 {
            result.append(.init(id: -213, icon: "", level: -213, rarity: 5))
        }
        return result
    }

    // MARK: Private

    @StateObject
    private var orientation = ThisDevice.DeviceOrientation()
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

private struct AbyssValueCellView: View {
    let cellData: AbyssValueCell

    var body: some View {
        HStack(alignment: .center) {
            VStack(alignment: .center) {
                Text(verbatim: cellData.value)
                    .lineLimit(1)
                    .font(.title)
                    .fontWeight(.heavy)
                    .fontWidth(.compressed)
                    .minimumScaleFactor(0.3)
                Text(cellData.description)
                    .lineLimit(1)
                    .font(.caption)
                    .minimumScaleFactor(0.3)
            }
            .frame(maxWidth: .infinity)
            cellData.makeAvatar()
        }
        .frame(maxWidth: .infinity)
        .padding(8)
        .background(
            .regularMaterial,
            in: RoundedRectangle(cornerRadius: 8, style: .circular)
        )
    }
}

// MARK: - AbyssValueCell

private struct AbyssValueCell: Identifiable, Hashable {
    // MARK: Lifecycle

    public init(value: String, description: String, avatarId: Int? = nil) {
        self.avatarId = avatarId
        self.value = value
        self.description = description.localized
    }

    public init(value: Int?, description: String, avatarId: Int? = nil) {
        self.avatarId = avatarId
        self.value = (value ?? -1).description
        self.description = description.localized
    }

    // MARK: Internal

    let id: Int = UUID().hashValue
    let avatarId: Int?
    var value: String
    var description: String

    func makeAvatar() -> some View {
        guard let avatarId = avatarId else { return AnyView(EmptyView()) }
        guard let avatar = CharacterAsset(rawValue: avatarId) else { return AnyView(EmptyView()) }
        let result = avatar.decoratedIcon(48, cutTo: .face).frame(width: 52, alignment: .center)
        return AnyView(result)
    }
}

extension SpiralAbyssDetail {
    fileprivate func summarizedIntoCells(compact: Bool = false) -> [AbyssValueCell] {
        var result = [AbyssValueCell]()
        result.append(AbyssValueCell(value: maxFloor, description: "app.abyss.info.deepest"))
        if compact {
            let appendCell = AbyssValueCell(value: totalBattleTimes, description: "app.abyss.info.battle")
            var newCell = AbyssValueCell(value: totalWinTimes, description: "app.abyss.info.win")
            newCell.value += " / \(appendCell.value)"
            newCell.description += " / \(appendCell.description)"
            result.append(newCell)
        } else {
            result.append(AbyssValueCell(value: totalBattleTimes, description: "app.abyss.info.battle"))
            result.append(AbyssValueCell(value: totalWinTimes, description: "app.abyss.info.win"))
        }
        result.append(AbyssValueCell(value: totalStar, description: "app.abyss.info.star"))
        result.append(
            AbyssValueCell(
                value: takeDamageRank.first?.value,
                description: "app.abyss.info.mostDamageTaken",
                avatarId: takeDamageRank.first?.avatarId
            )
        )
        result.append(
            AbyssValueCell(
                value: damageRank.first?.value,
                description: "app.abyss.info.strongest",
                avatarId: damageRank.first?.avatarId
            )
        )
        result.append(
            AbyssValueCell(
                value: defeatRank.first?.value,
                description: "app.abyss.info.mostDefeats",
                avatarId: defeatRank.first?.avatarId
            )
        )
        result.append(
            AbyssValueCell(
                value: normalSkillRank.first?.value,
                description: "app.abyss.info.mostESkills",
                avatarId: normalSkillRank.first?.avatarId
            )
        )
        result.append(
            AbyssValueCell(
                value: energySkillRank.first?.value,
                description: "app.abyss.info.mostQSkills",
                avatarId: energySkillRank.first?.avatarId
            )
        )
        return result
    }
}
