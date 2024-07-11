// (c) 2022 and onwards Pizza Studio (GPL v3.0 License).
// ====================
// This code is released under the GPL v3.0 License (SPDX-License-Identifier: GPL-3.0)

extension PlayerDetail.Avatar {
    /// 提瓦特大陆元素类型
    public enum TeyvatElement: String, CaseIterable, Hashable, Codable {
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
            case .physico: 0
            case .anemo: 1
            case .geo: 2
            case .electro: 3
            case .dendro: 4
            case .hydro: 5
            case .pyro: 6
            case .cryo: 7
            }
        }

        public var enkaLocTagForDmgAmp: String {
            switch self {
            case .physico: "FIGHT_PROP_PHYSICAL_ADD_HURT"
            case .anemo: "FIGHT_PROP_WIND_ADD_HURT"
            case .geo: "FIGHT_PROP_ROCK_ADD_HURT"
            case .electro: "FIGHT_PROP_ELEC_ADD_HURT"
            case .dendro: "FIGHT_PROP_GRASS_ADD_HURT"
            case .hydro: "FIGHT_PROP_WATER_ADD_HURT"
            case .pyro: "FIGHT_PROP_FIRE_ADD_HURT"
            case .cryo: "FIGHT_PROP_ICE_ADD_HURT"
            }
        }
    }
}
