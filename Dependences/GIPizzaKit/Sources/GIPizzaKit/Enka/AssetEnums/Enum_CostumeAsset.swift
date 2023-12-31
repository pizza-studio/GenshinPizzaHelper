//
//  Enum_ProfilePicture.swift
//  GenshinPizzaHepler
//
//  Created by ShikiSuen on 2023/10/4.
//

import Foundation

// MARK: - CostumeAsset

public enum CostumeAsset: Int, CaseIterable {
    case QinCostumeSea = 200301
    case BarbaraCostumeSummertime = 201401
    case NingguangCostumeFloral = 202701
    case KeqingCostumeFeather = 204201
    case QinCostumeWic = 200302
    case AmborCostumeWic = 202101
    case MonaCostumeWic = 204101
    case RosariaCostumeWic = 204501
    case DilucCostumeFlamme = 201601
    case FischlCostumeHighness = 203101
    case AyakaCostumeFruhling = 200201
    case LisaCostumeStudentin = 200601
    case KleeCostumeWitch = 202901
    case KaeyaCostumeDancer = 201501
}

extension CostumeAsset {
    public var frontPhotoFileName: String {
        "UI_AvatarIcon_\(String(describing: self))"
    }

    public var characterId: Int {
        switch self {
        case .QinCostumeSea: return 10000003
        case .BarbaraCostumeSummertime: return 10000014
        case .NingguangCostumeFloral: return 10000027
        case .KeqingCostumeFeather: return 10000042
        case .QinCostumeWic: return 10000003
        case .AmborCostumeWic: return 10000021
        case .MonaCostumeWic: return 10000041
        case .RosariaCostumeWic: return 10000045
        case .DilucCostumeFlamme: return 10000016
        case .FischlCostumeHighness: return 10000031
        case .AyakaCostumeFruhling: return 10000002
        case .LisaCostumeStudentin: return 10000006
        case .KleeCostumeWitch: return 10000029
        case .KaeyaCostumeDancer: return 10000015
        }
    }

    public var profilePictureIdentifier: Int {
        switch self {
        case .QinCostumeSea: return 1502
        case .BarbaraCostumeSummertime: return 401
        case .NingguangCostumeFloral: return 901
        case .KeqingCostumeFeather: return 1901
        case .QinCostumeWic: return 1501
        case .AmborCostumeWic: return 101
        case .MonaCostumeWic: return 1801
        case .RosariaCostumeWic: return 3001
        case .DilucCostumeFlamme: return 1601
        case .FischlCostumeHighness: return 1001
        case .AyakaCostumeFruhling: return 3401
        case .LisaCostumeStudentin: return 301
        case .KleeCostumeWitch: return 2101
        case .KaeyaCostumeDancer: return 201
        }
    }

    public var compatibleNamecard: NameCard? {
        switch self {
        case .QinCostumeSea: return .UI_NameCardPic_Csxy1_P
        case .BarbaraCostumeSummertime: return .UI_NameCardPic_Bp7_P
        case .NingguangCostumeFloral: return .UI_NameCardPic_TheatreMechanicus2_P
        case .KeqingCostumeFeather: return .UI_NameCardPic_Cenyan1_P
        case .QinCostumeWic: return nil
        case .AmborCostumeWic: return nil
        case .MonaCostumeWic: return nil
        case .RosariaCostumeWic: return nil
        case .DilucCostumeFlamme: return .UI_NameCardPic_Tzz1_P
        case .FischlCostumeHighness: return .UI_NameCardPic_Bp2_P
        case .AyakaCostumeFruhling: return .UI_NameCardPic_Fishing_P
        case .LisaCostumeStudentin: return .UI_NameCardPic_Bp17_P
        case .KleeCostumeWitch: return .UI_NameCardPic_RedandWhite_P
        case .KaeyaCostumeDancer: return .UI_NameCardPic_Xumi2_P
        }
    }
}
