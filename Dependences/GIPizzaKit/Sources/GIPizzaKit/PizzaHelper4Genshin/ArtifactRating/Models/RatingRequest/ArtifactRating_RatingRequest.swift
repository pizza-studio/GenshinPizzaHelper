// (c) 2023 and onwards Pizza Studio (GPL v3.0 License).
// ====================
// This code is released under the GPL v3.0 License (SPDX-License-Identifier: GPL-3.0)

// MARK: - ArtifactRating.RatingRequest

extension ArtifactRating {
    public struct RatingRequest {
        // MARK: Lifecycle

        public init(
            cid: Int,
            characterElement: Int,
            flower: Artifact,
            plume: Artifact,
            sands: Artifact,
            goblet: Artifact,
            circlet: Artifact
        ) {
            self.cid = cid
            self.characterElement = characterElement
            self.flower = flower
            self.plume = plume
            self.sands = sands
            self.goblet = goblet
            self.circlet = circlet
        }

        // MARK: Public

        /// 角色ID
        public var cid: Int
        /// 角色元素能力属性，依照原神提瓦特大陆游历顺序起算。物理属性为 0、风属性为 1、岩 2、雷 3，依次类推。
        public var characterElement: Int = 0
        /// 花
        public var flower: Artifact
        /// 翎
        public var plume: Artifact
        /// 钟
        public var sands: Artifact
        /// 杯
        public var goblet: Artifact
        /// 帽
        public var circlet: Artifact

        public var allArtifacts: [Artifact] {
            [flower, plume, sands, goblet, circlet]
        }

        public var allValidArtifacts: [Artifact] {
            allArtifacts.filter(\.isValid)
        }
    }
}
