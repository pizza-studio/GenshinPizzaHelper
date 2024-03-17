// (c) 2022 and onwards Pizza Studio (GPL v3.0 License).
// ====================
// This code is released under the GPL v3.0 License (SPDX-License-Identifier: GPL-3.0)

import Foundation

public enum AvatarAttribute: String {
    case baseATK = "FIGHT_PROP_BASE_ATTACK"
    case maxHP = "FIGHT_PROP_MAX_HP"
    case ATK = "FIGHT_PROP_ATTACK"
    case DEF = "FIGHT_PROP_DEFENSE"
    case EM = "FIGHT_PROP_ELEMENT_MASTERY"
    case critRate = "FIGHT_PROP_CRITICAL"
    case critDmg = "FIGHT_PROP_CRITICAL_HURT"
    case healAmp = "FIGHT_PROP_HEAL_ADD"
    case healedAmp = "FIGHT_PROP_HEALED_ADD"
    case chargeEfficiency = "FIGHT_PROP_CHARGE_EFFICIENCY"
    case shieldCostMinusRatio = "FIGHT_PROP_SHIELD_COST_MINUS_RATIO"
    case dmgAmpPyro = "FIGHT_PROP_FIRE_ADD_HURT"
    case dmgAmpHydro = "FIGHT_PROP_WATER_ADD_HURT"
    case dmgAmpDendro = "FIGHT_PROP_GRASS_ADD_HURT"
    case dmgAmpElectro = "FIGHT_PROP_ELEC_ADD_HURT"
    case dmgAmpAnemo = "FIGHT_PROP_WIND_ADD_HURT"
    case dmgAmpCryo = "FIGHT_PROP_ICE_ADD_HURT"
    case dmgAmpGeo = "FIGHT_PROP_ROCK_ADD_HURT"
    case dmgAmpPhysico = "FIGHT_PROP_PHYSICAL_ADD_HURT"
    case HP = "FIGHT_PROP_HP"
    case ATKAmp = "FIGHT_PROP_ATTACK_PERCENT"
    case HPAmp = "FIGHT_PROP_HP_PERCENT"
    case DEFAmp = "FIGHT_PROP_DEFENSE_PERCENT"

    // MARK: Public

    public var localizedKey: String {
        switch self {
        case .baseATK: return "detailPortal.ECDDV.prop.basicATK"
        case .maxHP: return "detailPortal.ECDDV.prop.maxHP"
        case .ATK: return "detailPortal.ECDDV.ATK"
        case .DEF: return "detailPortal.ECDDV.DEF"
        case .EM: return "detailPortal.ECDDV.prop.EM"
        case .critRate: return "detailPortal.ECDDV.prop.CR"
        case .critDmg: return "detailPortal.ECDDV.prop.CDMG"
        case .healAmp: return "detailPortal.ECDDV.prop.bonus.heal"
        case .healedAmp: return "detailPortal.ECDDV.prop.bonus.healed"
        case .chargeEfficiency: return "detailPortal.ECDDV.prop.ERCR"
        case .shieldCostMinusRatio: return "detailPortal.ECDDV.prop.SCMR"
        case .dmgAmpPyro: return "detailPortal.ECDDV.prop.bonus.pyro"
        case .dmgAmpHydro: return "detailPortal.ECDDV.prop.bonus.hydro"
        case .dmgAmpDendro: return "detailPortal.ECDDV.prop.bonus.dendro"
        case .dmgAmpElectro: return "detailPortal.ECDDV.prop.bonus.electro"
        case .dmgAmpAnemo: return "detailPortal.ECDDV.prop.bonus.anemo"
        case .dmgAmpCryo: return "detailPortal.ECDDV.prop.bonus.cryo"
        case .dmgAmpGeo: return "detailPortal.ECDDV.prop.bonus.geo"
        case .dmgAmpPhysico: return "detailPortal.ECDDV.prop.bonus.physico"
        case .HP: return "detailPortal.ECDDV.maxHP"
        case .ATKAmp: return "detailPortal.ECDDV.prop.ATK"
        case .HPAmp: return "detailPortal.ECDDV.prop.HP"
        case .DEFAmp: return "detailPortal.ECDDV.prop.DEF"
        }
    }

    public var localized: String {
        localizedKey.localized
    }

    public static func getLocalizedName(_ key: String) -> String {
        AvatarAttribute(rawValue: key)?.localized ?? "Unknown"
    }
}
