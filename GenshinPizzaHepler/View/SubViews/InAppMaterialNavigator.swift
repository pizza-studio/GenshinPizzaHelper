//
//  InAppMaterialNavigator.swift
//  GenshinPizzaHepler
//
//  Created by 戴藏龙 on 2022/8/25.
//  主页今日材料页面

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
                    Spacer()
                    Text(getDate())
                        .font(.caption)
                        .padding(.top)
                        .padding(.trailing, 25)
                        .padding(.bottom, -10)
                } else {
                    Text("今日材料")
                        .font(.caption)
                        .padding()
                    Spacer()
                    Text("所有材料均可获取")
                        .multilineTextAlignment(.center)
                        .font(.caption)
                        .padding()
                    Spacer()
                    Text(getDate())
                        .font(.caption)
                        .padding()
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
            let imageWidth = CGFloat(40)
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
                Spacer()
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
        let imageWidth = CGFloat(50)
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

    func getDate() -> String {
        let formatter = DateFormatter()
        formatter.setLocalizedDateFormatFromTemplate("MMMMd EEEE")
        return formatter.string(from: Date())
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

