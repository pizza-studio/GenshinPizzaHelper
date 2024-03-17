// (c) 2022 and onwards Pizza Studio (GPL v3.0 License).
// ====================
// This code is released under the GPL v3.0 License (SPDX-License-Identifier: GPL-3.0)

import Defaults
import DefaultsKeys
import Foundation

extension PlayerDetail.Avatar {
    public func summarize(locMap: Enka.Sputnik.CharLoc, useMarkDown: Bool = false) -> String {
        var resultLines = useMarkDown ? [] : ["//====================="]

        func addSeparator(finalLine: Bool = false) {
            if !useMarkDown {
                resultLines.append(finalLine ? "//=====================" : "//---------------------")
            }
        }

        func indentNode(_ level: UInt = 0) -> String {
            if !useMarkDown {
                return "// \(String(repeating: " ", count: Int(level)))→ "
            } else {
                return "- ###\(String(repeating: "#", count: Int(level))) "
            }
        }

        func indent(_ level: UInt = 0) -> String {
            if !useMarkDown {
                return "// \(String(repeating: " ", count: Int(level)))"
            } else {
                return "\(String(repeating: "\t", count: Int(level)))- "
            }
        }

        func emph(_ str: String) -> String {
            useMarkDown ? "**\(str)**" : str
        }

        // 姓名, 等级, 命之座, 十六进位天赋
        var headLine = useMarkDown ? "### " : "// "
        headLine.append(nameCorrected + " ")
        headLine.append("[Lv.\(level), C\(constellation)]")
        let skillLevels: String = skills.map { skillUnit in
            if skillUnit.level == skillUnit.levelAdjusted {
                return skillUnit.level.description
            } else {
                let strDeltaDisplay = "(+\(skillUnit.levelAdjusted - skillUnit.level))"
                return skillUnit.level.description + strDeltaDisplay
            }
        }.joined(separator: ", ")
        headLine.append(" [\(skillLevels)]")
        resultLines.append(headLine)
        addSeparator()

        let weaponTextCells: [String] = [
            weapon.nameCorrected,
            "(lv\(weapon.level), ☆\(weapon.rankLevel.rawValue), R\(weapon.refinementRank))",
        ]
        resultLines.append("\(indent(0))\(emph(weaponTextCells.joined(separator: " ")))")

        var weaponProps = "\(indent(1))"
        var weaponPropName = locMap[weapon.mainAttribute.rawName] ?? weapon.mainAttribute.rawName
        weaponProps.append("[! \(weaponPropName): \(weapon.mainAttribute.valueString)]")
        if let weaponSubAttr = weapon.subAttribute {
            weaponPropName = locMap[weaponSubAttr.rawName] ?? weaponSubAttr.rawName
            weaponProps.append(" [\(weaponPropName): \(weaponSubAttr.valueString)]")
        }
        resultLines.append(weaponProps)
        addSeparator()

        // Probs.
        var tagname = locMap[AvatarAttribute.maxHP.rawValue] ?? AvatarAttribute.maxHP.rawValue
        resultLines.append("\(indent(0))[\(tagname): \(fightPropMap.HP.rounded(toPlaces: 1))]")
        let tagnameATK = locMap[AvatarAttribute.ATK.rawValue] ?? AvatarAttribute.ATK.rawValue
        let tagnameDEF = locMap[AvatarAttribute.DEF.rawValue] ?? AvatarAttribute.DEF.rawValue
        resultLines
            .append(
                "\(indent(0))[\(tagnameATK) & \(tagnameDEF): \(fightPropMap.ATK.rounded(toPlaces: 1)) & \(fightPropMap.DEF.rounded(toPlaces: 1))]"
            )

        tagname = locMap[AvatarAttribute.EM.rawValue] ?? AvatarAttribute.EM.rawValue
        resultLines.append("\(indent(0))[\(tagname): \(fightPropMap.elementalMastery.rounded(toPlaces: 1))]")
        tagname = locMap[AvatarAttribute.chargeEfficiency.rawValue] ?? AvatarAttribute.chargeEfficiency.rawValue
        resultLines.append("\(indent(0))[\(tagname): \((fightPropMap.energyRecharge * 100).rounded(toPlaces: 2))%]")

        let tagnameCR = locMap[AvatarAttribute.critRate.rawValue] ?? AvatarAttribute.critRate.rawValue
        let tagnameCD = locMap[AvatarAttribute.critDmg.rawValue] ?? AvatarAttribute.critDmg.rawValue
        resultLines
            .append(
                "\(indent(0))[\(tagnameCR) & \(tagnameCD): \((fightPropMap.criticalRate * 100).rounded(toPlaces: 2))% & \((fightPropMap.criticalDamage * 100).rounded(toPlaces: 2))%]"
            )

        let effectiveElementDmgAmps = fightPropMap.allPairedDMGBoostsRanked.filter {
            $0.amount > 0 || $0.element == self.element
        }
        effectiveElementDmgAmps.forEach { amount, element in
            let i18nKeyEnka = element.enkaLocTagForDmgAmp
            let tagNameCurrent = locMap[i18nKeyEnka] ?? i18nKeyEnka
            resultLines.append("\(indent(0))[\(tagNameCurrent): \((amount * 100).rounded(toPlaces: 2))%]")
        }

        if fightPropMap.healingBonus > 0 {
            tagname = locMap[AvatarAttribute.healAmp.rawValue] ?? AvatarAttribute.healAmp.rawValue
            resultLines.append("\(indent(0))[\(tagname): \((fightPropMap.healingBonus * 100).rounded(toPlaces: 2))%]")
        }
        addSeparator()

        artifacts.enumerated().forEach { _, currentArtifact in
            var currentArtifactPropName = locMap[currentArtifact.mainAttribute.rawName] ?? currentArtifact.mainAttribute
                .rawName
            let mainPropStr = "\(currentArtifactPropName): \(currentArtifact.mainAttribute.valueString)"
            let emojiRep = currentArtifact.artifactType.emojiRepresentable
            let suiteName = currentArtifact.setName
            let rankLevelATF = currentArtifact.rankLevel.rawValue
            let lvATF = currentArtifact.level
            resultLines
                .append("\(indent(0))\(emojiRep) \(emph(mainPropStr)) (☆\(rankLevelATF) lv.\(lvATF) \(suiteName))")
            var arrSubProps: [String] = []
            currentArtifact.subAttributes.forEach { currentAttr in
                currentArtifactPropName = locMap[currentAttr.rawName] ?? currentAttr.rawName
                arrSubProps.append("[\(currentArtifactPropName): \(currentAttr.valueString)]")
            }
            resultLines.append("\(indent(1))\(arrSubProps.joined(separator: " "))")
        }

        addSeparator(finalLine: true)
        return resultLines.joined(separator: "\n")
    }
}
