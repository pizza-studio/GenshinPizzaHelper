//
//  InAppMaterialNavigator.swift
//  GenshinPizzaHepler
//
//  Created by 戴藏龙 on 2022/8/25.
//  主页今日材料页面

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

    let imageWidth = CGFloat(50)

    var talentMaterialProvider: TalentMaterialProvider {
        .init(weekday: showingWeekday)
    }

    var weaponMaterialProvider: WeaponMaterialProvider {
        .init(weekday: showingWeekday)
    }

    var body: some View {
        VStack {
            HStack {
                if showingWeekday != .sunday {
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
                        }
                    }
                    .padding(.leading, 25)
                    .font(.caption)
                    .padding(.top)
                    .padding(.bottom, -10)
                    Spacer()
                    if showMaterialDetail == false {
                        Text(getDate())
                            .font(.caption)
                            .padding(.top)
                            .padding(.bottom, -10)
                    } else {
                        Button("收起") {
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
                        }
                        .font(.caption)
                        .padding(.top)
                        .padding(.bottom, -10)
                    }
                    Image(systemName: "chevron.forward")
                        .rotationEffect(
                            Angle(degrees: showMaterialDetail ? 90 : 0),
                            anchor: .center
                        )
                        .foregroundColor(
                            showMaterialDetail ? .accentColor :
                                .secondary
                        )
                        .padding(.trailing, 25)
                        .font(.caption)
                        .padding(.top)
                        .padding(.bottom, -10)
                } else {
                    Group {
                        if showMaterialDetail {
                            Menu(showingWeekday.describe()) {
                                ForEach(
                                    MaterialWeekday.allCases,
                                    id: \.hashValue
                                ) { weekday in
                                    Button(weekday.describe()) {
                                        showingWeekday = weekday
                                    }
                                }
                            }
                        } else {
                            Text("今日材料")
                        }
                    }
                    .font(.caption)
                    .padding(.vertical)
                    .padding(.leading, 25)
                    Spacer()
                    Group {
                        if showRelatedDetailOfMaterial !=
                            nil { Text("左右滑动查看所有角色") } else { Text("所有材料均可获取") }
                    }
                    .multilineTextAlignment(.center)
                    .font(.caption)
                    .padding()
                    Spacer()
                    if showMaterialDetail == false {
                        Text(getDate())
                            .font(.caption)
                            .padding(.vertical)
                    } else {
                        Button("收起") {
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
                        }
                        .font(.caption)
                        .padding(.vertical)
                    }
                    Image(systemName: "chevron.forward")
                        .rotationEffect(
                            Angle(degrees: showMaterialDetail ? 90 : 0),
                            anchor: .center
                        )
                        .foregroundColor(
                            showMaterialDetail ? .accentColor :
                                .secondary
                        )
                        .padding(.trailing, 25)
                        .font(.caption)
                }
            }
            if !showMaterialDetail {
                materials()
            } else {
                if showRelatedDetailOfMaterial == nil {
                    materialsDetail()
                        .padding(
                            showingWeekday != .sunday ? .vertical :
                                .bottom
                        )
                } else {
                    materialRelatedItemView()
                        .padding()
                }
            }
        }
        .blurMaterialBackground()
        .padding(.horizontal)
        .onTapGesture {
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
        .onChange(of: scenePhase) { newValue in
            switch newValue {
            case .active:
                showingWeekday = .today()
            default:
                break
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
            .padding(.vertical)
        } else {
            EmptyView()
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
                        HStack {
                            ForEach(
                                material.relatedItem,
                                id: \.imageString
                            ) { item in
                                VStack {
                                    if let char = item.character {
                                        char.cardIcon(90)
                                    } else {
                                        Image(item.imageString)
                                            .resizable()
                                            .scaledToFill()
                                            .frame(width: 75, height: 90)
                                            .clipped()
                                    }
                                    Text(item.displayName)
                                        .font(.footnote)
                                        .foregroundColor(.secondary)
                                        .padding(.bottom)
                                }
                            }
                        }
                    }
                }
                Text("左右滑动查看更多")
                    .font(.caption)
                    .foregroundColor(.secondary)
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
        let formatter = DateFormatter.Gregorian()
        formatter.setLocalizedDateFormatFromTemplate("MMMMd EEEE")
        return formatter.string(from: Date())
    }
}
