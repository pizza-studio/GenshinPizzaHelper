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
        nameToLocalize: "「高塔孤王」",
        weekday: .mondayAndThursday,
        relatedItem: [
            .init(weapon: .MitternachtsWaltz),
            .init(weapon: .TheStringless),
            .init(weapon: .TheViridescentHunt),
            .init(weapon: .RoyalGrimoire),
            .init(weapon: .FavoniusCodex),
            .init(weapon: .SnowTombedStarsilver),
            .init(weapon: .TheBell),
            .init(weapon: .SongOfBrokenPines),
            .init(weapon: .WolfFang),
            .init(weapon: .AquilaFavonia),
            .init(weapon: .CinnabarSpindle),
            .init(weapon: .TheAlleyFlash),
            .init(weapon: .RoyalLongsword),
            .init(weapon: .FavoniusSword),
        ]
    )
    static let borealWolf: WeaponOrTalentMaterial = .init(
        imageString: "weapon.BorealWolf",
        nameToLocalize: "「凛风奔狼」",
        weekday: .tuesdayAndFriday,
        relatedItem: [
            .init(weapon: .SkywardHarp),
            .init(weapon: .SacrificialBow),
            .init(weapon: .ElegyForTheEnd),
            .init(weapon: .BalladOfTheBoundlessBlue),
            .init(weapon: .SkywardAtlas),
            .init(weapon: .DodocoTales),
            .init(weapon: .WineAndSong),
            .init(weapon: .TheWidsith),
            .init(weapon: .SkywardPride),
            .init(weapon: .SacrificialGreatsword),
            .init(weapon: .DragonspineSpear),
            .init(weapon: .Deathmatch),
            .init(weapon: .MissiveWindspear),
            .init(weapon: .TheBlackSword),
            .init(weapon: .SkywardBlade),
            .init(weapon: .SwordOfDescension),
            .init(weapon: .TheFlute),
        ]
    )
    static let dandelionGladiator: WeaponOrTalentMaterial = .init(
        imageString: "weapon.DandelionGladiator",
        nameToLocalize: "「狮牙斗士」",
        weekday: .wednesdayAndSaturday,
        relatedItem: [
            .init(weapon: .AmosBow),
            .init(weapon: .CompoundBow),
            .init(weapon: .AlleyHunter),
            .init(weapon: .RoyalBow),
            .init(weapon: .FavoniusWarbow),
            .init(weapon: .Frostbearer),
            .init(weapon: .SacrificialFragments),
            .init(weapon: .LostPrayerToTheSacredWinds),
            .init(weapon: .MailedFlower),
            .init(weapon: .RoyalGreatsword),
            .init(weapon: .WolfsGravestone),
            .init(weapon: .FavoniusGreatsword),
            .init(weapon: .SkywardSpine),
            .init(weapon: .FavoniusLance),
            .init(weapon: .SacrificialSword),
            .init(weapon: .FesteringDesire),
            .init(weapon: .FreedomSworn),
        ]
    )

    // 璃月
    static let guyun: WeaponOrTalentMaterial = .init(
        imageString: "weapon.Guyun",
        nameToLocalize: "「孤云寒林」",
        weekday: .mondayAndThursday,
        relatedItem: [
            .init(weapon: .BlackcliffWarbow),
            .init(weapon: .AquaSimulacra),
            .init(weapon: .Rust),
            .init(weapon: .BlackcliffAgate),
            .init(weapon: .JadefallsSplendor),
            .init(weapon: .SolarPearl),
            .init(weapon: .SacrificialJade),
            .init(weapon: .Whiteblind),
            .init(weapon: .LithicBlade),
            .init(weapon: .CrescentPike),
            .init(weapon: .PrimordialJadeWingedSpear),
            .init(weapon: .BlackcliffLongsword),
            .init(weapon: .SummitShaper),
            .init(weapon: .LionsRoar),
        ]
    )
    static let mistVeiled: WeaponOrTalentMaterial = .init(
        imageString: "weapon.MistVeiled",
        nameToLocalize: "「雾海云间」",
        weekday: .tuesdayAndFriday,
        relatedItem: [
            .init(weapon: .PrototypeAmber),
            .init(weapon: .EyeOfPerception),
            .init(weapon: .BlackcliffSlasher),
            .init(weapon: .TheUnforged),
            .init(weapon: .Rainslasher),
            .init(weapon: .BlackcliffPole),
            .init(weapon: .CalamityQueller),
            .init(weapon: .DragonsBane),
            .init(weapon: .RoyalSpear),
            .init(weapon: .PrimordialJadeCutter),
            .init(weapon: .PrototypeRancour),
        ]
    )
    static let aerosiderite: WeaponOrTalentMaterial = .init(
        imageString: "weapon.Aerosiderite",
        nameToLocalize: "「漆黑陨铁」",
        weekday: .wednesdayAndSaturday,
        relatedItem: [
            .init(weapon: .CompoundBow),
            .init(weapon: .FadingTwilight),
            .init(weapon: .MappaMare),
            .init(weapon: .MemoryOfDust),
            .init(weapon: .SerpentSpine),
            .init(weapon: .LuxuriousSeaLord),
            .init(weapon: .PrototypeArchaic),
            .init(weapon: .StaffOfHoma),
            .init(weapon: .VortexVanquisher),
            .init(weapon: .LithicSpear),
            .init(weapon: .PrototypeStarglitter),
            .init(weapon: .IronSting),
        ]
    )

    // 稻妻
    static let distantSea: WeaponOrTalentMaterial = .init(
        imageString: "weapon.DistantSea",
        nameToLocalize: "「远海夷地」",
        weekday: .mondayAndThursday,
        relatedItem: [
            .init(weapon: .HakushinRing),
            .init(weapon: .OathswornEye),
            .init(weapon: .EverlastingMoonglow),
            .init(weapon: .Akuoumaru),
            .init(weapon: .AmenomaKageuchi),
            .init(weapon: .MistsplitterReforged),
        ]
    )
    static let narukami: WeaponOrTalentMaterial = .init(
        imageString: "weapon.Narukami",
        nameToLocalize: "「鸣神御灵」",
        weekday: .tuesdayAndFriday,
        relatedItem: [
            .init(weapon: .Hamayumi),
            .init(weapon: .MouunsMoon),
            .init(weapon: .ThunderingPulse),
            .init(weapon: .Predator),
            .init(weapon: .KatsuragikiriNagamasa),
            .init(weapon: .RedhornStonethresher),
            .init(weapon: .HaranGeppakuFutsu),
            .init(weapon: .ToukabouShigure),
        ]
    )
    static let kijin: WeaponOrTalentMaterial = .init(
        imageString: "weapon.Kijin",
        nameToLocalize: "「今昔剧画」",
        weekday: .wednesdayAndSaturday,
        relatedItem: [
            .init(weapon: .PolarStar),
            .init(weapon: .KagurasVerity),
            .init(weapon: .KitainCrossSpear),
            .init(weapon: .WavebreakersFin),
            .init(weapon: .TheCatch),
            .init(weapon: .EngulfingLightning),
            .init(weapon: .KagotsurubeIsshin),
        ]
    )

    // 须弥
    static let forestDew: WeaponOrTalentMaterial = .init(
        imageString: "weapon.ForestDew",
        nameToLocalize: "「谧林涓露」",
        weekday: .mondayAndThursday,
        relatedItem: [
            .init(weapon: .IbisPiercer),
            .init(weapon: .ForestRegalia),
            .init(weapon: .SapwoodBlade),
            .init(weapon: .LightOfFoliarIncision),
            .init(weapon: .KeyOfKhajNisut),
            .init(weapon: .XiphosMoonlight),
        ]
    )
    static let oasisGarden: WeaponOrTalentMaterial = .init(
        imageString: "weapon.OasisGarden",
        nameToLocalize: "「绿洲花园」",
        weekday: .tuesdayAndFriday,
        relatedItem: [
            .init(weapon: .FruitOfFulfillment),
            .init(weapon: .AThousandFloatingDreams),
            .init(weapon: .WanderingEvenstar),
            .init(weapon: .TalkingStick),
            .init(weapon: .Moonpiercer),
            .init(weapon: .StaffOfTheScarletSands),
        ]
    )
    static let scorchingMight: WeaponOrTalentMaterial = .init(
        imageString: "weapon.ScorchingMight",
        nameToLocalize: "「烈日威权」",
        weekday: .wednesdayAndSaturday,
        relatedItem: [
            .init(weapon: .KingsSquire),
            .init(weapon: .HuntersPath),
            .init(weapon: .EndOfTheLine),
            .init(weapon: .ScionOfTheBlazingSun),
            .init(weapon: .TulaytullahsRemembrance),
            .init(weapon: .BeaconOfTheReedSea),
            .init(weapon: .MakhairaAquamarine),
        ]
    )

    // 枫丹
    static let chord: WeaponOrTalentMaterial = .init(
        imageString: "weapon.Chord",
        nameToLocalize: "「悠古弦音」",
        weekday: .mondayAndThursday,
        relatedItem: [
            .init(weapon: .RangeGauge),
            .init(weapon: .TheFirstGreatMagic),
            .init(weapon: .SongOfStillness),
            .init(weapon: .ProspectorsDrill),
            .init(weapon: .FleuveCendreFerryman),
            .init(weapon: .SwordOfNarzissenkreuz),
            // 下述武器等 4.2 再开放显示，否则会有公然泄密之虞。
            // .init(weapon: .SwordOfNarzissenkreuz),
        ]
    )
    static let dewdrop: WeaponOrTalentMaterial = .init(
        imageString: "weapon.Dewdrop",
        nameToLocalize: "「纯圣露滴」",
        weekday: .tuesdayAndFriday,
        relatedItem: [
            .init(weapon: .TomeOfTheEternalFlow),
            .init(weapon: .FlowingPurity),
            .init(weapon: .TheDockhandsAssistant),
            .init(weapon: .SplendorOfStillWaters),
            .init(weapon: .FinaleOfTheDeep),
            // 下述武器等 4.2 再开放显示，否则会有公然泄密之虞。
            .init(weapon: .SplendorOfStillWaters),
        ]
    )
    static let goblet: WeaponOrTalentMaterial = .init(
        imageString: "weapon.Goblet",
        nameToLocalize: "「无垢之海」",
        weekday: .wednesdayAndSaturday,
        relatedItem: [
            .init(weapon: .CashflowSupervision),
            .init(weapon: .PortablePowerSaw),
            .init(weapon: .TidalShadow),
            .init(weapon: .BalladOfTheFjords),
            .init(weapon: .RightfulReward),
        ]
    )

    // 所有材料
    static let allWeaponMaterials: [WeaponOrTalentMaterial] = [
        .decarabian, .borealWolf, .dandelionGladiator, .guyun, .mistVeiled,
        .aerosiderite, .distantSea, .narukami, .kijin, .forestDew,
        .oasisGarden, .scorchingMight, .chord, .dewdrop, .goblet,
    ]
    static func allWeaponMaterialsOf(weekday: MaterialWeekday)
        -> [WeaponOrTalentMaterial] {
        allWeaponMaterials.filter { material in
            (material.weekday == weekday) || (weekday == .sunday)
        }
    }

    static let dumpedWeaponIconMap: [String: String] = {
        var mapOutput = [String: String]()
        allWeaponMaterials.forEach { theMaterial in
            theMaterial.relatedItem.forEach { theItem in
                mapOutput[theItem.nameToLocalize] = theItem.imageString
            }
        }
        return mapOutput
    }()

    // MARK: - Talent Material choices

    // 蒙德
    static let freedom: WeaponOrTalentMaterial = .init(
        imageString: "talent.Freedom",
        nameToLocalize: "「自由」",
        weekday: .mondayAndThursday,
        relatedItem: [
            .init(character: .Aloy),
            .init(character: .Amber),
            .init(character: .Barbara),
            .init(character: .Diona),
            .init(character: .Klee),
            .init(character: .Sucrose),
            .init(character: .Tartaglia),
        ]
    )
    static let resistance: WeaponOrTalentMaterial = .init(
        imageString: "talent.Resistance",
        nameToLocalize: "「抗争」",
        weekday: .tuesdayAndFriday,
        relatedItem: [
            .init(character: .Bennett),
            .init(character: .Diluc),
            .init(character: .Eula),
            .init(character: .Mona),
            .init(character: .Noelle),
            .init(character: .Jean),
            .init(character: .Razor),
        ]
    )
    static let ballad: WeaponOrTalentMaterial = .init(
        imageString: "talent.Ballad",
        nameToLocalize: "「诗文」",
        weekday: .wednesdayAndSaturday,
        relatedItem: [
            .init(character: .Albedo),
            .init(character: .Fischl),
            .init(character: .Kaeya),
            .init(character: .Lisa),
            .init(character: .Mika),
            .init(character: .Rosaria),
            .init(character: .Venti),
        ]
    )

    // 璃月
    static let prosperity: WeaponOrTalentMaterial = .init(
        imageString: "talent.Prosperity",
        nameToLocalize: "「繁荣」",
        weekday: .mondayAndThursday,
        relatedItem: [
            .init(character: .Keqing),
            .init(character: .Ningguang),
            .init(character: .Qiqi),
            .init(character: .Shenhe),
            .init(character: .Xiao),
            .init(character: .Yelan),
        ]
    )
    static let diligence: WeaponOrTalentMaterial = .init(
        imageString: "talent.Diligence",
        nameToLocalize: "「勤劳」",
        weekday: .tuesdayAndFriday,
        relatedItem: [
            .init(character: .Chongyun),
            .init(character: .Ganyu),
            .init(character: .Hutao),
            .init(character: .Kazuha),
            .init(character: .Xiangling),
            .init(character: .Yaoyao),
            .init(character: .Yunjin),
        ]
    )
    static let gold: WeaponOrTalentMaterial = .init(
        imageString: "talent.Gold",
        nameToLocalize: "「黄金」",
        weekday: .wednesdayAndSaturday,
        relatedItem: [
            .init(character: .Baizhu),
            .init(character: .Beidou),
            .init(character: .Yanfei),
            .init(character: .Xingqiu),
            .init(character: .Xinyan),
            .init(character: .Zhongli),
        ]
    )

    // 稻妻
    static let transience: WeaponOrTalentMaterial = .init(
        imageString: "talent.Transience",
        nameToLocalize: "「浮世」",
        weekday: .mondayAndThursday,
        relatedItem: [
            .init(character: .Heizo),
            .init(character: .Kokomi),
            .init(character: .Kirara),
            .init(character: .Thoma),
            .init(character: .Yoimiya),
        ]
    )
    static let elegance: WeaponOrTalentMaterial = .init(
        imageString: "talent.Elegance",
        nameToLocalize: "「风雅」",
        weekday: .tuesdayAndFriday,
        relatedItem: [
            .init(character: .Ayaka),
            .init(character: .Ayato),
            .init(character: .Itto),
            .init(character: .Sara),
            .init(character: .Shinobu),
        ]
    )
    static let light: WeaponOrTalentMaterial = .init(
        imageString: "talent.Light",
        nameToLocalize: "「天光」",
        weekday: .wednesdayAndSaturday,
        relatedItem: [
            .init(character: .Gorou),
            .init(character: .Sayu),
            .init(character: .Ei),
            .init(character: .Miko),
        ]
    )

    // 须弥
    static let admonition: WeaponOrTalentMaterial = .init(
        imageString: "talent.Admonition",
        nameToLocalize: "「诤言」",
        weekday: .mondayAndThursday,
        relatedItem: [
            .init(character: .Candace),
            .init(character: .Cyno),
            .init(character: .Faruzan),
            .init(character: .Tighnari),
        ]
    )
    static let ingenuity: WeaponOrTalentMaterial = .init(
        imageString: "talent.Ingenuity",
        nameToLocalize: "「巧思」",
        weekday: .tuesdayAndFriday,
        relatedItem: [
            .init(character: .Alhaitham),
            .init(character: .Dori),
            .init(character: .Kaveh),
            .init(character: .Layla),
            .init(character: .Nahida),
        ]
    )
    static let praxis: WeaponOrTalentMaterial = .init(
        imageString: "talent.Praxis",
        nameToLocalize: "「笃行」",
        weekday: .wednesdayAndSaturday,
        relatedItem: [
            .init(character: .Collei),
            .init(character: .Dehya),
            .init(character: .Nilou),
            .init(character: .Kunikuzushi),
        ]
    )

    // 枫丹
    static let kouhei: WeaponOrTalentMaterial = .init(
        imageString: "talent.Kouhei",
        nameToLocalize: "「公平」",
        weekday: .mondayAndThursday,
        relatedItem: [
            .init(character: .Lyney),
            .init(character: .Neuvillette),
        ]
    )
    static let seigi: WeaponOrTalentMaterial = .init(
        imageString: "talent.Seigi",
        nameToLocalize: "「正义」",
        weekday: .tuesdayAndFriday,
        relatedItem: [
            .init(character: .Freminet),
            // 下述角色等 4.2 再开放显示，否则会有公然泄密之虞。
            // .init(character: .Charlotte),
            // .init(character: .Furina),
        ]
    )
    static let chitsujo: WeaponOrTalentMaterial = .init(
        imageString: "talent.Chitsujo",
        nameToLocalize: "「秩序」",
        weekday: .wednesdayAndSaturday,
        relatedItem: [
            .init(character: .Lynette),
            .init(character: .Wriothesley),
        ]
    )

    // 所有天赋材料
    static let allTalentMaterials: [WeaponOrTalentMaterial] = [
        .freedom, .resistance, .ballad, .prosperity, .diligence, .gold,
        .transience, .elegance, .light, .admonition, .ingenuity, .praxis,
        .kouhei, .seigi, .chitsujo,
    ]
    static func allTalentMaterialsOf(weekday: MaterialWeekday)
        -> [WeaponOrTalentMaterial] {
        allTalentMaterials.filter { material in
            (material.weekday == weekday) || (weekday == .sunday)
        }
    }
}
