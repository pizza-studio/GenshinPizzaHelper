//
//  InAppMaterialNavigator.swift
//  GenshinPizzaHepler
//
//  Created by 戴藏龙 on 2022/8/25.
//  主页今日材料页面

import SFSafeSymbols
import SwiftUI

struct InAppMaterialNavigator: View {
    @State
    var showingWeekday: MaterialWeekday = .today()
    @Environment(\.scenePhase)
    var scenePhase

    let uuid = UUID()

    @State
    var showMaterialDetail = false

    @State
    var showRelatedDetailOfMaterial: WeaponOrTalentMaterial?

    @Namespace
    var animationMaterial

    @Environment(\.colorScheme)
    var colorScheme

    let imageWidth = CGFloat(50)

    var viewBackgroundColor: UIColor {
        colorScheme == .light ? UIColor.secondarySystemBackground : UIColor.systemBackground
    }

    var sectionBackgroundColor: UIColor {
        colorScheme == .dark ? UIColor.secondarySystemBackground : UIColor.systemBackground
    }

    var talentMaterialProvider: TalentMaterialProvider {
        .init(weekday: showingWeekday)
    }

    var weaponMaterialProvider: WeaponMaterialProvider {
        .init(weekday: showingWeekday)
    }

    var body: some View {
        Section {
            HStack {
                Spacer()
                if !showMaterialDetail {
                    materials()
                } else {
                    if showRelatedDetailOfMaterial == nil {
                        materialsDetail()
                    } else {
                        materialRelatedItemView()
                    }
                }
                Spacer()
            }
            .padding()
            .onTapGesture { switchStatus() }
            .onChange(of: scenePhase) { newValue in
                switch newValue {
                case .active:
                    showingWeekday = .today()
                default:
                    break
                }
            }
            .listRowInsets(EdgeInsets())
        } header: {
            HStack {
                Group {
                    if showMaterialDetail {
                        Menu(showingWeekday.describe()) {
                            ForEach(
                                MaterialWeekday.allCases,
                                id: \.hashValue
                            ) { weekday in
                                Button(weekday.describe()) {
                                    withAnimation {
                                        showingWeekday = weekday
                                    }
                                }
                            }
                        }
                    } else {
                        Text("今日材料")
                            .foregroundColor(.primary)
                            .font(.headline)
                    }
                }
                .font(.caption)
                Spacer()
                HStack(spacing: 2) {
                    if showMaterialDetail == false {
                        Button {
                            switchStatus()
                        } label: {
                            Text(getDate())
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    } else {
                        Button {
                            simpleTaptic(type: .light)
                            withAnimation(.interactiveSpring(
                                response: 0.25,
                                dampingFraction: 1.0,
                                blendDuration: 0
                            )) {
                                showingWeekday = .today()
                                showRelatedDetailOfMaterial = nil
                                showMaterialDetail = false
                            }
                        } label: {
                            HStack {
                                Text("收起").font(.caption)
                            }
                        }
                    }
                    Image(systemSymbol: .chevronForward)
                        .rotationEffect(
                            Angle(degrees: showMaterialDetail ? 90 : 0),
                            anchor: .center
                        )
                        .font(.caption)
                        .foregroundColor(showMaterialDetail ? .accentColor : .secondary)
                }
            }
        }
    }

    func switchStatus() {
        if !showMaterialDetail {
            simpleTaptic(type: .light)
            withAnimation(.interactiveSpring(
                response: 0.25,
                dampingFraction: 1.0,
                blendDuration: 0
            )) {
                showingWeekday = .today()
                showMaterialDetail = true
            }
        }
        if showRelatedDetailOfMaterial != nil {
            simpleTaptic(type: .light)
            withAnimation(.interactiveSpring(
                response: 0.25,
                dampingFraction: 1.0,
                blendDuration: 0
            )) {
                showRelatedDetailOfMaterial = nil
            }
        }
    }

    @ViewBuilder
    func materials() -> some View {
        if showingWeekday != .sunday {
            let imageWidth = CGFloat(40)
            VStack(spacing: 0) {
                HStack(spacing: 0) {
                    ForEach(
                        talentMaterialProvider.todaysMaterials,
                        id: \.imageString
                    ) { material in
                        Image(material.imageString)
                            .resizable()
                            .scaledToFit()
                            .matchedGeometryEffect(
                                id: material.imageString,
                                in: animationMaterial
                            )
                            .frame(width: imageWidth)
                    }
                }
                HStack(spacing: 0) {
                    ForEach(
                        weaponMaterialProvider.todaysMaterials,
                        id: \.imageString
                    ) { material in
                        Image(material.imageString)
                            .resizable()
                            .scaledToFit()
                            .matchedGeometryEffect(
                                id: material.imageString,
                                in: animationMaterial
                            )
                            .frame(width: imageWidth)
                    }
                }
            }
        } else {
            Text("所有材料均可获取")
        }
    }

    @ViewBuilder
    func materialsDetail() -> some View {
        VStack(alignment: .trailing) {
            HStack {
                Spacer()
                VStack(alignment: .leading) {
                    ForEach(
                        talentMaterialProvider.todaysMaterials,
                        id: \.imageString
                    ) { material in
                        HStack {
                            Image(material.imageString)
                                .resizable()
                                .scaledToFit()
                                .matchedGeometryEffect(
                                    id: material.imageString,
                                    in: animationMaterial
                                )
                                .frame(width: imageWidth)
                            Text(material.displayName)
                                .foregroundColor(Color("materialTextColor"))
                                .matchedGeometryEffect(
                                    id: material.displayName,
                                    in: animationMaterial
                                )
                        }
                        .onTapGesture {
                            simpleTaptic(type: .light)
                            withAnimation(.interactiveSpring(
                                response: 0.25,
                                dampingFraction: 1.0,
                                blendDuration: 0
                            )) {
                                showRelatedDetailOfMaterial = material
                            }
                        }
                    }
                }
                Spacer()
                VStack(alignment: .leading) {
                    ForEach(
                        weaponMaterialProvider.todaysMaterials,
                        id: \.imageString
                    ) { material in
                        HStack {
                            Image(material.imageString)
                                .resizable()
                                .scaledToFit()
                                .matchedGeometryEffect(
                                    id: material.imageString,
                                    in: animationMaterial
                                )
                                .frame(width: imageWidth)
                            Text(material.displayName)
                                .foregroundColor(Color("materialTextColor"))
                                .matchedGeometryEffect(
                                    id: material.displayName,
                                    in: animationMaterial
                                )
                        }
                        .onTapGesture {
                            simpleTaptic(type: .light)
                            withAnimation(.interactiveSpring(
                                response: 0.25,
                                dampingFraction: 1.0,
                                blendDuration: 0
                            )) {
                                showRelatedDetailOfMaterial = material
                            }
                        }
                    }
                }
                Spacer()
            }
            Spacer()
        }
    }

    @ViewBuilder
    func materialRelatedItemView() -> some View {
        if let material = showRelatedDetailOfMaterial {
            VStack(alignment: .center) {
                VStack(alignment: .leading, spacing: 10) {
                    HStack {
                        Image(material.imageString)
                            .resizable()
                            .scaledToFit()
                            .matchedGeometryEffect(
                                id: material.imageString,
                                in: animationMaterial
                            )
                            .frame(width: imageWidth)
                        Text(material.displayName)
                            .foregroundColor(Color("materialTextColor"))
                            .matchedGeometryEffect(
                                id: material.displayName,
                                in: animationMaterial
                            )
                    }
                    ScrollView(.horizontal) {
                        HStack(alignment: .top) {
                            ForEach(
                                material.relatedItem,
                                id: \.imageString
                            ) { item in
                                VStack {
                                    if let char = item.character {
                                        char.cardIcon(90)
                                        let charNameFormatted = char.localized
                                            .split(separator: " ").joined(separator: "\n")
                                        Text(charNameFormatted)
                                            .font(.footnote)
                                            .foregroundColor(.secondary)
                                            .padding(.bottom)
                                    } else {
                                        Image(item.imageString)
                                            .resizable()
                                            .scaledToFill()
                                            .frame(width: 75, height: 90)
                                            .clipped()
                                        let itemNameFormatted = item.displayName.localized
                                            .split(separator: " ").joined(separator: "\n")
                                        Text(itemNameFormatted)
                                            .font(.footnote)
                                            .foregroundColor(.secondary)
                                            .padding(.bottom)
                                    }
                                }
                            }
                        }
                    }
                }
                if OS.type == .macOS {
                    HelpTextForScrollingOnDesktopComputer(.horizontal)
                } else {
                    Text("左右滑动查看更多")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                Spacer()
            }
            .onTapGesture {
                simpleTaptic(type: .light)
                withAnimation(.interactiveSpring(
                    response: 0.25,
                    dampingFraction: 1.0,
                    blendDuration: 0
                )) {
                    showRelatedDetailOfMaterial = nil
                }
            }
        } else {
            EmptyView()
        }
    }

    func getDate() -> String {
        let formatter = DateFormatter()
        formatter.setLocalizedDateFormatFromTemplate("MMMMd EEEE")
        return formatter.string(from: Date())
    }
}
