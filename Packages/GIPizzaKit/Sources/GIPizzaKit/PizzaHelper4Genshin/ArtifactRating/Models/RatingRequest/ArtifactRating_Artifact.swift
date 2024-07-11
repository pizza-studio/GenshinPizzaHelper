// (c) 2024 and onwards Pizza Studio (GPL v3.0 License).
// ====================
// This code is released under the GPL v3.0 License (SPDX-License-Identifier: GPL-3.0)

extension ArtifactRating.RatingRequest {
    // MARK: Public

    public struct Artifact {
        // MARK: Lifecycle

        public init() {}

        // MARK: Public

        public var mainProp3: Artifact3MainProp?
        public var mainProp4: Artifact4MainProp?
        public var mainProp5: Artifact5MainProp?
        public var star: Int = 5
        public var lv: Int = 20
        public var setId: Int = -114_514
        public var atkAmp: Double = 0
        public var hpAmp: Double = 0
        public var defAmp: Double = 0
        public var em: Double = 0
        public var er: Double = 0
        public var critRate: Double = 0
        public var critDmg: Double = 0
        public var atk: Double = 0
        public var hp: Double = 0
        public var def: Double = 0

        public var isNull: Bool {
            setId == -114_514
        }

        public var isValid: Bool {
            !isNull
        }
    }
}
