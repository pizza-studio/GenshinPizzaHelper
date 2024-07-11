// (c) 2022 and onwards Pizza Studio (GPL v3.0 License).
// ====================
// This code is released under the GPL v3.0 License (SPDX-License-Identifier: GPL-3.0)

// MARK: - ArtifactSubStatScore

extension ArtifactRating {
    public enum SubStatScoreLevel: Double, Codable {
        case highest = 30
        case higher = 20
        case high = 15
        case medium = 10
        case low = 7.5
        case lower = 5
        case lowest = 2.5
        case none = 0
    }
}
