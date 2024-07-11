// (c) 2022 and onwards Pizza Studio (GPL v3.0 License).
// ====================
// This code is released under the GPL v3.0 License (SPDX-License-Identifier: GPL-3.0)

extension ArtifactRating.RatingRequest.Artifact3MainProp {
    var translated: ArtifactRating.Appraiser.Param {
        switch self {
        case .hpAmp: return .hpAmp
        case .atkAmp: return .atkAmp
        case .defAmp: return .defAmp
        case .em: return .em
        case .er: return .er
        }
    }
}

extension ArtifactRating.RatingRequest.Artifact4MainProp {
    var translated: ArtifactRating.Appraiser.Param {
        switch self {
        case .hpAmp: return .hpAmp
        case .atkAmp: return .atkAmp
        case .defAmp: return .defAmp
        case .em: return .em
        case .dmgAmpPhysico: return .dmgAmp(.physico)
        case .dmgAmpPyro: return .dmgAmp(.pyro)
        case .dmgAmpHydro: return .dmgAmp(.hydro)
        case .dmgAmpCryo: return .dmgAmp(.cryo)
        case .dmgAmpElectro: return .dmgAmp(.electro)
        case .dmgAmpAnemo: return .dmgAmp(.anemo)
        case .dmgAmpGeo: return .dmgAmp(.geo)
        case .dmgAmpDendro: return .dmgAmp(.dendro)
        }
    }
}

extension ArtifactRating.RatingRequest.Artifact5MainProp {
    var translated: ArtifactRating.Appraiser.Param {
        switch self {
        case .hpAmp: return .hpAmp
        case .atkAmp: return .atkAmp
        case .defAmp: return .defAmp
        case .em: return .em
        case .critRate: return .cr
        case .critDmg: return .cd
        case .healingBonus: return .heal
        }
    }
}
