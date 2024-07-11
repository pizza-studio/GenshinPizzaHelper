// (c) 2022 and onwards Pizza Studio (GPL v3.0 License).
// ====================
// This code is released under the GPL v3.0 License (SPDX-License-Identifier: GPL-3.0)

import Defaults
import DefaultsKeys

// MARK: - ArtifactRating

public enum ArtifactRating {}

public typealias ArtifactSubStatScore = ArtifactRating.SubStatScoreLevel

extension Defaults.Keys {
    public static let artifactRatingOptions =
        Key<ArtifactRatingOptions>("artifactRatingOptions", default: .allEnabled, suite: .opSuite)
}

// MARK: - ArtifactRatingOptions

public struct ArtifactRatingOptions: OptionSet, _DefaultsSerializable {
    // MARK: Lifecycle

    public init(rawValue: Int) {
        self.rawValue = rawValue
    }

    // MARK: Public

    public static let allDisabled = Self([])
    public static let allEnabled = Self([.enabled, .considerMainProps, .considerHyperbloomElectroRoles])
    public static let enabled = Self(rawValue: 1 << 0)
    public static let considerMainProps = Self(rawValue: 1 << 1)
    public static let considerHyperbloomElectroRoles = Self(rawValue: 1 << 2)

    public let rawValue: Int
}
