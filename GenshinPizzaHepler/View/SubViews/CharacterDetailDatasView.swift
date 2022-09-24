//
//  CharacterDetailDatasView.swift
//  GenshinPizzaHelper
//
//  Created by Bill Haku on 2022/9/24.
//

import SwiftUI

struct CharacterDetailDatasView: View {
    var characterDetailData: PlayerDetails.AvatarInfo
    @Binding var charactersDetailMap: ENCharacterMap?
    @Binding var charactersLocMap: ENCharacterLoc?

    var body: some View {
        VStack {
            Group {
                InfoPreviewer(title: "角色ID", content: "\(getLocalizedNameFromID(id: characterDetailData.avatarId))", contentStyle: .capsule, textColor: .primary, backgroundColor: .gray)
                InfoPreviewer(title: "等级", content: "\(characterDetailData.propMap.level)", contentStyle: .capsule, textColor: .primary, backgroundColor: .gray)
                InfoPreviewer(title: "生命值", content: "\(characterDetailData.fightPropMap.HP.rounded(toPlaces: 1))", contentStyle: .capsule, textColor: .primary, backgroundColor: .gray)
                InfoPreviewer(title: "攻击力", content: "\(characterDetailData.fightPropMap.ATK.rounded(toPlaces: 1))", contentStyle: .capsule, textColor: .primary, backgroundColor: .gray)
                InfoPreviewer(title: "防御力", content: "\(characterDetailData.fightPropMap.DEF.rounded(toPlaces: 1))", contentStyle: .capsule, textColor: .primary, backgroundColor: .gray)
                InfoPreviewer(title: "元素精通", content: "\(characterDetailData.fightPropMap.elementalMastery.rounded(toPlaces: 1))", contentStyle: .capsule, textColor: .primary, backgroundColor: .gray)
                InfoPreviewer(title: "元素充能效率", content: "\((characterDetailData.fightPropMap.energyRecharge * 100).rounded(toPlaces: 2))%", contentStyle: .capsule, textColor: .primary, backgroundColor: .gray)
                InfoPreviewer(title: "治疗加成", content: "\((characterDetailData.fightPropMap.healingBonus * 100).rounded(toPlaces: 2))%", contentStyle: .capsule, textColor: .primary, backgroundColor: .gray)
                InfoPreviewer(title: "暴击率", content: "\((characterDetailData.fightPropMap.criticalRate * 100).rounded(toPlaces: 2))%", contentStyle: .capsule, textColor: .primary, backgroundColor: .gray)
                InfoPreviewer(title: "暴击伤害", content: "\((characterDetailData.fightPropMap.criticalDamage * 100.0).rounded(toPlaces: 2))%", contentStyle: .capsule, textColor: .primary, backgroundColor: .gray)
            }
            Spacer()
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.white)
        .cornerRadius(16)
    }

    func getNameTextMapHash(id: Int) -> Int {
        return charactersDetailMap?.characterDetails["\(id)"]?.NameTextMapHash ?? -1
    }

    func getLocalizedNameFromMapHash(hashId: Int) -> String {
        switch Locale.current.languageCode {
        case "zh":
            return charactersLocMap?.zh_cn.content["\(hashId)"] ?? "Unknown"
        case "en":
            return charactersLocMap?.en.content["\(hashId)"] ?? "Unknown"
        case "ja":
            return charactersLocMap?.ja.content["\(hashId)"] ?? "Unknown"
        case "fr":
            return charactersLocMap?.fr.content["\(hashId)"] ?? "Unknown"
        default:
            return charactersLocMap?.en.content["\(hashId)"] ?? "Unknown"
        }
    }

    func getLocalizedNameFromID(id: Int) -> String {
        let hashId = getNameTextMapHash(id: id)
        return getLocalizedNameFromMapHash(hashId: hashId)
    }
}
