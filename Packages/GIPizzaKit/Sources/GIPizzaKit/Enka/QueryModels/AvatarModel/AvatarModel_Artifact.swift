// (c) 2022 and onwards Pizza Studio (GPL v3.0 License).
// ====================
// This code is released under the GPL v3.0 License (SPDX-License-Identifier: GPL-3.0)

import Foundation.NSUUID

extension EnkaGI.QueryRelated.Avatar {
    /// 圣遗物
    public struct Artifact: Identifiable, Equatable, Hashable {
        // MARK: Lifecycle

        init?(
            artifactEquipment: EnkaGI.QueryRelated.FetchModel.AvatarInfo.EquipList,
            localizedDictionary: [String: String],
            score: Double?
        ) {
            guard artifactEquipment.flat.itemType == "ITEM_RELIQUARY"
            else { return nil }
            self.id = artifactEquipment.flat.nameTextMapHash
            self.name = localizedDictionary
                .nameFromHashMap(artifactEquipment.flat.nameTextMapHash)
            self.setName = localizedDictionary
                .nameFromHashMap(artifactEquipment.flat.setNameTextMapHash!)
            self.mainAttribute = Attribute(
                name: AvatarAttribute
                    .getLocalizedName(
                        artifactEquipment.flat
                            .reliquaryMainstat!.mainPropId
                    ),
                value: artifactEquipment.flat.reliquaryMainstat!.statValue,
                rawName: artifactEquipment.flat.reliquaryMainstat!
                    .mainPropId
            )
            self.subAttributes = artifactEquipment.flat.reliquarySubstats?
                .map { stats in
                    Attribute(
                        name: AvatarAttribute
                            .getLocalizedName(stats.appendPropId),
                        value: stats.statValue,
                        rawName: stats.appendPropId
                    )
                } ?? []
            self.iconString = artifactEquipment.flat.icon
            self
                .artifactType = .init(
                    rawValue: artifactEquipment.flat
                        .equipType ?? ""
                ) ?? .flower
            self
                .rankLevel =
                .init(
                    rawValue: artifactEquipment.flat
                        .rankLevel
                ) ?? .five
            self.level = max(
                (artifactEquipment.reliquary?.level ?? 1) - 1,
                0
            )
            self.score = score
        }

        // MARK: Public

        public enum PartType: String, CaseIterable, Hashable {
            case flower = "EQUIP_BRACER"
            case plume = "EQUIP_NECKLACE"
            case sands = "EQUIP_SHOES"
            case goblet = "EQUIP_RING"
            case circlet = "EQUIP_DRESS"

            // MARK: Public

            public var sortId: Int {
                switch self {
                case .flower: 0
                case .plume: 1
                case .sands: 2
                case .goblet: 3
                case .circlet: 4
                }
            }

            public var emojiRepresentable: String {
                switch self {
                case .flower: "🌷"
                case .plume: "🪶"
                case .sands: "⏳"
                case .goblet: "🍷"
                case .circlet: "👑"
                }
            }
        }

        public let id: String

        /// 圣遗物名字（词典没有，暂不可用）
        public let name: String
        /// 所属圣遗物套装的名字
        public let setName: String
        /// 圣遗物的主属性
        public let mainAttribute: Attribute
        /// 圣遗物的副属性
        public let subAttributes: [Attribute]
        /// 圣遗物图标ID
        public let iconString: String
        /// 圣遗物所属部位
        public let artifactType: PartType
        /// 圣遗物等级
        public let level: Int
        /// 圣遗物星级
        public let rankLevel: RankLevel
        /// 圣遗物评分
        public var score: Double?

        /// 圣遗物套装编号
        public var setId: Int? {
            let arr = iconString.split(separator: "_")
            return arr.count == 4 ? Int(arr[2]) : nil
        }

        public static func == (
            lhs: EnkaGI.QueryRelated.Avatar.Artifact,
            rhs: EnkaGI.QueryRelated.Avatar.Artifact
        )
            -> Bool {
            lhs.id == rhs.id
        }
    }
}
