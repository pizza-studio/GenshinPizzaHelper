//
//  Enum_DailyMaterialAsset.swift
//  GenshinPizzaHepler
//
//  Created by ShikiSuen on 2023/10/5.
//

import Foundation

// MARK: - DailyMaterialConsumer

public protocol DailyMaterialConsumer {
    var dailyMaterial: DailyMaterialAsset? { get }
}

// MARK: - DailyMaterialAsset

/// 这里请严格按照游戏内的发行出品顺序排序，否则 `availableWeekDay` 可能会计算出错。
/// 每个 case 的符号名称就是素材名称。
public enum DailyMaterialAsset: Int, CaseIterable {
    case talentFreedom
    case talentResistance
    case talentBallad
    case talentProsperity
    case talentDiligence
    case talentGold
    case talentTransience
    case talentElegance
    case talentLight
    case talentAdmonition
    case talentIngenuity
    case talentPraxis
    case talentEquity
    case talentJustice
    case talentOrder
    case weaponDecarabian
    case weaponBorealWolf
    case weaponGladiator
    case weaponGuyun
    case weaponElixir
    case weaponAerosiderite
    case weaponDistantSea
    case weaponNarukami
    case weaponKijinMask
    case weaponTalisman
    case weaponOasisGarden
    case weaponScorchingMight
    case weaponAncientChord
    case weaponDewdrop
    case weaponPristineSea
}

extension DailyMaterialAsset {
    public enum AvailableWeekDay: Int {
        case MonThu = 0
        case TueFri = 1
        case WedSat = 2
    }

    public var availableWeekDay: AvailableWeekDay? {
        .init(rawValue: rawValue % 3) ?? nil
    }

    public func todayConsumers(_ day: AvailableWeekDay? = nil) -> [DailyMaterialConsumer] {
        guard let day = day else { return WeaponAsset.allCases + CharacterAsset.allCases }
        let weaponResults = WeaponAsset.allCases.filter { $0.dailyMaterial?.availableWeekDay == day }
        let roleResults = CharacterAsset.allCases.filter { $0.dailyMaterial?.availableWeekDay == day }
        return weaponResults + roleResults
    }
}

extension DailyMaterialAsset {
    public var localizedKey: String {
        "$asset.dailyMaterial:" + String(describing: self)
    }

    public var localized: String { localizedKey.localized }

    public var fileName: String { .init(describing: self) }
}
