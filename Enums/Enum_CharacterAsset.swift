//
//  CharacterAssets.swift
//  GenshinPizzaHepler
//
//  Created by ShikiSuen on 2023/10/3.
//

import Defaults
import Foundation
import HBMihoyoAPI
import HBPizzaHelperAPI
import SwiftUI

// MARK: - CharacterAsset

/// 原神名片清单，按照 Ambr.top 网页陈列顺序排列。
public enum CharacterAsset: Int, CaseIterable {
    case Paimon = -114_514
    case Hotaru = 10000007
    case Sora = 10000005
    case Sucrose = 10000043
    case Keqing = 10000042
    case Mona = 10000041
    case Chongyun = 10000036
    case Qiqi = 10000035
    case Noelle = 10000034
    case Bennett = 10000032
    case Fischl = 10000031
    case Klee = 10000029
    case Ningguang = 10000027
    case Xingqiu = 10000025
    case Beidou = 10000024
    case Xiangling = 10000023
    case Venti = 10000022
    case Amber = 10000021
    case Razor = 10000020
    case Diluc = 10000016
    case Kaeya = 10000015
    case Barbara = 10000014
    case Lisa = 10000006
    case Jean = 10000003
    case Diona = 10000039
    case Tartaglia = 10000033
    case Xinyan = 10000044
    case Zhongli = 10000030
    case Albedo = 10000038
    case Ganyu = 10000037
    case Xiao = 10000026
    case Hutao = 10000046
    case Rosaria = 10000045
    case Yanfei = 10000048
    case Eula = 10000051
    case Kazuha = 10000047
    case Ayaka = 10000002
    case Sayu = 10000053
    case Yoimiya = 10000049
    case Aloy = 10000062
    case Sara = 10000056
    case Ei = 10000052
    case Kokomi = 10000054
    case Thoma = 10000050
    case Itto = 10000057
    case Gorou = 10000055
    case Yunjin = 10000064
    case Shenhe = 10000063
    case Miko = 10000058
    case Ayato = 10000066
    case Yelan = 10000060
    case Shinobu = 10000065
    case Heizou = 10000059
    case Tighnari = 10000069
    case Collei = 10000067
    case Dori = 10000068
    case Candace = 10000072
    case Cyno = 10000071
    case Nilou = 10000070
    case Nahida = 10000073
    case Layla = 10000074
    case Faruzan = 10000076
    case Kunikuzushi = 10000075
    case Alhaitham = 10000078
    case Yaoyao = 10000077
    case Dehya = 10000079
    case Mika = 10000080
    case Baizhu = 10000082
    case Kaveh = 10000081
    case Kirara = 10000061
    case Lyney = 10000084
    case Lynette = 10000083
    case Freminet = 10000085
    case Neuvillette = 10000087
    case Wriothesley = 10000086
    case Charlotte = 10000088
    case Furina = 10000089
}

extension CharacterAsset {
    public var enkaId: Int { rawValue }

    public static var fallbackedValue: CharacterAsset { .Paimon }

    public static func match(id: Int) -> CharacterAsset {
        .init(rawValue: id) ?? .Paimon
    }

    public var localizedKey: String {
        var raw = String(describing: self)
        if Defaults[.useActualCharacterNames], self == .Kunikuzushi {
            raw = "Raiden" + raw
        }
        return "$asset.character:" + raw
    }

    public var localized: String {
        if Defaults[.useActualCharacterNames], self == .Kunikuzushi {
            return localizedKey.localized
        }
        return localizedKey.localized.localizedWithFix
    }
}

extension CharacterAsset {
    public var officialRawNameInEnglish: String {
        ("$asset.character:" + String(describing: self)).i18n("en")
    }

    public var officialSimplifiedChineseName: String {
        ("$asset.character:" + String(describing: self)).i18n("zh-Hans")
    }
}

extension CharacterAsset {
    public var frontPhotoFileName: String {
        switch self {
        case .Paimon: return "UI_AvatarIcon_Paimon"
        case .Hotaru: return "UI_AvatarIcon_PlayerGirl"
        case .Sora: return "UI_AvatarIcon_PlayerBoy"
        case .Sucrose: return "UI_AvatarIcon_Sucrose"
        case .Keqing: return "UI_AvatarIcon_Keqing"
        case .Mona: return "UI_AvatarIcon_Mona"
        case .Chongyun: return "UI_AvatarIcon_Chongyun"
        case .Qiqi: return "UI_AvatarIcon_Qiqi"
        case .Noelle: return "UI_AvatarIcon_Noel"
        case .Bennett: return "UI_AvatarIcon_Bennett"
        case .Fischl: return "UI_AvatarIcon_Fischl"
        case .Klee: return "UI_AvatarIcon_Klee"
        case .Ningguang: return "UI_AvatarIcon_Ningguang"
        case .Xingqiu: return "UI_AvatarIcon_Xingqiu"
        case .Beidou: return "UI_AvatarIcon_Beidou"
        case .Xiangling: return "UI_AvatarIcon_Xiangling"
        case .Venti: return "UI_AvatarIcon_Venti"
        case .Amber: return "UI_AvatarIcon_Ambor"
        case .Razor: return "UI_AvatarIcon_Razor"
        case .Diluc: return "UI_AvatarIcon_Diluc"
        case .Kaeya: return "UI_AvatarIcon_Kaeya"
        case .Barbara: return "UI_AvatarIcon_Barbara"
        case .Lisa: return "UI_AvatarIcon_Lisa"
        case .Jean: return "UI_AvatarIcon_Qin"
        case .Diona: return "UI_AvatarIcon_Diona"
        case .Tartaglia: return "UI_AvatarIcon_Tartaglia"
        case .Xinyan: return "UI_AvatarIcon_Xinyan"
        case .Zhongli: return "UI_AvatarIcon_Zhongli"
        case .Albedo: return "UI_AvatarIcon_Albedo"
        case .Ganyu: return "UI_AvatarIcon_Ganyu"
        case .Xiao: return "UI_AvatarIcon_Xiao"
        case .Hutao: return "UI_AvatarIcon_Hutao"
        case .Rosaria: return "UI_AvatarIcon_Rosaria"
        case .Yanfei: return "UI_AvatarIcon_Feiyan"
        case .Eula: return "UI_AvatarIcon_Eula"
        case .Kazuha: return "UI_AvatarIcon_Kazuha"
        case .Ayaka: return "UI_AvatarIcon_Ayaka"
        case .Sayu: return "UI_AvatarIcon_Sayu"
        case .Yoimiya: return "UI_AvatarIcon_Yoimiya"
        case .Aloy: return "UI_AvatarIcon_Aloy"
        case .Sara: return "UI_AvatarIcon_Sara"
        case .Ei: return "UI_AvatarIcon_Shougun"
        case .Kokomi: return "UI_AvatarIcon_Kokomi"
        case .Thoma: return "UI_AvatarIcon_Tohma"
        case .Itto: return "UI_AvatarIcon_Itto"
        case .Gorou: return "UI_AvatarIcon_Gorou"
        case .Yunjin: return "UI_AvatarIcon_Yunjin"
        case .Shenhe: return "UI_AvatarIcon_Shenhe"
        case .Miko: return "UI_AvatarIcon_Yae"
        case .Ayato: return "UI_AvatarIcon_Ayato"
        case .Yelan: return "UI_AvatarIcon_Yelan"
        case .Shinobu: return "UI_AvatarIcon_Shinobu"
        case .Heizou: return "UI_AvatarIcon_Heizo"
        case .Tighnari: return "UI_AvatarIcon_Tighnari"
        case .Collei: return "UI_AvatarIcon_Collei"
        case .Dori: return "UI_AvatarIcon_Dori"
        case .Candace: return "UI_AvatarIcon_Candace"
        case .Cyno: return "UI_AvatarIcon_Cyno"
        case .Nilou: return "UI_AvatarIcon_Nilou"
        case .Nahida: return "UI_AvatarIcon_Nahida"
        case .Layla: return "UI_AvatarIcon_Layla"
        case .Faruzan: return "UI_AvatarIcon_Faruzan"
        case .Kunikuzushi: return "UI_AvatarIcon_Wanderer"
        case .Alhaitham: return "UI_AvatarIcon_Alhatham"
        case .Yaoyao: return "UI_AvatarIcon_Yaoyao"
        case .Dehya: return "UI_AvatarIcon_Dehya"
        case .Mika: return "UI_AvatarIcon_Mika"
        case .Baizhu: return "UI_AvatarIcon_Baizhuer"
        case .Kaveh: return "UI_AvatarIcon_Kaveh"
        case .Kirara: return "UI_AvatarIcon_Momoka"
        case .Lyney: return "UI_AvatarIcon_Liney"
        case .Lynette: return "UI_AvatarIcon_Linette"
        case .Freminet: return "UI_AvatarIcon_Freminet"
        case .Neuvillette: return "UI_AvatarIcon_Neuvillette"
        case .Wriothesley: return "UI_AvatarIcon_Wriothesley"
        case .Charlotte: return "UI_AvatarIcon_Charlotte"
        case .Furina: return "UI_AvatarIcon_Furina"
        }
    }

    public var namecard: NameCard {
        if let costumeCard = Self.costumeMap[self]?.compatibleNamecard {
            return costumeCard
        }
        switch self {
        case .Paimon: return .UI_NameCardPic_0_P
        case .Hotaru: return .UI_NameCardPic_Bp2_P
        case .Sora: return .UI_NameCardPic_Bp2_P
        case .Sucrose: return .UI_NameCardPic_Sucrose_P
        case .Keqing: return .UI_NameCardPic_Keqing_P
        case .Mona: return .UI_NameCardPic_Mona_P
        case .Chongyun: return .UI_NameCardPic_Chongyun_P
        case .Qiqi: return .UI_NameCardPic_Qiqi_P
        case .Noelle: return .UI_NameCardPic_Noel_P
        case .Bennett: return .UI_NameCardPic_Bennett_P
        case .Fischl: return .UI_NameCardPic_Fischl_P
        case .Klee: return .UI_NameCardPic_Klee_P
        case .Ningguang: return .UI_NameCardPic_Ningguang_P
        case .Xingqiu: return .UI_NameCardPic_Xingqiu_P
        case .Beidou: return .UI_NameCardPic_Beidou_P
        case .Xiangling: return .UI_NameCardPic_Xiangling_P
        case .Venti: return .UI_NameCardPic_Venti_P
        case .Amber: return .UI_NameCardPic_Ambor_P
        case .Razor: return .UI_NameCardPic_Razor_P
        case .Diluc: return .UI_NameCardPic_Diluc_P
        case .Kaeya: return .UI_NameCardPic_Kaeya_P
        case .Barbara: return .UI_NameCardPic_Barbara_P
        case .Lisa: return .UI_NameCardPic_Lisa_P
        case .Jean: return .UI_NameCardPic_Qin_P
        case .Diona: return .UI_NameCardPic_Diona_P
        case .Tartaglia: return .UI_NameCardPic_Tartaglia_P
        case .Xinyan: return .UI_NameCardPic_Xinyan_P
        case .Zhongli: return .UI_NameCardPic_Zhongli_P
        case .Albedo: return .UI_NameCardPic_Albedo_P
        case .Ganyu: return .UI_NameCardPic_Ganyu_P
        case .Xiao: return .UI_NameCardPic_Xiao_P
        case .Hutao: return .UI_NameCardPic_Hutao_P
        case .Rosaria: return .UI_NameCardPic_Rosaria_P
        case .Yanfei: return .UI_NameCardPic_Feiyan_P
        case .Eula: return .UI_NameCardPic_Eula_P
        case .Kazuha: return .UI_NameCardPic_Kazuha_P
        case .Ayaka: return .UI_NameCardPic_Ayaka_P
        case .Sayu: return .UI_NameCardPic_Sayu_P
        case .Yoimiya: return .UI_NameCardPic_Yoimiya_P
        case .Aloy: return .UI_NameCardPic_Aloy_P
        case .Sara: return .UI_NameCardPic_Sara_P
        case .Ei: return .UI_NameCardPic_Shougun_P
        case .Kokomi: return .UI_NameCardPic_Kokomi_P
        case .Thoma: return .UI_NameCardPic_Tohma_P
        case .Itto: return .UI_NameCardPic_Itto_P
        case .Gorou: return .UI_NameCardPic_Gorou_P
        case .Yunjin: return .UI_NameCardPic_Yunjin_P
        case .Shenhe: return .UI_NameCardPic_Shenhe_P
        case .Miko: return .UI_NameCardPic_Yae1_P
        case .Ayato: return .UI_NameCardPic_Ayato_P
        case .Yelan: return .UI_NameCardPic_Yelan_P
        case .Shinobu: return .UI_NameCardPic_Shinobu_P
        case .Heizou: return .UI_NameCardPic_Heizo_P
        case .Tighnari: return .UI_NameCardPic_Tighnari_P
        case .Collei: return .UI_NameCardPic_Collei_P
        case .Dori: return .UI_NameCardPic_Dori_P
        case .Candace: return .UI_NameCardPic_Candace_P
        case .Cyno: return .UI_NameCardPic_Cyno_P
        case .Nilou: return .UI_NameCardPic_Nilou_P
        case .Nahida: return .UI_NameCardPic_Nahida_P
        case .Layla: return .UI_NameCardPic_Layla_P
        case .Faruzan: return .UI_NameCardPic_Faruzan_P
        case .Kunikuzushi: return .UI_NameCardPic_Wanderer_P
        case .Alhaitham: return .UI_NameCardPic_Alhatham_P
        case .Yaoyao: return .UI_NameCardPic_Yaoyao_P
        case .Dehya: return .UI_NameCardPic_Dehya_P
        case .Mika: return .UI_NameCardPic_Mika_P
        case .Baizhu: return .UI_NameCardPic_Baizhuer_P
        case .Kaveh: return .UI_NameCardPic_Kaveh_P
        case .Kirara: return .UI_NameCardPic_Kirara_P
        case .Lyney: return .UI_NameCardPic_Liney_P
        case .Lynette: return .UI_NameCardPic_Linette_P
        case .Freminet: return .UI_NameCardPic_Freminet_P
        case .Neuvillette: return .UI_NameCardPic_Neuvillette_P
        case .Wriothesley: return .UI_NameCardPic_Wriothesley_P
        case .Charlotte: return .UI_NameCardPic_Charlotte_P
        case .Furina: return .UI_NameCardPic_Furina_P
        }
    }
}

// MARK: - Profile Picture Data

extension CharacterAsset {
    public var possibleProfilePictureIdentifiers: [Int] {
        switch self {
        case .Paimon: return [rawValue]
        case .Hotaru: return [2]
        case .Sora: return [1]
        case .Sucrose: return [1400]
        case .Keqing: return [1900, 1901]
        case .Mona: return [1801, 1800]
        case .Chongyun: return [1300]
        case .Qiqi: return [1700]
        case .Noelle: return [1200]
        case .Bennett: return [1100]
        case .Fischl: return [1000, 1001]
        case .Klee: return [2100, 2101]
        case .Ningguang: return [900, 901]
        case .Xingqiu: return [800]
        case .Beidou: return [700]
        case .Xiangling: return [600]
        case .Venti: return [2000]
        case .Amber: return [100, 101]
        case .Razor: return [500]
        case .Diluc: return [1600, 1601]
        case .Kaeya: return [201, 200]
        case .Barbara: return [400, 401]
        case .Lisa: return [300, 301]
        case .Jean: return [1500, 1502, 1501]
        case .Diona: return [2200]
        case .Tartaglia: return [2300]
        case .Xinyan: return [2400]
        case .Zhongli: return [2500]
        case .Albedo: return [2600]
        case .Ganyu: return [2700]
        case .Xiao: return [2800]
        case .Hutao: return [2900]
        case .Rosaria: return [3001, 3000]
        case .Yanfei: return [3100]
        case .Eula: return [3200]
        case .Kazuha: return [3300]
        case .Ayaka: return [3400, 3401]
        case .Sayu: return [3500]
        case .Yoimiya: return [3600]
        case .Aloy: return [3700]
        case .Sara: return [3800]
        case .Ei: return [3900]
        case .Kokomi: return [4000]
        case .Thoma: return [4100]
        case .Itto: return [4300]
        case .Gorou: return [4200]
        case .Yunjin: return [4400]
        case .Shenhe: return [4500]
        case .Miko: return [4600]
        case .Ayato: return [4700]
        case .Yelan: return [4800]
        case .Shinobu: return [4900]
        case .Heizou: return [5000]
        case .Tighnari: return [5200]
        case .Collei: return [5100]
        case .Dori: return [5300]
        case .Candace: return [5400]
        case .Cyno: return [5500]
        case .Nilou: return [5600]
        case .Nahida: return [5700]
        case .Layla: return [5800]
        case .Faruzan: return [5900]
        case .Kunikuzushi: return [6000]
        case .Alhaitham: return [6200]
        case .Yaoyao: return [6100]
        case .Dehya: return [6300]
        case .Mika: return [6400]
        case .Baizhu: return [6600]
        case .Kaveh: return [6500]
        case .Kirara: return [6700]
        case .Lyney: return [6900]
        case .Lynette: return [6800]
        case .Freminet: return [7000]
        case .Neuvillette: return [7100]
        case .Wriothesley: return [7200]
        case .Charlotte: return [] // 原神 4.2
        case .Furina: return [] // 原神 4.2
        }
    }
}

// MARK: DailyMaterialConsumer

extension CharacterAsset: DailyMaterialConsumer {
    public var dailyMaterial: DailyMaterialAsset? {
        switch self {
        case .Paimon: return nil
        case .Hotaru: return nil
        case .Sora: return nil
        case .Sucrose: return .talentFreedom
        case .Keqing: return .talentProsperity
        case .Mona: return .talentResistance
        case .Chongyun: return .talentDiligence
        case .Qiqi: return .talentProsperity
        case .Noelle: return .talentResistance
        case .Bennett: return .talentResistance
        case .Fischl: return .talentBallad
        case .Klee: return .talentFreedom
        case .Ningguang: return .talentProsperity
        case .Xingqiu: return .talentGold
        case .Beidou: return .talentGold
        case .Xiangling: return .talentDiligence
        case .Venti: return .talentBallad
        case .Amber: return .talentFreedom
        case .Razor: return .talentResistance
        case .Diluc: return .talentResistance
        case .Kaeya: return .talentBallad
        case .Barbara: return .talentFreedom
        case .Lisa: return .talentBallad
        case .Jean: return .talentResistance
        case .Diona: return .talentFreedom
        case .Tartaglia: return .talentFreedom
        case .Xinyan: return .talentGold
        case .Zhongli: return .talentGold
        case .Albedo: return .talentBallad
        case .Ganyu: return .talentDiligence
        case .Xiao: return .talentProsperity
        case .Hutao: return .talentDiligence
        case .Rosaria: return .talentBallad
        case .Yanfei: return .talentGold
        case .Eula: return .talentResistance
        case .Kazuha: return .talentDiligence
        case .Ayaka: return .talentElegance
        case .Sayu: return .talentLight
        case .Yoimiya: return .talentTransience
        case .Aloy: return .talentFreedom
        case .Sara: return .talentElegance
        case .Ei: return .talentLight
        case .Kokomi: return .talentTransience
        case .Thoma: return .talentTransience
        case .Itto: return .talentElegance
        case .Gorou: return .talentLight
        case .Yunjin: return .talentDiligence
        case .Shenhe: return .talentProsperity
        case .Miko: return .talentLight
        case .Ayato: return .talentElegance
        case .Yelan: return .talentProsperity
        case .Shinobu: return .talentElegance
        case .Heizou: return .talentTransience
        case .Tighnari: return .talentAdmonition
        case .Collei: return .talentPraxis
        case .Dori: return .talentIngenuity
        case .Candace: return .talentAdmonition
        case .Cyno: return .talentAdmonition
        case .Nilou: return .talentPraxis
        case .Nahida: return .talentIngenuity
        case .Layla: return .talentIngenuity
        case .Faruzan: return .talentAdmonition
        case .Kunikuzushi: return .talentPraxis
        case .Alhaitham: return .talentIngenuity
        case .Yaoyao: return .talentDiligence
        case .Dehya: return .talentPraxis
        case .Mika: return .talentBallad
        case .Baizhu: return .talentGold
        case .Kaveh: return .talentIngenuity
        case .Kirara: return .talentTransience
        case .Lyney: return .talentEquity
        case .Lynette: return .talentOrder
        case .Freminet: return .talentJustice
        case .Neuvillette: return .talentEquity
        case .Wriothesley: return .talentOrder
        case .Charlotte:
            return .talentJustice.available(since: .Specify(day: 7, month: 11, year: 2023)) // 原神 4.2
        case .Furina:
            return .talentJustice.available(since: .Specify(day: 7, month: 11, year: 2023)) // 原神 4.2
        }
    }
}

// MARK: - A Dictionary dedicated for recording players' costume preference.

extension CharacterAsset {
    public static var costumeMap: [CharacterAsset: CostumeAsset] = {
        var result = [CharacterAsset: CostumeAsset]()
        _ = Defaults[.cachedCostumeMap].map { key, value in
            result[CharacterAsset.match(id: key)] = .init(rawValue: value)
        }
        return result
    }()
}

// MARK: - Extending Enka.CharacterMap.Character

extension Enka.CharacterMap.Character {
    public var enkaID: Int {
        CharacterAsset.allCases.filter { currentChar in
            currentChar.frontPhotoFileName == iconString
        }.first?.enkaId ?? -114_514
    }

    public var asset: CharacterAsset {
        CharacterAsset.allCases.filter { currentChar in
            currentChar.frontPhotoFileName == iconString
        }.first ?? .fallbackedValue
    }
}

// MARK: - AllAvatarDetailModel.Avatar Assets

extension AllAvatarDetailModel.Avatar {
    public var asset: CharacterAsset? {
        .init(rawValue: id) ?? .fallbackedValue
    }
}

// MARK: Private Array Extension

extension Array {
    fileprivate func available(since date: Date?) -> Self {
        guard let date = date else { return self }
        return Date() < date ? [] : self
    }
}
