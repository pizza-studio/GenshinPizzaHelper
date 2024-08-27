// (c) 2022 and onwards Pizza Studio (GPL v3.0 License).
// ====================
// This code is released under the GPL v3.0 License (SPDX-License-Identifier: GPL-3.0)

extension EnkaGI.QueryRelated.Avatar {
    /// 武器
    public struct Weapon: Hashable, Identifiable {
        // MARK: Lifecycle

        init?(
            weaponEquipment: EnkaGI.QueryRelated.ProfileRAW.AvatarInfoRAW.EquipListRAW,
            localizedDictionary: [String: String]
        ) {
            guard weaponEquipment.flat.itemType == "ITEM_WEAPON"
            else { return nil }
            self.id = weaponEquipment.itemId.description
            self.name = localizedDictionary.nameFromHashMap(weaponEquipment.flat.nameTextMapHash)
            self.level = weaponEquipment.weapon!.level
            self.refinementRank = (weaponEquipment.weapon?.affixMap?.first?.value ?? 0) + 1
            self.iconString = weaponEquipment.flat.icon
            self.rankLevel = .init(rawValue: weaponEquipment.flat.rankLevel) ?? .four

            self.mainAttribute = .init(
                name: AvatarAttribute.baseATK.localized,
                value: 0,
                rawName: AvatarAttribute.baseATK.rawValue
            )
            self.subAttribute = nil
            weaponEquipment.flat.weaponStats?.forEach { currentStat in
                guard let type = AvatarAttribute(rawValue: currentStat.appendPropId) else { return }
                let localizedAttributeName = type.localized
                switch type {
                case .baseATK:
                    self.mainAttribute = .init(
                        name: localizedAttributeName,
                        value: currentStat.statValue,
                        rawName: currentStat.appendPropId
                    )
                default:
                    self.subAttribute = .init(
                        name: localizedAttributeName,
                        value: currentStat.statValue,
                        rawName: currentStat.appendPropId
                    )
                }
            }
        }

        // MARK: Public

        public let id: String
        /// 武器名字
        public let name: String
        /// 武器等级
        public let level: Int
        /// 精炼等阶 (1-5)
        public let refinementRank: Int
        /// 武器主属性
        public var mainAttribute: Attribute
        /// 武器副属性
        public var subAttribute: Attribute?
        /// 武器图标ID
        public let iconString: String
        /// 武器星级
        public let rankLevel: RankLevel

        /// 突破后武器图标ID
        public var awakenedIconString: String { "gi_weapon_\(id)" }
        /// 经过错字订正处理的武器名称
        public var nameCorrected: String {
            name.localizedWithFix
        }
    }
}
