// (c) 2022 and onwards Pizza Studio (GPL v3.0 License).
// ====================
// This code is released under the GPL v3.0 License (SPDX-License-Identifier: GPL-3.0)

import Darwin

extension PlayerDetail.Avatar {
    /// 任意属性
    public struct Attribute: Hashable {
        // MARK: Lifecycle

        public init(name: String, value: Double, rawName: String) {
            self.name = name
            self.value = value
            self.rawName = rawName
        }

        /// 属性图标的ID
        // let iconString: String

        // MARK: Public

        public let name: String
        public var value: Double
        public let rawName: String

        public var valueString: String {
            var result: String
            if floor(value) == value {
                result = "\(Int(value))"
            } else {
                result = String(format: "%.1f", value)
            }
            if let last = name.last, ["％", "%"].contains(last) {
                result.append("%")
            }
            return result.description
        }

        public var matchedType: AvatarAttribute? {
            .init(rawValue: rawName)
        }
    }
}
