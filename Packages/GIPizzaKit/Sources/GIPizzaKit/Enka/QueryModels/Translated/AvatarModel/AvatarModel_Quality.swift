// (c) 2022 and onwards Pizza Studio (GPL v3.0 License).
// ====================
// This code is released under the GPL v3.0 License (SPDX-License-Identifier: GPL-3.0)

extension EnkaGI.QueryRelated.Avatar {
    /// 角色星级，橙色为四星，紫色为五星
    public enum Quality: String, Hashable {
        /// 紫色，四星角色
        case purple = "QUALITY_PURPLE"
        /// 橙色，五星角色
        case orange = "QUALITY_ORANGE"
        /// 特殊橙色，埃洛伊
        case orangeSpecial = "QUALITY_ORANGE_SP"
    }
}
