//
//  MaterialChoices.swift
//  GenshinPizzaHelper
//
//  Created by 戴藏龙 on 2022/9/20.
//

import Foundation

extension WeaponOrTalentMaterial {
    // MARK: - Weapon Material choices
    // 蒙德
    static let decarabian: WeaponOrTalentMaterial = .init(
        imageString: "weapon.Decarabian",
        localizedName: "「高塔孤王」",
        weekday: .mondayAndThursday)
    static let borealWolf: WeaponOrTalentMaterial = .init(imageString: "weapon.BorealWolf", localizedName: "「凛风奔狼」", weekday: .tuesdayAndFriday)
    static let dandelionGladiator: WeaponOrTalentMaterial = .init(imageString: "weapon.DandelionGladiator", localizedName: "「狮牙斗士」", weekday: .wednesdayAndSaturday)

    // 璃月
    static let guyun: WeaponOrTalentMaterial = .init(imageString: "weapon.Guyun", localizedName: "「孤云寒林」", weekday: .mondayAndThursday)
    static let mistVeiled: WeaponOrTalentMaterial = .init(imageString: "weapon.MistVeiled", localizedName: "「雾海云间」", weekday: .tuesdayAndFriday)
    static let aerosiderite: WeaponOrTalentMaterial = .init(imageString: "weapon.Aerosiderite", localizedName: "「漆黑陨铁」", weekday: .wednesdayAndSaturday)

    // 稻妻
    static let distantSea: WeaponOrTalentMaterial = .init(imageString: "weapon.DistantSea", localizedName: "「远海夷地」", weekday: .mondayAndThursday)
    static let narukami: WeaponOrTalentMaterial = .init(imageString: "weapon.Narukami", localizedName: "「鸣神御灵」", weekday: .tuesdayAndFriday)
    static let kijin: WeaponOrTalentMaterial = .init(imageString: "weapon.Kijin", localizedName: "「今昔剧画」", weekday: .wednesdayAndSaturday)

    // 须弥
    static let forestDew: WeaponOrTalentMaterial = .init(imageString: "weapon.ForestDew", localizedName: "「谧林涓露」", weekday: .mondayAndThursday)
    static let oasisGarden: WeaponOrTalentMaterial = .init(imageString: "weapon.OasisGarden", localizedName: "「绿洲花园」", weekday: .tuesdayAndFriday)
    static let scorchingMight: WeaponOrTalentMaterial = .init(imageString: "weapon.ScorchingMight", localizedName: "「烈日威权」", weekday: .wednesdayAndSaturday)

    // 所有材料
    static let allWeaponMaterials: [WeaponOrTalentMaterial] = [
        .decarabian, .borealWolf, .dandelionGladiator, .guyun, .mistVeiled, .aerosiderite, .distantSea, .narukami, .kijin, .forestDew, .oasisGarden, .scorchingMight
    ]
    static func allWeaponMaterialsOf(weekday: MaterialWeekday) -> [WeaponOrTalentMaterial] {
        allWeaponMaterials.filter { material in
            (material.weekday == weekday) || (weekday == .sunday)
        }
    }

    // MARK: - Talent Material choices
    // 蒙德
    static let freedom: WeaponOrTalentMaterial = .init(imageString: "talent.Freedom", localizedName: "「自由」", weekday: .mondayAndThursday)
    static let resistance: WeaponOrTalentMaterial = .init(imageString: "talent.Resistance", localizedName: "「抗争」", weekday: .tuesdayAndFriday,
                                                          relatedItem: [
                                                            .init(imageString: "UI_AvatarIcon_Mona_Card", localizedName: "莫娜"),
                                                            .init(imageString: "UI_AvatarIcon_Qin_Card", localizedName: "琴"),
                                                            .init(imageString: "UI_AvatarIcon_Eula_Card", localizedName: "优菈"),
                                                            .init(imageString: "UI_AvatarIcon_Diluc_Card", localizedName: "迪卢克"),
                                                            .init(imageString: "UI_AvatarIcon_Razor_Card", localizedName: "雷泽"),
                                                            .init(imageString: "UI_AvatarIcon_Noel_Card", localizedName: "诺艾尔"),
                                                            .init(imageString: "UI_AvatarIcon_Bennett_Card", localizedName: "班尼特"),
                                                          ])
    static let ballad: WeaponOrTalentMaterial = .init(imageString: "talent.Ballad", localizedName: "「诗文」", weekday: .wednesdayAndSaturday)

    // 璃月
    static let prosperity: WeaponOrTalentMaterial = .init(imageString: "talent.Prosperity", localizedName: "「繁荣」", weekday: .mondayAndThursday)
    static let diligence: WeaponOrTalentMaterial = .init(imageString: "talent.Diligence", localizedName: "「勤劳」", weekday: .tuesdayAndFriday)
    static let gold: WeaponOrTalentMaterial = .init(imageString: "talent.Gold", localizedName: "「黄金」", weekday: .wednesdayAndSaturday)

    // 稻妻
    static let transience: WeaponOrTalentMaterial = .init(imageString: "talent.Transience", localizedName: "「浮世」", weekday: .mondayAndThursday)
    static let elegance: WeaponOrTalentMaterial = .init(imageString: "talent.Elegance", localizedName: "「风雅」", weekday: .tuesdayAndFriday)
    static let light: WeaponOrTalentMaterial = .init(imageString: "talent.Light", localizedName: "「天光」", weekday: .wednesdayAndSaturday)

    // 须弥
    static let admonition: WeaponOrTalentMaterial = .init(imageString: "talent.Admonition", localizedName: "「诤言」", weekday: .mondayAndThursday)
    static let ingenuity: WeaponOrTalentMaterial = .init(imageString: "talent.Ingenuity", localizedName: "「巧思」", weekday: .tuesdayAndFriday)
    static let praxis: WeaponOrTalentMaterial = .init(imageString: "talent.Praxis", localizedName: "「笃行」", weekday: .wednesdayAndSaturday)

    // 所有天赋材料
    static let allTalentMaterials: [WeaponOrTalentMaterial] = [
        .freedom, .resistance, .ballad, .prosperity, .diligence, .gold, .transience, .elegance, .light, .admonition, .ingenuity, .praxis
    ]
    static func allTalentMaterialsOf(weekday: MaterialWeekday) -> [WeaponOrTalentMaterial] {
        allTalentMaterials.filter { material in
            (material.weekday == weekday) || (weekday == .sunday)
        }
    }
}
