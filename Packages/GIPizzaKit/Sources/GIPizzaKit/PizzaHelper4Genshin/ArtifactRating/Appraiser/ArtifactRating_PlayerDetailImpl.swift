// (c) 2022 and onwards Pizza Studio (GPL v3.0 License).
// ====================
// This code is released under the GPL v3.0 License (SPDX-License-Identifier: GPL-3.0)

// MARK: - Artifact Rating Support

extension PlayerDetail.Avatar {
    public func convert2ArtifactRatingModel() -> ArtifactRating.RatingRequest {
        let extractedData = extractArtifactSetData()
        return ArtifactRating.RatingRequest(
            cid: enkaID,
            characterElement: element.enumerationId,
            flower: extractedData[.flower] ?? .init(),
            plume: extractedData[.plume] ?? .init(),
            sands: extractedData[.sands] ?? .init(),
            goblet: extractedData[.goblet] ?? .init(),
            circlet: extractedData[.circlet] ?? .init()
        )
    }

    typealias ArtifactsDataDictionary = [Artifact.PartType: ArtifactRating.RatingRequest.Artifact]

    func extractArtifactSetData() -> ArtifactsDataDictionary {
        var arrResult = ArtifactsDataDictionary()
        artifacts.forEach { thisRawEnkaArtifact in
            var result = ArtifactRating.RatingRequest.Artifact()
            let artifactType = thisRawEnkaArtifact.artifactType
            result.star = thisRawEnkaArtifact.rankLevel.rawValue
            result.setId = thisRawEnkaArtifact.setId ?? -114_514
            result.lv = thisRawEnkaArtifact.level
            // 副词条
            thisRawEnkaArtifact.subAttributes.forEach { thisRawEnkaAttr in
                defer { print("\(thisRawEnkaAttr.rawName)-\(thisRawEnkaAttr.value)") }
                switch AvatarAttribute(rawValue: thisRawEnkaAttr.rawName) {
                case .ATK: result.atk = thisRawEnkaAttr.value
                case .DEF: result.def = thisRawEnkaAttr.value
                case .EM: result.em = thisRawEnkaAttr.value
                case .critRate: result.critRate = thisRawEnkaAttr.value
                case .critDmg: result.critDmg = thisRawEnkaAttr.value
                case .chargeEfficiency: result.er = thisRawEnkaAttr.value
                case .HP: result.hp = thisRawEnkaAttr.value
                case .ATKAmp: result.atkAmp = thisRawEnkaAttr.value
                case .HPAmp: result.hpAmp = thisRawEnkaAttr.value
                case .DEFAmp: result.defAmp = thisRawEnkaAttr.value
                default: break
                }
            }
            // 主词条。
            let mainAttributeType = AvatarAttribute(rawValue: thisRawEnkaArtifact.mainAttribute.rawName)
            switch (artifactType, mainAttributeType) {
            case (.sands, .HPAmp): result.mainProp3 = .hpAmp
            case (.sands, .ATKAmp): result.mainProp3 = .atkAmp
            case (.sands, .DEFAmp): result.mainProp3 = .defAmp
            case (.sands, .EM): result.mainProp3 = .em
            case (.sands, .chargeEfficiency): result.mainProp3 = .er
            case (.sands, _): result.mainProp3 = nil
            case (.goblet, .HPAmp): result.mainProp4 = .hpAmp
            case (.goblet, .ATKAmp): result.mainProp4 = .atkAmp
            case (.goblet, .DEFAmp): result.mainProp4 = .defAmp
            case (.goblet, .EM): result.mainProp4 = .em
            case (.goblet, .dmgAmpPhysico): result.mainProp4 = .dmgAmpPhysico
            case (.goblet, .dmgAmpAnemo): result.mainProp4 = .dmgAmpAnemo
            case (.goblet, .dmgAmpGeo): result.mainProp4 = .dmgAmpGeo
            case (.goblet, .dmgAmpElectro): result.mainProp4 = .dmgAmpElectro
            case (.goblet, .dmgAmpDendro): result.mainProp4 = .dmgAmpDendro
            case (.goblet, .dmgAmpHydro): result.mainProp4 = .dmgAmpHydro
            case (.goblet, .dmgAmpPyro): result.mainProp4 = .dmgAmpPyro
            case (.goblet, .dmgAmpCryo): result.mainProp4 = .dmgAmpCryo
            case (.goblet, _): result.mainProp4 = nil
            case (.circlet, .HPAmp): result.mainProp5 = .hpAmp
            case (.circlet, .ATKAmp): result.mainProp5 = .atkAmp
            case (.circlet, .DEFAmp): result.mainProp5 = .defAmp
            case (.circlet, .EM): result.mainProp5 = .em
            case (.circlet, .critRate): result.mainProp5 = .critRate
            case (.circlet, .critDmg): result.mainProp5 = .critDmg
            case (.circlet, .healAmp): result.mainProp5 = .healingBonus
            case (.circlet, _): result.mainProp5 = nil
            case (_, _): break
            }
            arrResult[artifactType] = result
        }
        return arrResult
    }
}
