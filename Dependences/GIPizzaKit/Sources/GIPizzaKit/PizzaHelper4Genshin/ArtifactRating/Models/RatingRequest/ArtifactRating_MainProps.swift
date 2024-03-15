// (c) 2023 and onwards Pizza Studio (GPL v3.0 License).
// ====================
// This code is released under the GPL v3.0 License (SPDX-License-Identifier: GPL-3.0)

extension ArtifactRating.RatingRequest {
    public enum Artifact3MainProp: Int {
        case hpAmp = 1
        case atkAmp = 2
        case defAmp = 3
        case em = 4
        case er = 5
    }

    public enum Artifact4MainProp: Int {
        case hpAmp = 1
        case atkAmp = 2
        case defAmp = 3
        case em = 4
        case dmgAmpPhysico = 5
        case dmgAmpPyro = 6
        case dmgAmpHydro = 7
        case dmgAmpCryo = 8
        case dmgAmpElectro = 9
        case dmgAmpAnemo = 10
        case dmgAmpGeo = 11
        case dmgAmpDendro = 12
    }

    public enum Artifact5MainProp: Int {
        case hpAmp = 1
        case atkAmp = 2
        case defAmp = 3
        case em = 4
        case critRate = 5
        case critDmg = 6
        case healingBonus = 7
    }
}
