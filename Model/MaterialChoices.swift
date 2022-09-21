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
    static let decarabian: WeaponOrTalentMaterial = .init(imageString: "weapon.Decarabian", localizedName: "「高塔孤王」", weekday: .mondayAndThursday)
    static let borealWolf: WeaponOrTalentMaterial = .init(imageString: "weapon.BorealWolf", localizedName: "「凛风奔狼」", weekday: .tuesdayAndFriday,
                                                          relatedItem: [
                                                            .init(imageString: "UI_EquipIcon_Catalyst_Dvalin_Awaken", localizedName: "天空之卷"),
                                                            .init(imageString: "UI_EquipIcon_Sword_Dvalin_Awaken", localizedName: "天空之刃"),
                                                            .init(imageString: "UI_EquipIcon_Bow_Dvalin_Awaken", localizedName: "天空之翼"),
                                                            .init(imageString: "UI_EquipIcon_Bow_Widsith_Awaken", localizedName: "终末嗟叹之诗"),
                                                            .init(imageString: "UI_EquipIcon_Catalyst_Troupe_Awaken", localizedName: "流浪乐章"),
                                                            .init(imageString: "UI_EquipIcon_Bow_Fossil_Awaken", localizedName: "祭礼弓"),
                                                            .init(imageString: "UI_EquipIcon_Sword_Troupe_Awaken", localizedName: "笛剑"),
                                                            .init(imageString: "UI_EquipIcon_Claymore_Fossil_Awaken", localizedName: "祭礼大剑"),
                                                            .init(imageString: "UI_EquipIcon_Sword_Bloodstained_Awaken", localizedName: "黑剑"),
                                                            .init(imageString: "UI_EquipIcon_Pole_Gladiator_Awaken", localizedName: "决斗之枪"),
                                                            .init(imageString: "UI_EquipIcon_Pole_Everfrost_Awaken", localizedName: "龙脊长枪"),
                                                            .init(imageString: "UI_EquipIcon_Catalyst_Outlaw_Awaken", localizedName: "暗巷的酒与诗"),
                                                            .init(imageString: "UI_EquipIcon_Catalyst_Ludiharpastum_Awaken", localizedName: "嘟嘟可故事集"),
                                                            .init(imageString: "UI_EquipIcon_Sword_Psalmus_Awaken", localizedName: "降临之剑"),
                                                          ]
    )
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
    static let freedom: WeaponOrTalentMaterial = .init(imageString: "talent.Freedom", localizedName: "「自由」", weekday: .mondayAndThursday,
                                                       relatedItem: [
                                                        .init(imageString: "UI_AvatarIcon_Barbara_Card", localizedName: "芭芭拉"),
                                                        .init(imageString: "UI_AvatarIcon_Ambor_Card", localizedName: "安柏"),
                                                        .init(imageString: "UI_AvatarIcon_Klee_Card", localizedName: "可莉"),
                                                        .init(imageString: "UI_AvatarIcon_Tartaglia_Card", localizedName: "达达利亚"),
                                                        .init(imageString: "UI_AvatarIcon_Diona_Card", localizedName: "迪奥娜"),
                                                        .init(imageString: "UI_AvatarIcon_Sucrose_Card", localizedName: "砂糖"),
                                                        .init(imageString: "UI_AvatarIcon_Aloy_Card", localizedName: "埃洛伊"),
                                                       ]
    )
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
    static let ballad: WeaponOrTalentMaterial = .init(imageString: "talent.Ballad", localizedName: "「诗文」", weekday: .wednesdayAndSaturday,
                                                      relatedItem: [
                                                       .init(imageString: "UI_AvatarIcon_Lisa_Card", localizedName: "丽莎"),
                                                       .init(imageString: "UI_AvatarIcon_Fischl_Card", localizedName: "菲谢尔"),
                                                       .init(imageString: "UI_AvatarIcon_Kaeya_Card", localizedName: "凯亚"),
                                                       .init(imageString: "UI_AvatarIcon_Venti_Card", localizedName: "温迪"),
                                                       .init(imageString: "UI_AvatarIcon_Albedo_Card", localizedName: "阿贝多"),
                                                       .init(imageString: "UI_AvatarIcon_Rosaria_Card", localizedName: "罗莎莉亚"),
                                                      ])

    // 璃月
    static let prosperity: WeaponOrTalentMaterial = .init(imageString: "talent.Prosperity", localizedName: "「繁荣」", weekday: .mondayAndThursday,
                                                          relatedItem: [
                                                            .init(imageString: "UI_AvatarIcon_Xiao_Card", localizedName: "魈"),
                                                            .init(imageString: "UI_AvatarIcon_Ningguang_Card", localizedName: "凝光"),
                                                            .init(imageString: "UI_AvatarIcon_Qiqi_Card", localizedName: "七七"),
                                                            .init(imageString: "UI_AvatarIcon_Keqing_Card", localizedName: "刻晴"),
                                                            .init(imageString: "UI_AvatarIcon_Yelan_Card", localizedName: "夜兰"),
                                                            .init(imageString: "UI_AvatarIcon_Shenhe_Card", localizedName: "申鹤"),
                                                          ]
    )
    static let diligence: WeaponOrTalentMaterial = .init(imageString: "talent.Diligence", localizedName: "「勤劳」", weekday: .tuesdayAndFriday,
                                                         relatedItem: [
                                                            .init(imageString: "UI_AvatarIcon_Xiangling_Card", localizedName: "香菱"),
                                                            .init(imageString: "UI_AvatarIcon_Chongyun_Card", localizedName: "重云"),
                                                            .init(imageString: "UI_AvatarIcon_Ganyu_Card", localizedName: "甘雨"),
                                                            .init(imageString: "UI_AvatarIcon_Hutao_Card", localizedName: "胡桃"),
                                                            .init(imageString: "UI_AvatarIcon_Kazuha_Card", localizedName: "枫原万叶"),
                                                            .init(imageString: "UI_AvatarIcon_Yunjin_Card", localizedName: "云堇"),
                                                         ]
    )
    static let gold: WeaponOrTalentMaterial = .init(imageString: "talent.Gold", localizedName: "「黄金」", weekday: .wednesdayAndSaturday,
                                                    relatedItem: [
                                                        .init(imageString: "UI_AvatarIcon_Beidou_Card", localizedName: "北斗"),
                                                        .init(imageString: "UI_AvatarIcon_Xingqiu_Card", localizedName: "行秋"),
                                                        .init(imageString: "UI_AvatarIcon_Zhongli_Card", localizedName: "钟离"),
                                                        .init(imageString: "UI_AvatarIcon_Xinyan_Card", localizedName: "辛焱"),
                                                        .init(imageString: "UI_AvatarIcon_Feiyan_Card", localizedName: "烟绯"),
                                                    ]
    )

    // 稻妻
    static let transience: WeaponOrTalentMaterial = .init(imageString: "talent.Transience", localizedName: "「浮世」", weekday: .mondayAndThursday,
                                                          relatedItem: [
                                                              .init(imageString: "UI_AvatarIcon_Yoimiya_Card", localizedName: "宵宫"),
                                                              .init(imageString: "UI_AvatarIcon_Tohma_Card", localizedName: "托马"),
                                                              .init(imageString: "UI_AvatarIcon_Kokomi_Card", localizedName: "珊瑚宫心海"),
                                                              .init(imageString: "UI_AvatarIcon_Heizo_Card", localizedName: "鹿野院平藏"),
                                                          ]
    )
    static let elegance: WeaponOrTalentMaterial = .init(imageString: "talent.Elegance", localizedName: "「风雅」", weekday: .tuesdayAndFriday,
                                                        relatedItem: [
                                                            .init(imageString: "UI_AvatarIcon_Sara_Card", localizedName: "九条裟罗"),
                                                            .init(imageString: "UI_AvatarIcon_Ayaka_Card", localizedName: "神里绫华"),
                                                            .init(imageString: "UI_AvatarIcon_Itto_Card", localizedName: "荒泷一斗"),
                                                            .init(imageString: "UI_AvatarIcon_Shinobu_Card", localizedName: "久岐忍"),
                                                            .init(imageString: "UI_AvatarIcon_Ayato_Card", localizedName: "神里绫人"),
                                                        ]
    )
    static let light: WeaponOrTalentMaterial = .init(imageString: "talent.Light", localizedName: "「天光」", weekday: .wednesdayAndSaturday,
                                                     relatedItem: [
                                                         .init(imageString: "UI_AvatarIcon_Shougun_Card", localizedName: "雷电将军"),
                                                         .init(imageString: "UI_AvatarIcon_Sayu_Card", localizedName: "早柚"),
                                                         .init(imageString: "UI_AvatarIcon_Gorou_Card", localizedName: "五郎"),
                                                         .init(imageString: "UI_AvatarIcon_Yae_Card", localizedName: "八重神子"),
                                                     ]
    )

    // 须弥
    static let admonition: WeaponOrTalentMaterial = .init(imageString: "talent.Admonition", localizedName: "「诤言」", weekday: .mondayAndThursday,
                                                          relatedItem: [
                                                            .init(imageString: "UI_AvatarIcon_Tighnari_Card", localizedName: "提纳里"),
                                                            .init(imageString: "UI_AvatarIcon_Candace_Card", localizedName: "坎蒂丝"),
                                                            .init(imageString: "UI_AvatarIcon_Cyno_Card", localizedName: "赛诺")
                                                          ]
    )
    static let ingenuity: WeaponOrTalentMaterial = .init(imageString: "talent.Ingenuity", localizedName: "「巧思」", weekday: .tuesdayAndFriday,
                                                         relatedItem: [
                                                           .init(imageString: "UI_AvatarIcon_Dori_Card", localizedName: "多莉")
                                                         ]
    )
    static let praxis: WeaponOrTalentMaterial = .init(imageString: "talent.Praxis", localizedName: "「笃行」", weekday: .wednesdayAndSaturday,
                                                      relatedItem: [
                                                        .init(imageString: "UI_AvatarIcon_Collei_Card", localizedName: "柯莱"),
                                                        .init(imageString: "UI_AvatarIcon_Nilou_Card", localizedName: "妮露")
                                                      ]
    )

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
