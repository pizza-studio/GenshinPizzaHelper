// (c) 2022 and onwards Pizza Studio (GPL v3.0 License).
// ====================
// This code is released under the GPL v3.0 License (SPDX-License-Identifier: GPL-3.0)

// MARK: - RankLevel

public enum RankLevel: Int, Hashable {
    case one = 1, two = 2, three = 3, four = 4, five = 5

    // MARK: Public

    public var rectangularBackgroundIconString: String {
        "UI_QualityBg_\(rawValue)"
    }

    public var squaredBackgroundIconString: String {
        "UI_QualityBg_\(rawValue)s"
    }
}
