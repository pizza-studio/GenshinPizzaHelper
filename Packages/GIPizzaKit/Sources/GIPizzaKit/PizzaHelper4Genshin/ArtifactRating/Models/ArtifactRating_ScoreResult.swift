// (c) 2022 and onwards Pizza Studio (GPL v3.0 License).
// ====================
// This code is released under the GPL v3.0 License (SPDX-License-Identifier: GPL-3.0)

// MARK: - ArtifactRating.ScoreResult

extension ArtifactRating {
    public struct ScoreResult: Codable, Equatable {
        var charactername: String
        public var stat1pt: Double
        public var stat2pt: Double
        public var stat3pt: Double
        public var stat4pt: Double
        public var stat5pt: Double
        public var allpt: Double
        public var result: String

        public var isValid: Bool {
            guard allpt == stat1pt + stat2pt + stat3pt + stat4pt + stat5pt
            else { return false }
            guard stat1pt >= 0 else { return false }
            guard stat2pt >= 0 else { return false }
            guard stat3pt >= 0 else { return false }
            guard stat4pt >= 0 else { return false }
            guard stat5pt >= 0 else { return false }
            return true
        }

        public func convertToCollectionModel(
            uid: String,
            charId: String
        )
            -> ArtifactRating.CollectionModel {
            ArtifactRating.CollectionModel(
                uid: uid,
                charId: charId,
                totalScore: allpt,
                stat1Score: stat1pt,
                stat2Score: stat2pt,
                stat3Score: stat3pt,
                stat4Score: stat4pt,
                stat5Score: stat5pt
            )
        }
    }
}
