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

        // MARK: Public

        public let name: String
        public var value: Double
        public let rawName: String

        public var valueString: String {
            var result: String
            // 不能仅用这个来判定某个属性是否以 % 标记。
            // 得务必用 isPercentageRepresentable 判断。
            if floor(value) == value {
                result = "\(Int(value))"
            } else {
                result = String(format: "%.1f", value)
            }
            if isPercentageRepresentable {
                result.append("%")
            }
            return result.description
        }

        public var isPercentageRepresentable: Bool {
            switch matchedType {
            case .baseATK: return false
            case .maxHP: return false
            case .ATK: return false
            case .DEF: return false
            case .EM: return false
            case .critRate: return true
            case .critDmg: return true
            case .healAmp: return true
            case .healedAmp: return true
            case .chargeEfficiency: return true
            case .shieldCostMinusRatio: return true
            case .dmgAmpPyro: return true
            case .dmgAmpHydro: return true
            case .dmgAmpDendro: return true
            case .dmgAmpElectro: return true
            case .dmgAmpAnemo: return true
            case .dmgAmpCryo: return true
            case .dmgAmpGeo: return true
            case .dmgAmpPhysico: return true
            case .HP: return false
            case .ATKAmp: return true
            case .HPAmp: return true
            case .DEFAmp: return true
            case nil: return false
            }
        }

        public var matchedType: AvatarAttribute? {
            .init(rawValue: rawName)
        }
    }
}
