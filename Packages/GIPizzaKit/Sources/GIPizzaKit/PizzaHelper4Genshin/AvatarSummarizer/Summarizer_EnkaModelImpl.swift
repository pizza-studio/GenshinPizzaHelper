// (c) 2022 and onwards Pizza Studio (GPL v3.0 License).
// ====================
// This code is released under the GPL v3.0 License (SPDX-License-Identifier: GPL-3.0)

extension EnkaGI.QueryRelated.FightPropMap {
    public typealias PairedDamageAmpIntel = (amount: Double, element: EnkaGI.QueryRelated.Avatar.TeyvatElement)

    /// 给所有伤害加成做排序，最高加成得以排在最开头。
    var allPairedDMGBoostsRanked: [PairedDamageAmpIntel] {
        EnkaGI.QueryRelated.Avatar.TeyvatElement.allCases.map { currentElement in
            getPairedDamageAmpIntel(for: currentElement)
        }.sorted { $0.amount > $1.amount }
    }

    public func getPairedDamageAmpIntel(for element: EnkaGI.QueryRelated.Avatar.TeyvatElement) -> PairedDamageAmpIntel {
        switch element {
        case .physico: return (physicoDamage, .physico)
        case .anemo: return (anemoDamage, .anemo)
        case .geo: return (geoDamage, .geo)
        case .electro: return (electroDamage, .electro)
        case .dendro: return (dendroDamage, .dendro)
        case .hydro: return (hydroDamage, .hydro)
        case .pyro: return (pyroDamage, .pyro)
        case .cryo: return (cryoDamage, .cryo)
        }
    }

    public func baseDMGBoostIntel(for element: EnkaGI.QueryRelated.Avatar.TeyvatElement) -> PairedDamageAmpIntel {
        getPairedDamageAmpIntel(for: element)
    }

    public func highestDMGBoostIntel(for element: EnkaGI.QueryRelated.Avatar.TeyvatElement) -> PairedDamageAmpIntel {
        let base = baseDMGBoostIntel(for: element)
        let result = allPairedDMGBoostsRanked.first ?? base
        // 如果一个角色的所有元素加成都是 0% 的话，则排序结果会不准确。此时优先使用 baseDMGBoostIntel。
        return result.amount == base.amount ? base : result
    }

    /// 物理伤害加成是否有效、且物理伤害加成是否为最强元素加成
    public func isPhysicoDMGBoostSecondarilyEffective(for element: EnkaGI.QueryRelated.Avatar.TeyvatElement) -> Bool {
        physicoDamage > 0 && (highestDMGBoostIntel(for: element).element != .physico)
    }
}
