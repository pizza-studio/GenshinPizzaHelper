//
//  ArtifactRatingSputnik.swift
//
//
//  Created by ShikiSuen on 2024/3/15.
//

import Foundation
import JavaScriptCore

// MARK: - ArtifactRatingSputnik

public struct ArtifactRatingSputnik {
    public enum Param: Hashable {
        case cr
        case cd
        case er
        case em
        case atkR
        case atk
        case hpR
        case hp
        case defR
        case def
        case emd(PlayerDetail.Avatar.AvatarElement) // 元素伤害
        case heal // 治疗加成
    }

    public let request: ArtifactRatingRequest
}

extension ArtifactRatingSputnik {
    public static func tellTier(score: Int) -> String {
        // 给脸黑的玩家们一点面子，不然太沮丧了。
        // 另外，考虑到钟杯帽主词条带来的分数上涨，这里也稍微将 S 段位的分数线划分得更严格一些。
        // 原先刚好满足 S 的分数现在只能分到 S- 分数段。
        switch score {
        case 1000...: return "SSS"
        case 950 ..< 1000: return "SS"
        case 900 ..< 950: return "S+"
        case 850 ..< 900: return "S"
        case 800 ..< 850: return "S-"
        case 750 ..< 800: return "A+"
        case 700 ..< 750: return "A"
        case 650 ..< 700: return "B+"
        case 600 ..< 650: return "B"
        case 550 ..< 600: return "B-"
        case 500 ..< 550: return "C"
        case 450 ..< 500: return "D"
        default: return "F"
        }
    }

    public static func getDefaultRoll(
        for param: ArtifactRatingSputnik.Param, star5: Bool
    )
        -> Double {
        switch (param, star5) {
        case (.emd, true): return 7.0
        case (.cr, true): return 3.3
        case (.cd, true): return 6.6
        case (.er, true): return 5.5
        case (.em, true): return 20
        case (.atkR, true): return 5
        case (.atk, true): return 17
        case (.hpR, true): return 5
        case (.hp, true): return 264
        case (.defR, true): return 6.2
        case (.def, true): return 20
        case (.heal, true): return 5.4
        case (.emd, false): return 6.3
        case (.cr, false): return 2.65
        case (.cd, false): return 5.3
        case (.er, false): return 4.4
        case (.em, false): return 16
        case (.atkR, false): return 3.95
        case (.atk, false): return 13
        case (.hpR, false): return 3.95
        case (.hp, false): return 203
        case (.defR, false): return 5
        case (.def, false): return 16
        case (.heal, false): return 4.8
        }
    }
}

extension ArtifactRatingRequest.Artifact {
    func getSubScore(using ratingModel: CharacterStatScoreModel, for request: ArtifactRatingRequest) -> Double {
        let isStar5: Bool = star >= 5
        func getPt(_ base: Double, _ param: ArtifactRatingSputnik.Param) -> Double {
            (base / ArtifactRatingSputnik.getDefaultRoll(for: param, star5: isStar5)) * ratingModel.getRaw(param)
        }

        var stackedScore: [Double] = [
            getPt(atkPercent, .atkR),
            getPt(hpPercent, .hpR),
            getPt(defPercent, .defR),
            getPt(crPercent, .cr),
            getPt(cdPercent, .cd),
            getPt(em, .em),
            getPt(erPercent, .er),
            getPt(atk, .atk),
            getPt(hp, .hp),
            getPt(def, .def),
        ]

        // 钟杯帽主词条只可能最多出现一个。
        let mainPropParam = mainProp3?.translated
            ?? mainProp4?.translated
            ?? mainProp5?.translated
        let mainPropWeight = Double(lv) * 0.25
        var mainPropCounted = false
        checkMainProp: if let mainPropParam = mainPropParam {
            switch mainPropParam {
            case let .emd(gobletAmpedElement):
                // 元素伤害加成需要额外处理。
                // 预设情况下会尊重与角色属性对应的元素伤害加成。
                // 但是优菈、雷泽、辛焱这三位物理角色被专门指定优先尊重物理伤害加成。
                // 然后再检查杯子的伤害加成元素种类是否与被尊重的伤害加成元素一致。
                // 不一致的话，则这个杯子的主词条将不再参与计分。
                var predefinedElement: PlayerDetail.Avatar.AvatarElement?
                ratingModel.keys.forEach { currentParam in
                    switch currentParam {
                    case let .emd(predefinedValue): predefinedElement = predefinedValue
                    default: return
                    }
                }
                guard let avatar = CharacterAsset(rawValue: request.cid) else { break checkMainProp }
                let avatarElement = avatar.element
                let fallbackElement = PlayerDetail.Avatar.AvatarElement(id: request.characterElement)
                predefinedElement = predefinedElement ?? avatarElement ?? fallbackElement
                if gobletAmpedElement == predefinedElement {
                    stackedScore.append(getPt(mainPropWeight, mainPropParam))
                    mainPropCounted = true
                }
            default:
                stackedScore.append(getPt(mainPropWeight, mainPropParam))
                mainPropCounted = true
            }
        }

        var result = stackedScore.reduce(0, +)
        if mainPropCounted {
            // 因为引入了主词条加分机制，导致分数上涨得有些虚高了。这里给总分乘以 0.9。
            // 理论上，此处的调整不会影响到花翎，只会影响到钟杯帽。
            // 这也就是说，如果角色带了与自己属性或者特长不相配的属性伤害杯的话，反而会「扣分」。
            result *= 0.9
        }
        return result
    }
}

extension ArtifactRatingSputnik {
    public func evaluate() -> ArtifactRatingScoreResult? {
        guard let char = CharacterAsset(rawValue: request.cid) else { return nil }
        var ratingModel = char.getArtifactRatingModel()

        // NOTE: Adjust dictionary contents for potential Hyperbloom Electro Roles.

        /// Theoreotically, any electro character can be turned into
        ///  a Hyperbloom trigger if any of the following 4-set is equipped.
        /// This affects the standards for benchmarking the artifacts.
        /// For example, if Raiden Shogun has a 4-set Paradise Lost equipped,
        ///  then her Element Master should be considered the most useful.

        do {
            let hyperbloomSets4: Set<Int> = [15028, 15026, 15025, 10007]
            var setIdValuesDetected = Set<Int>()

            if PlayerDetail.Avatar.AvatarElement(id: request.characterElement) == .electro {
                var accumulation = 0
                request.allValidArtifacts.forEach { artifact in
                    if hyperbloomSets4.contains(artifact.setId) {
                        setIdValuesDetected.insert(artifact.setId)
                        accumulation += 1
                    }
                }
                if accumulation >= 4, setIdValuesDetected.count <= 2 {
                    ratingModel[.em] = .highest
                }
            }
        }

        var scores: [Int: Double] = [:]

        let totalScore: Double = request.allArtifacts.enumerated().map {
            let score = $0.element.getSubScore(using: ratingModel, for: request)
            scores[$0.offset] = score
            return score
        }.reduce(0, +)

        return ArtifactRatingScoreResult(
            charactername: char.localized,
            stat1pt: scores[0] ?? 0,
            stat2pt: scores[1] ?? 0,
            stat3pt: scores[2] ?? 0,
            stat4pt: scores[3] ?? 0,
            stat5pt: scores[4] ?? 0,
            allpt: totalScore,
            result: Self.tellTier(score: Int(ceil(totalScore)))
        )
    }
}
