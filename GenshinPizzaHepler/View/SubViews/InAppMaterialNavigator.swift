//
//  InAppMaterialNavigator.swift
//  GenshinPizzaHepler
//
//  Created by 戴藏龙 on 2022/8/25.
//

import SwiftUI

struct InAppMaterialNavigator: View {
    var today: MaterialWeekday = .today()
    var talentMaterialProvider: TalentMaterialProvider { .init(weekday: today) }
    var weaponMaterialProvider: WeaponMaterialProvider { .init(weekday: today) }

    let uuid = UUID()

    @State var showMaterialDetail = false

    @Namespace var animationMaterial

    var body: some View {
        VStack {
            HStack {
                if today != .sunday {
                    Text("今日材料")
                        .font(.caption)
                        .padding(.top)
                        .padding(.leading, 25)
                        .padding(.bottom, -10)
//                        .foregroundColor(Color("materialTextColor"))
                    Spacer()
                } else {
                    Text("今日材料：星期日所有材料均可获取")
                        .font(.caption)
                        .padding()
//                        .foregroundColor(Color("materialTextColor"))

                }
            }
            if !showMaterialDetail {
                materials()
            } else {
                materialsDetail()
                    .padding(.vertical)
            }
        }
        .blurMaterialBackground()
        .padding(.horizontal)
        .onTapGesture {
            simpleTaptic(type: .light)
            withAnimation(.interactiveSpring(response: 0.25, dampingFraction: 1.0, blendDuration: 0)) {
                showMaterialDetail.toggle()
            }
        }
    }

    @ViewBuilder
    func materials() -> some View {
        if today != .sunday {
            let imageWidth = UIScreen.main.bounds.width * 1/10
            HStack(spacing: 0) {
                Spacer()
                ForEach(talentMaterialProvider.todaysMaterials, id: \.imageString) { material in
                    Image(material.imageString)
                        .resizable()
                        .scaledToFit()
                        .matchedGeometryEffect(id: material.imageString, in: animationMaterial)
                        .frame(width: imageWidth)
                        .padding(.vertical)
                }
                Spacer(minLength: UIScreen.main.bounds.width * 1/30)
                ForEach(weaponMaterialProvider.todaysMaterials, id: \.imageString) { material in
                    Image(material.imageString)
                        .resizable()
                        .scaledToFit()
                        .matchedGeometryEffect(id: material.imageString, in: animationMaterial)
                        .frame(width: imageWidth)
                }
                Spacer()
            }
        } else {
            EmptyView()
        }
    }

    @ViewBuilder
    func materialsDetail() -> some View {
        let imageWidth = UIScreen.main.bounds.width * 1/8
        HStack {
            Spacer()
            VStack(alignment: .leading) {
                ForEach(talentMaterialProvider.todaysMaterials, id: \.imageString) { material in
                    HStack {
                        Image(material.imageString)
                            .resizable()
                            .scaledToFit()
                            .matchedGeometryEffect(id: material.imageString, in: animationMaterial)
                            .frame(width: imageWidth)
                        Text(material.localizedName)
                            .foregroundColor(Color("materialTextColor"))

                    }

                }
            }
            Spacer()
            VStack(alignment: .leading) {
                ForEach(weaponMaterialProvider.todaysMaterials, id: \.imageString) { material in
                    HStack {
                        Image(material.imageString)
                            .resizable()
                            .scaledToFit()
                            .matchedGeometryEffect(id: material.imageString, in: animationMaterial)
                            .frame(width: imageWidth)
                        Text(material.localizedName)
                            .foregroundColor(Color("materialTextColor"))
                    }
                }
            }
            Spacer()
        }
    }
}

extension View {
    func blurMaterialBackground() -> some View {
        if #available(iOS 15.0, *) {
            return AnyView(self.background(.regularMaterial, in: RoundedRectangle(cornerRadius: 20, style: .continuous)))
        } else {
            return AnyView(self.background(RoundedRectangle(cornerRadius: 20, style: .continuous).foregroundColor(Color(UIColor.systemGray6))))
        }
    }
}

