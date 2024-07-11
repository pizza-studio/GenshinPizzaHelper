// (c) 2022 and onwards Pizza Studio (GPL v3.0 License).
// ====================
// This code is released under the GPL v3.0 License (SPDX-License-Identifier: GPL-3.0)

extension PlayerDetail.Avatar {
    public var baseDMGBoostIntel: Enka.FightPropMap.PairedDamageAmpIntel {
        fightPropMap.getPairedDamageAmpIntel(for: element)
    }

    public var highestDMGBoostIntel: Enka.FightPropMap.PairedDamageAmpIntel {
        fightPropMap.highestDMGBoostIntel(for: element)
    }

    /// 物理伤害加成是否有效、且物理伤害加成是否为最强元素加成
    public var isPhysicoDMGBoostSecondarilyEffective: Bool {
        fightPropMap.isPhysicoDMGBoostSecondarilyEffective(for: element)
    }
}

extension PlayerDetail.Avatar.Skill {
    public var isLevelAdjusted: Bool {
        levelAdjusted != level
    }
}

extension PlayerDetail.Avatar.TeyvatElement {
    public var dmgBonusLabel: (text: String, icon: String) {
        switch self {
        case .cryo: return ("detailPortal.EASV.bonus.cryo", "UI_Icon_Element_Cryo")
        case .anemo: return ("detailPortal.EASV.bonus.anemo", "UI_Icon_Element_Anemo")
        case .electro: return ("detailPortal.EASV.bonus.electro", "UI_Icon_Element_Electro")
        case .hydro: return ("detailPortal.EASV.bonus.hydro", "UI_Icon_Element_Hydro")
        case .pyro: return ("detailPortal.EASV.bonus.pyro", "UI_Icon_Element_Pyro")
        case .geo: return ("detailPortal.EASV.bonus.geo", "UI_Icon_Element_Geo")
        case .dendro: return ("detailPortal.EASV.bonus.dendro", "UI_Icon_Element_Dendro")
        case .physico: return ("detailPortal.EASV.bonus.physico", "UI_Icon_Element_Physico_Amp")
        }
    }
}
