// (c) 2022 and onwards Pizza Studio (GPL v3.0 License).
// ====================
// This code is released under the GPL v3.0 License (SPDX-License-Identifier: GPL-3.0)

#if DEBUG
extension ArtifactRating.SubStatScoreLevel {
    public var srsValue: Double {
        switch self {
        case .highest: 1
        case .higher: 0.85
        case .high: 0.65
        case .medium: 0.55
        case .low: 0.45
        case .lower: 0.35
        case .lowest: 0.1
        case .none: 0
        }
    }
}

// MARK: - ArtifactRating.Appraiser.Param + CaseIterable

extension ArtifactRating.Appraiser.Param: CaseIterable {
    public static let allCases: [ArtifactRating.Appraiser.Param] = {
        var result: [ArtifactRating.Appraiser.Param] = [
            .cr, .cd, .er, .em, .atkAmp, .atk, .hpAmp, .hp, .defAmp, .def,
        ]
        EnkaGI.QueryRelated.Avatar.TeyvatElement.allCases.forEach { element in
            result.append(.dmgAmp(element))
        }
        return result
    }()
}

// MARK: - ArtifactRating.Appraiser.Param + RawRepresentable

extension ArtifactRating.Appraiser.Param: RawRepresentable {
    public init?(rawValue: String) {
        let matched = Self.allCases.first { rawValue == $0.rawValue }
        guard let matched else { return nil }
        self = matched
    }

    public var rawValue: String {
        switch self {
        case .cr: return "CriticalChanceBase"
        case .cd: return "CriticalDamageBase"
        case .er: return "SPRatioBase"
        case .em: return "ElementalMastery"
        case .atkAmp: return "AttackAddedRatio"
        case .atk: return "AttackDelta"
        case .hpAmp: return "HPAddedRatio"
        case .hp: return "HPDelta"
        case .defAmp: return "DefenceAddedRatio"
        case .def: return "DefenceDelta"
        case let .dmgAmp(teyvatElement):
            return switch teyvatElement {
            case .physico: "PhysicalAddedRatio"
            case .anemo: "WindAddedRatio"
            case .geo: "RockAddedRatio"
            case .electro: "ThunderAddedRatio"
            case .dendro: "GrassAddedRatio"
            case .hydro: "WaterAddedRatio"
            case .pyro: "FireAddedRatio"
            case .cryo: "IceAddedRatio"
            }
        case .heal: return "HealRatioBase"
        }
    }
}

// MARK: - DataDumper

public enum DataDumper {
    public struct StatScoreModelDecodable: Codable, Hashable {
        public typealias Dict = [String: Self]

        public var main: [String: [String: Double]]
        public var weight: [String: Double]
        public var max: Double
    }

    public static func dumpArtifactModelData() -> [String: [String: Double]] {
        var result = [String: [String: Double]]()
        CharacterAsset.allCases.forEach { character in
            guard character != .Paimon else { return }
            let model = character.getArtifactRatingModel()
            if character == .Hotaru || character == .Sora {
                EnkaGI.QueryRelated.Avatar.TeyvatElement.allCases.forEach { element in
                    var newModel = model
                    newModel[.dmgAmp(element)] = .highest
                    additionalValues: switch element {
                    case .anemo, .geo:
                        newModel[.er] = .highest
                    case .electro:
                        newModel[.er] = .highest
                        newModel[.em] = .higher
                    case .dendro:
                        newModel[.er] = .highest
                        newModel[.em] = .highest
                    default: break additionalValues
                    }
                    let charID = character.rawValue.description + "_" + element.rawValue
                    newModel.forEach { prop, weight in
                        result[charID, default: [:]][prop.rawValue] = weight.srsValue
                    }
                }
            } else {
                var elementAmpDealt = false
                model.forEach { prop, weight in
                    propCheck: switch prop {
                    case .dmgAmp: elementAmpDealt = true
                    default: break propCheck
                    }
                    result[character.rawValue.description, default: [:]][prop.rawValue] = weight.srsValue
                }
                guard !elementAmpDealt, let element = character.element else { return }
                result[
                    character.rawValue.description,
                    default: [:]
                ][ArtifactRating.Appraiser.Param.dmgAmp(element).rawValue] = 1
            }
        }
        return result
    }

    public static func dumpArtifactModelDataNeo() -> StatScoreModelDecodable.Dict {
        var result = StatScoreModelDecodable.Dict()
        let rawData = dumpArtifactModelData()
        rawData.forEach { charID, allTable in
            var mainTable = [String: [String: Double]]()
            for i in 1 ... 5 {
                switch i {
                case 1:
                    mainTable[i.description] = ["HPDelta": 1]
                case 2:
                    mainTable[i.description] = ["AttackDelta": 1]
                case 3:
                    let allowedParams: [ArtifactRating.Appraiser.Param] = [
                        .hpAmp, .atkAmp, .defAmp, .em, .er,
                    ]
                    let allowedParamTags = allowedParams.map(\.rawValue)
                    allowedParamTags.forEach { param in
                        guard let value = allTable[param] else { return }
                        mainTable[i.description, default: [:]][param] = value
                    }
                case 4:
                    var allowedParams: [ArtifactRating.Appraiser.Param] = [
                        .hpAmp, .atkAmp, .defAmp, .em,
                    ]
                    EnkaGI.QueryRelated.Avatar.TeyvatElement.allCases.forEach { element in
                        allowedParams.append(.dmgAmp(element))
                    }
                    let allowedParamTags = allowedParams.map(\.rawValue)
                    allowedParamTags.forEach { param in
                        guard let value = allTable[param] else { return }
                        mainTable[i.description, default: [:]][param] = value
                    }
                case 5:
                    let allowedParams: [ArtifactRating.Appraiser.Param] = [
                        .hpAmp, .atkAmp, .defAmp, .em, .heal, .cr, .cd,
                    ]
                    let allowedParamTags = allowedParams.map(\.rawValue)
                    allowedParamTags.forEach { param in
                        guard let value = allTable[param] else { return }
                        mainTable[i.description, default: [:]][param] = value
                    }
                default: break
                }
            }
            let newEntry = StatScoreModelDecodable(
                main: mainTable,
                weight: allTable,
                max: 10
            )
            result[charID] = newEntry
        }
        return result
    }
}

#endif
