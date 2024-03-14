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
    public enum Param {
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
    }

    public let request: ArtifactRatingRequest
}

extension ArtifactRatingSputnik {
    public static func tellTier(score: Int) -> String {
        // 给脸黑的玩家们一点面子，不然太沮丧了。
        switch score {
        case 1000...: return "SSS"
        case 900 ..< 1000: return "SS"
        case 850 ..< 900: return "S+"
        case 800 ..< 850: return "S"
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
        }
    }
}

extension ArtifactRatingRequest.Artifact {
    func getSubScore(using ratingModel: CharacterStatScoreModel) -> Double {
        let isStar5: Bool = star >= 5
        func getPt(_ base: Double, _ param: ArtifactRatingSputnik.Param) -> Double {
            (base / ArtifactRatingSputnik.getDefaultRoll(for: param, star5: isStar5)) * ratingModel.getRaw(param)
        }
        return [
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
        ].reduce(0, +)
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
            let score = $0.element.getSubScore(using: ratingModel)
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
