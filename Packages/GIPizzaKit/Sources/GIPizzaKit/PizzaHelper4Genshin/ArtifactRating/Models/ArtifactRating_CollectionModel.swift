// (c) 2022 and onwards Pizza Studio (GPL v3.0 License).
// ====================
// This code is released under the GPL v3.0 License (SPDX-License-Identifier: GPL-3.0)

// MARK: - ArtifactRating.CollectionModel

extension ArtifactRating {
    public struct CollectionModel: Codable {
        public var uid: String
        public var charId: String
        public var totalScore: Double
        public var stat1Score: Double
        public var stat2Score: Double
        public var stat3Score: Double
        public var stat4Score: Double
        public var stat5Score: Double
    }
}
