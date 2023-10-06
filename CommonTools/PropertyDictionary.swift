//
//  PropertyDictionary.swift
//  GenshinPizzaHelper
//
//  Created by Bill Haku on 2022/9/25.
//

import Foundation

class PropertyDictionary {
    static var dict: [String: String] = [
        "FIGHT_PROP_BASE_ATTACK": "detailPortal.ECDDV.prop.basicATK",
        "FIGHT_PROP_MAX_HP": "detailPortal.ECDDV.prop.maxHP",
        "FIGHT_PROP_ATTACK": "detailPortal.ECDDV.ATK",
        "FIGHT_PROP_DEFENSE": "detailPortal.ECDDV.DEF",
        "FIGHT_PROP_ELEMENT_MASTERY": "detailPortal.ECDDV.prop.EM",
        "FIGHT_PROP_CRITICAL": "detailPortal.ECDDV.prop.CR",
        "FIGHT_PROP_CRITICAL_HURT": "detailPortal.ECDDV.prop.CDMG",
        "FIGHT_PROP_HEAL_ADD": "detailPortal.ECDDV.prop.bonus.heal",
        "FIGHT_PROP_HEALED_ADD": "detailPortal.ECDDV.prop.bonus.healed",
        "FIGHT_PROP_CHARGE_EFFICIENCY": "detailPortal.ECDDV.prop.ERCR",
        "FIGHT_PROP_SHIELD_COST_MINUS_RATIO": "detailPortal.ECDDV.prop.SCMR",
        "FIGHT_PROP_FIRE_ADD_HURT": "detailPortal.ECDDV.prop.bonus.pyro",
        "FIGHT_PROP_WATER_ADD_HURT": "detailPortal.ECDDV.prop.bonus.hydro",
        "FIGHT_PROP_GRASS_ADD_HURT": "detailPortal.ECDDV.prop.bonus.dendro",
        "FIGHT_PROP_ELEC_ADD_HURT": "detailPortal.ECDDV.prop.bonus.electro",
        "FIGHT_PROP_WIND_ADD_HURT": "detailPortal.ECDDV.prop.bonus.anemo",
        "FIGHT_PROP_ICE_ADD_HURT": "detailPortal.ECDDV.prop.bonus.cryo",
        "FIGHT_PROP_ROCK_ADD_HURT": "detailPortal.ECDDV.prop.bonus.geo",
        "FIGHT_PROP_PHYSICAL_ADD_HURT": "detailPortal.ECDDV.prop.bonus.physical",
        "FIGHT_PROP_HP": "detailPortal.ECDDV.maxHP",
        "FIGHT_PROP_ATTACK_PERCENT": "detailPortal.ECDDV.prop.ATK",
        "FIGHT_PROP_HP_PERCENT": "detailPortal.ECDDV.prop.HP",
        "FIGHT_PROP_DEFENSE_PERCENT": "detailPortal.ECDDV.prop.DEF",
    ]

    static func getLocalizedName(_ key: String) -> String {
        dict[key]?.localized ?? "Unknown"
    }
}
