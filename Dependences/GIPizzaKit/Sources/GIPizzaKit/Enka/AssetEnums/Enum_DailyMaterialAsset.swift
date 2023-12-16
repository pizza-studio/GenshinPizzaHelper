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

    /// 该函式用来屏蔽某些正式发行前的内容。
    /// - Remark:之所以仅对名片与材料这么做，
    /// 是因为角色往往会提前一个月被米哈游官方借由「天外卫星通信」公开。
    /// 该函式可用于 CharacterAsset 与 WeaponAsset 身为 DailyMaterialConsumer 时的 .dailyMaterial 返回值。
    /// 例：`case .Baizhu: return .talentGold.available(since: .Specify(day: 11, month: 4, year: 2023))`。
    /// - Parameter date: 解除禁令的时间，建议设定为新版发行之前的纪行的结束日之后的那天。
    /// - Returns: 如果还没到解禁时间的话，会返回 nil；否则会返回本体。
    public func available(since date: Date?) -> DailyMaterialAsset? {
        guard let date = date else { return self }
        return Date() < date ? nil : self
    }
}

extension DailyMaterialAsset {
    public var localizedKey: String {
        "$asset.dailyMaterial:" + String(describing: self)
    }

    public var localized: String { localizedKey.spmLocalized }

    public var fileName: String { .init(describing: self) }
}
