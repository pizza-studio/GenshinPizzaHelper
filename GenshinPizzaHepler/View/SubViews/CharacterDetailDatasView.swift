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

    var body: some View {
        VStack {
            InfoPreviewer(title: "角色ID", content: "\(getNameTextMapHash(id: characterDetailData.avatarId))", contentStyle: .capsule, textColor: .primary, backgroundColor: .gray)
            InfoPreviewer(title: "攻击力", content: "\(characterDetailData.fightPropMap.ATK.rounded(toPlaces: 1))", contentStyle: .capsule, textColor: .primary, backgroundColor: .gray)
            InfoPreviewer(title: "生命值", content: "\(characterDetailData.fightPropMap.HP.rounded(toPlaces: 1))", contentStyle: .capsule, textColor: .primary, backgroundColor: .gray)
            InfoPreviewer(title: "防御力", content: "\(characterDetailData.fightPropMap.DEF.rounded(toPlaces: 1))", contentStyle: .capsule, textColor: .primary, backgroundColor: .gray)
            InfoPreviewer(title: "暴击率", content: "\((characterDetailData.fightPropMap.criticalRate * 100).rounded(toPlaces: 2))%", contentStyle: .capsule, textColor: .primary, backgroundColor: .gray)
            InfoPreviewer(title: "暴击伤害", content: "\((characterDetailData.fightPropMap.criticalDamage * 100.0).rounded(toPlaces: 2))%", contentStyle: .capsule, textColor: .primary, backgroundColor: .gray)
            InfoPreviewer(title: "元素充能效率", content: "\((characterDetailData.fightPropMap.energyRecharge * 100).rounded(toPlaces: 2))%", contentStyle: .capsule, textColor: .primary, backgroundColor: .gray)
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.white)
        .cornerRadius(16)
    }

    func getNameTextMapHash(id: Int) -> Int {
        return charactersDetailMap?.characterDetails["\(id)"]?.NameTextMapHash ?? -1
    }
}
