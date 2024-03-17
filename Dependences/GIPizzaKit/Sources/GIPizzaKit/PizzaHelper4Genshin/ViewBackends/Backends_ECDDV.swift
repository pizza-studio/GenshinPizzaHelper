// (c) 2022 and onwards Pizza Studio (GPL v3.0 License).
// ====================
// This code is released under the GPL v3.0 License (SPDX-License-Identifier: GPL-3.0)

// ECDDV (EachCharacterDetailDataView) 视图的有些前端运算必须放到后端来，不然会卡死 compiler。

import Defaults
import Foundation

extension PlayerDetail.Avatar {
    public struct ProbBackendData: Codable, Hashable, Identifiable {
        // MARK: Lifecycle

        public init(
            iconString: String, name: String, value: String
        ) {
            self.id = UUID().uuidString
            self.iconString = iconString
            self.name = name
            self.value = value
        }

        // MARK: Public

        public let id: String
        public let iconString: String
        public let name: String
        public let value: String
    }

    public func getProbBackendDataPairs(useAdaptiveSpacing: Bool) -> [ProbBackendData] {
        var result = [ProbBackendData]()
        if fightPropMap.healingBonus > 0 {
            result.append(.init(
                iconString: "UI_Icon_MaxHp",
                name: "detailPortal.ECDDV.prop.maxHP".localized + " & " + "detailPortal.ECDDV.prop.bonus.heal"
                    .localized
                    .percentageMarksTrimmed,
                value: "\(fightPropMap.HP.rounded(toPlaces: 1))" +
                    ", " +
                    "\((fightPropMap.healingBonus * 100).rounded(toPlaces: 2))%"
            ))
        } else {
            result.append(.init(
                iconString: "UI_Icon_MaxHp",
                name: "detailPortal.ECDDV.prop.maxHP",
                value: "\(fightPropMap.HP.rounded(toPlaces: 1))"
            ))
        }

        if isPhysicoDMGBoostSecondarilyEffective {
            result.append(.init(
                iconString: "UI_Icon_CurAttack",
                name: "detailPortal.ECDDV.ATK".localized + " & " + "detailPortal.ECDDV.prop.bonus.physico"
                    .localized
                    .percentageMarksTrimmed,
                value: "\(fightPropMap.ATK.rounded(toPlaces: 1))" +
                    ", " +
                    "\((fightPropMap.physicoDamage * 100.0).rounded(toPlaces: 2))%"
            ))
        } else {
            result.append(.init(
                iconString: "UI_Icon_CurAttack",
                name: "detailPortal.ECDDV.ATK",
                value: "\(fightPropMap.ATK.rounded(toPlaces: 1))"
            ))
        }
        result.append(.init(
            iconString: "UI_Icon_CurDefense",
            name: "detailPortal.ECDDV.DEF",
            value: "\(fightPropMap.DEF.rounded(toPlaces: 1))"
        ))
        result.append(.init(
            iconString: "UI_Icon_Element",
            name: "detailPortal.ECDDV.EM",
            value: "\(fightPropMap.elementalMastery.rounded(toPlaces: 1))"
        ))
        result.append(.init(
            iconString: "UI_Icon_Intee_WindField_ClockwiseRotation",
            name: "detailPortal.ECDDV.ERCR",
            value: "\((fightPropMap.energyRecharge * 100).rounded(toPlaces: 2))%"
        ))

        if useAdaptiveSpacing {
            result.append(.init(
                iconString: "UI_Icon_CriticalRate",
                name: "detailPortal.ECDDV.CR",
                value: "\((fightPropMap.criticalRate * 100).rounded(toPlaces: 2))%"
            ))
            result.append(.init(
                iconString: "UI_Icon_CriticalDamage",
                name: "detailPortal.ECDDV.CDMG",
                value: "\((fightPropMap.criticalDamage * 100.0).rounded(toPlaces: 2))%"
            ))
        } else {
            result.append(.init(
                iconString: "UI_Icon_CriticalDamage",
                name: "detailPortal.ECDDV.CR".localized + " & " + "detailPortal.ECDDV.CDMG".localized,
                value: "\((fightPropMap.criticalRate * 100).rounded(toPlaces: 2))%" +
                    ", " +
                    "\((fightPropMap.criticalDamage * 100.0).rounded(toPlaces: 2))%"
            ))
        }
        let primaryDMGBonus = highestDMGBoostIntel
        result.append(.init(
            iconString: primaryDMGBonus.element.dmgBonusLabel.icon,
            name: primaryDMGBonus.element.dmgBonusLabel.text,
            value: "\((primaryDMGBonus.amount * 100.0).rounded(toPlaces: 2))%"
        ))
        if Defaults[.artifactRatingOptions].contains(.enabled),
           let totalScore = artifactTotalScore,
           let rank = artifactScoreRank {
            result.append(.init(
                iconString: "UI_Icon_ArtifactRating",
                name: "detailPortal.ECDDV.artifactRank".localized,
                value: "\(String(format: "%.0f", totalScore)) (\(rank))"
            ))
        }

        return result
    }
}

// MARK: - Convert trailing percentage mark into a rised arrow mark.

extension String {
    fileprivate var percentageMarksTrimmed: String {
        if !contains("％"), !contains("%") { return self }
        return replacingOccurrences(of: "％", with: "")
            .replacingOccurrences(of: "%", with: "")
    }
}
