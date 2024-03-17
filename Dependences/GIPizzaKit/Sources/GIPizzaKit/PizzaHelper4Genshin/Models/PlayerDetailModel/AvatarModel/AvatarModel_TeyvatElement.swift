// (c) 2022 and onwards Pizza Studio (GPL v3.0 License).
// ====================
// This code is released under the GPL v3.0 License (SPDX-License-Identifier: GPL-3.0)

extension PlayerDetail.Avatar {
    /// 提瓦特大陆元素类型
    public enum TeyvatElement: String, CaseIterable, Hashable {
        /// 原人
        case physico = "Unknown"
        /// 风
        case anemo = "Wind"
        /// 岩
        case geo = "Rock"
        /// 雷
        case electro = "Electric"
        /// 草
        case dendro = "Grass"
        /// 水
        case hydro = "Water"
        /// 火
        case pyro = "Fire"
        /// 冰
        case cryo = "Ice"

        // MARK: Lifecycle

        public init?(id: Int) {
            switch id {
            case 0: self = .physico
            case 1: self = .anemo
            case 2: self = .geo
            case 3: self = .electro
            case 4: self = .dendro
            case 5: self = .hydro
            case 6: self = .pyro
            case 7: self = .cryo
            default: return nil
            }
        }

        // MARK: Public

        /// 角色元素能力属性，依照原神提瓦特大陆游历顺序起算。物理属性为 0、风属性为 1、岩 2、雷 3，依次类推。
        public var enumerationId: Int {
            switch self {
            case .cryo: 7
            case .anemo: 1
            case .electro: 3
            case .hydro: 5
            case .pyro: 6
            case .geo: 2
            case .dendro: 4
            case .physico: 0
            }
        }
    }
}
