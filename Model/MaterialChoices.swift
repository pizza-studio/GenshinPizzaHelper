//
//  MaterialChoices.swift
//  GenshinPizzaHelper
//
//  Created by 戴藏龙 on 2022/9/20.
//

import Foundation

extension WeaponMaterial {
    // 所有材料
    static let allMaterials: [WeaponMaterial] = [
        .decarabian, .borealWolf, .dandelionGladiator, .guyun, .mistVeiled, .aerosiderite, .distantSea, .narukami, .kijin, .forestDew, .oasisGarden, .scorchingMight
    ]
    static func allMaterialsOf(weekday: MaterialWeekday) -> [WeaponMaterial] {
        allMaterials.filter { material in
            (material.weekday == weekday) || (weekday == .sunday)
        }
    }

    // MARK: - Weapon Material choices
    // 蒙德
    static let decarabian: WeaponMaterial = .init(
        imageString: "weapon.Decarabian",
        localizedName: "「高塔孤王」",
        weekday: .mondayAndThursday)
    static let borealWolf: WeaponMaterial = .init(imageString: "weapon.BorealWolf", localizedName: "「凛风奔狼」", weekday: .tuesdayAndFriday)
    static let dandelionGladiator: WeaponMaterial = .init(imageString: "weapon.DandelionGladiator", localizedName: "「狮牙斗士」", weekday: .wednesdayAndSaturday)

    // 璃月
    static let guyun: WeaponMaterial = .init(imageString: "weapon.Guyun", localizedName: "「孤云寒林」", weekday: .mondayAndThursday)
    static let mistVeiled: WeaponMaterial = .init(imageString: "weapon.MistVeiled", localizedName: "「雾海云间」", weekday: .tuesdayAndFriday)
    static let aerosiderite: WeaponMaterial = .init(imageString: "weapon.Aerosiderite", localizedName: "「漆黑陨铁」", weekday: .wednesdayAndSaturday)

    // 稻妻
    static let distantSea: WeaponMaterial = .init(imageString: "weapon.DistantSea", localizedName: "「远海夷地」", weekday: .mondayAndThursday)
    static let narukami: WeaponMaterial = .init(imageString: "weapon.Narukami", localizedName: "「鸣神御灵」", weekday: .tuesdayAndFriday)
    static let kijin: WeaponMaterial = .init(imageString: "weapon.Kijin", localizedName: "「今昔剧画」", weekday: .wednesdayAndSaturday)

    // 须弥
    static let forestDew: WeaponMaterial = .init(imageString: "weapon.ForestDew", localizedName: "「谧林涓露」", weekday: .mondayAndThursday)
    static let oasisGarden: WeaponMaterial = .init(imageString: "weapon.OasisGarden", localizedName: "「绿洲花园」", weekday: .tuesdayAndFriday)
    static let scorchingMight: WeaponMaterial = .init(imageString: "weapon.ScorchingMight", localizedName: "「烈日威权」", weekday: .wednesdayAndSaturday)
}

extension TalentMaterial {
    // 所有材料
    static let allMaterials: [TalentMaterial] = [
        .freedom, .resistance, .ballad, .prosperity, .diligence, .gold, .transience, .elegance, .light, .admonition, .ingenuity, .praxis
    ]
    static func allMaterialsOf(weekday: MaterialWeekday) -> [TalentMaterial] {
        allMaterials.filter { material in
            (material.weekday == weekday) || (weekday == .sunday)
        }
    }

    // MARK: - Talent Material choices
    // 蒙德
    static let freedom: TalentMaterial = .init(imageString: "talent.Freedom", localizedName: "「自由」", weekday: .mondayAndThursday)
    static let resistance: TalentMaterial = .init(imageString: "talent.Resistance", localizedName: "「抗争」", weekday: .tuesdayAndFriday)
    static let ballad: TalentMaterial = .init(imageString: "talent.Ballad", localizedName: "「诗文」", weekday: .wednesdayAndSaturday)

    // 璃月
    static let prosperity: TalentMaterial = .init(imageString: "talent.Prosperity", localizedName: "「繁荣」", weekday: .mondayAndThursday)
    static let diligence: TalentMaterial = .init(imageString: "talent.Diligence", localizedName: "「勤劳」", weekday: .tuesdayAndFriday)
    static let gold: TalentMaterial = .init(imageString: "talent.Gold", localizedName: "「黄金」", weekday: .wednesdayAndSaturday)

    // 稻妻
    static let transience: TalentMaterial = .init(imageString: "talent.Transience", localizedName: "「浮世」", weekday: .mondayAndThursday)
    static let elegance: TalentMaterial = .init(imageString: "talent.Elegance", localizedName: "「风雅」", weekday: .tuesdayAndFriday)
    static let light: TalentMaterial = .init(imageString: "talent.Light", localizedName: "「天光」", weekday: .wednesdayAndSaturday)

    // 须弥
    static let admonition: TalentMaterial = .init(imageString: "talent.Admonition", localizedName: "「诤言」", weekday: .mondayAndThursday)
    static let ingenuity: TalentMaterial = .init(imageString: "talent.Ingenuity", localizedName: "「巧思」", weekday: .tuesdayAndFriday)
    static let praxis: TalentMaterial = .init(imageString: "talent.Praxis", localizedName: "「笃行」", weekday: .wednesdayAndSaturday)
}
