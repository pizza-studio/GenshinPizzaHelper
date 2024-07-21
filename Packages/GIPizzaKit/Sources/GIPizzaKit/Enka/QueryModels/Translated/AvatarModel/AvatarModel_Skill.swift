// (c) 2022 and onwards Pizza Studio (GPL v3.0 License).
// ====================
// This code is released under the GPL v3.0 License (SPDX-License-Identifier: GPL-3.0)

extension EnkaGI.QueryRelated.Avatar {
    /// 天赋
    public struct Skill: Hashable {
        /// 天赋名字(字典没有，暂时无法使用)
        public let name: String
        /// 固有天赋等级
        public let level: Int
        /// 加权天赋等级（被命之座影响过的天赋等级
        public let levelAdjusted: Int
        /// 天赋图标ID
        public let iconString: String
    }
}
