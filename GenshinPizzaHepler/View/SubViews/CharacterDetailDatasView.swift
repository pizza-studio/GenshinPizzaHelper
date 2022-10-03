//
//  CharacterDetailDatasView.swift
//  GenshinPizzaHelper
//
//  Created by Bill Haku on 2022/9/24.
//

import SwiftUI

struct CharacterDetailDatasView: View {
    var avatar: PlayerDetail.Avatar

    var body: some View {
        ScrollView {
            VStack {
                HStack(alignment: .center) {
                    Label {
                        Text("\(avatar.name)")
                            .font(.title)
                    } icon: {
                        WebImage(urlStr: "http://ophelper.top/resource/\(avatar.sideIconString).png")
                            .frame(width: 50, height: 50)
                    }
                    Spacer()
                }
                .padding(.bottom, 10)
                Group {
                    InfoPreviewer(title: "武器", content: "\(avatar.weapon.name)", contentStyle: .capsule, textColor: .primary, backgroundColor: .gray)
                    InfoPreviewer(title: "等级", content: "\(avatar.level)", contentStyle: .capsule, textColor: .primary, backgroundColor: .gray)
                    InfoPreviewer(title: "生命值", content: "\(avatar.fightPropMap.HP.rounded(toPlaces: 1))", contentStyle: .capsule, textColor: .primary, backgroundColor: .gray)
                    InfoPreviewer(title: "攻击力", content: "\(avatar.fightPropMap.ATK.rounded(toPlaces: 1))", contentStyle: .capsule, textColor: .primary, backgroundColor: .gray)
                    InfoPreviewer(title: "防御力", content: "\(avatar.fightPropMap.DEF.rounded(toPlaces: 1))", contentStyle: .capsule, textColor: .primary, backgroundColor: .gray)
                    InfoPreviewer(title: "元素精通", content: "\(avatar.fightPropMap.elementalMastery.rounded(toPlaces: 1))", contentStyle: .capsule, textColor: .primary, backgroundColor: .gray)
                    InfoPreviewer(title: "元素充能效率", content: "\((avatar.fightPropMap.energyRecharge * 100).rounded(toPlaces: 2))%", contentStyle: .capsule, textColor: .primary, backgroundColor: .gray)
                    InfoPreviewer(title: "治疗加成", content: "\((avatar.fightPropMap.healingBonus * 100).rounded(toPlaces: 2))%", contentStyle: .capsule, textColor: .primary, backgroundColor: .gray)
                    InfoPreviewer(title: "暴击率", content: "\((avatar.fightPropMap.criticalRate * 100).rounded(toPlaces: 2))%", contentStyle: .capsule, textColor: .primary, backgroundColor: .gray)
                    InfoPreviewer(title: "暴击伤害", content: "\((avatar.fightPropMap.criticalDamage * 100.0).rounded(toPlaces: 2))%", contentStyle: .capsule, textColor: .primary, backgroundColor: .gray)
                }
                switch avatar.element {
                case .wind: 
                    InfoPreviewer(title: "风元素伤害加成", content: "\((avatar.fightPropMap.anemoDamage * 100.0).rounded(toPlaces: 2))%", contentStyle: .capsule, textColor: .primary, backgroundColor: .gray)
                case .ice:
                    InfoPreviewer(title: "冰元素伤害加成", content: "\((avatar.fightPropMap.cryoDamage * 100.0).rounded(toPlaces: 2))%", contentStyle: .capsule, textColor: .primary, backgroundColor: .gray)
                case .electric:
                    InfoPreviewer(title: "雷元素伤害加成", content: "\((avatar.fightPropMap.electroDamage * 100.0).rounded(toPlaces: 2))%", contentStyle: .capsule, textColor: .primary, backgroundColor: .gray)
                case .water:
                    InfoPreviewer(title: "水元素伤害加成", content: "\((avatar.fightPropMap.hydroDamage * 100.0).rounded(toPlaces: 2))%", contentStyle: .capsule, textColor: .primary, backgroundColor: .gray)
                case .fire:
                    InfoPreviewer(title: "火元素伤害加成", content: "\((avatar.fightPropMap.pyroDamage * 100.0).rounded(toPlaces: 2))%", contentStyle: .capsule, textColor: .primary, backgroundColor: .gray)
                case .rock:
                    InfoPreviewer(title: "岩元素伤害加成", content: "\((avatar.fightPropMap.geoDamage * 100.0).rounded(toPlaces: 2))%", contentStyle: .capsule, textColor: .primary, backgroundColor: .gray)
                case .grass:
                    InfoPreviewer(title: "草元素伤害加成", content: "\((avatar.fightPropMap.dendroDamage * 100.0).rounded(toPlaces: 2))%", contentStyle: .capsule, textColor: .primary, backgroundColor: .gray)
                default:
                    EmptyView()
                }
                if avatar.fightPropMap.physicalDamage > 0 {
                    InfoPreviewer(title: "物理伤害加成", content: "\((avatar.fightPropMap.physicalDamage * 100.0).rounded(toPlaces: 2))%", contentStyle: .capsule, textColor: .primary, backgroundColor: .gray)
                }
                Divider()
                artifactsDetailsView()
                Spacer(minLength: 50)
            }
            .padding()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.white)
            .cornerRadius(16)
        }
    }

    @ViewBuilder
    func artifactsDetailsView() -> some View {
        if #available(iOS 16, *) {
            Grid {
                GridRow {
                    ForEach(avatar.artifacts) { artifact in
                        EnkaWebIcon(iconString: artifact.iconString)
                    }
                }
                GridRow {
                    ForEach(avatar.artifacts) { artifact in
                        VStack {
                            Text(artifact.mainAttribute.name)
                                .font(.caption)
                            Text("\(artifact.mainAttribute.valueString)")
                                .bold()
                        }
                    }
                }
                GridRow {
                    ForEach(avatar.artifacts) { artifact in
                        VStack {
                            ForEach(artifact.subAttributes, id:\.name) { subAttribute in
                                Text(subAttribute.name)
                                    .font(.caption)
                                Text("\(subAttribute.valueString)")
                            }
                        }
                    }
                }
            }
        }
    }
}

enum CharacterElement: String {
    case cyro = "Ice"
    case anemo = "Wind"
    case electro = "Electric"
    case hydro = "Water"
    case pryo = "Fire"
    case geo = "Rock"
    case dendro = "Grass"
    case none = "none"
}
