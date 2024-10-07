// (c) 2022 and onwards Pizza Studio (GPL v3.0 License).
// ====================
// This code is released under the GPL v3.0 License (SPDX-License-Identifier: GPL-3.0)

// MARK: - ArtifactRating.CharacterStatScoreModel

extension ArtifactRating {
    public typealias CharacterStatScoreModel = [ArtifactRating.Appraiser.Param: ArtifactSubStatScore]
}

extension ArtifactRating.CharacterStatScoreModel {
    func getRaw(_ param: ArtifactRating.Appraiser.Param) -> Double {
        if let fetched = self[param] {
            return fetched.rawValue
        }
        switch param {
        case .dmgAmp: return ArtifactSubStatScore.highest.rawValue
        default: return 0
        }
    }
}

// 以下内容不受 GPL 保护。
// 其中，所有与圣遗物评分的方法均衍生自下述来源：
// - 爱丽丝工房的原始评分脚本: https://github.com/Kamihimmel/artifactrating/
// - 披萨助手依据 BiliBili 百科的主词条推荐而做出的决策。
// 详情请洽下文的具体的内文脚注。

extension CharacterAsset {
    /// 这个部分的角色排序暂时按照爱丽丝工房的脚本来处理。
    func getArtifactRatingModel() -> ArtifactRating.CharacterStatScoreModel {
        switch self {
        case .Miko: return [
                .cr: .highest,
                .cd: .highest,
                .er: .none,
                .em: .higher,
                .atkAmp: .high,
                .atk: .lower,
                .hpAmp: .none,
                .hp: .none,
                .defAmp: .none,
                .def: .none,
            ]
        case .Xiao: return [
                .cr: .highest,
                .cd: .highest,
                .er: .none,
                .em: .none,
                .atkAmp: .high,
                .atk: .low,
                .hpAmp: .none,
                .hp: .none,
                .defAmp: .none,
                .def: .none,
            ]
        case .Hutao: return [
                .cr: .highest,
                .cd: .highest,
                .er: .none,
                .em: .higher,
                .atkAmp: .medium,
                .atk: .lower,
                .hpAmp: .high,
                .hp: .low,
                .defAmp: .none,
                .def: .none,
            ]
        case .Ganyu: return [
                .cr: .highest,
                .cd: .highest,
                .er: .none,
                .em: .higher,
                .atkAmp: .higher,
                .atk: .medium,
                .hpAmp: .none,
                .hp: .none,
                .defAmp: .none,
                .def: .none,
            ]
        case .Yelan: return [
                .cr: .highest,
                .cd: .highest,
                .er: .medium,
                .em: .medium,
                .atkAmp: .none,
                .atk: .none,
                .hpAmp: .highest,
                .hp: .medium,
                .defAmp: .none,
                .def: .none,
            ]
        case .Ei: return [
                .cr: .highest,
                .cd: .highest,
                .er: .highest,
                .em: .none,
                .atkAmp: .high,
                .atk: .low,
                .hpAmp: .none,
                .hp: .none,
                .defAmp: .none,
                .def: .none,
            ]
        case .Kunikuzushi: return [
                .cr: .highest,
                .cd: .highest,
                .er: .none,
                .em: .none,
                .atkAmp: .high,
                .atk: .low,
                .hpAmp: .none,
                .hp: .none,
                .defAmp: .none,
                .def: .none,
            ]
        case .Cyno: return [
                .cr: .highest,
                .cd: .highest,
                .er: .lower,
                .em: .higher,
                .atkAmp: .high,
                .atk: .low,
                .hpAmp: .none,
                .hp: .none,
                .defAmp: .none,
                .def: .none,
            ]
        case .Alhaitham: return [
                .cr: .highest,
                .cd: .highest,
                .er: .none,
                .em: .higher,
                .atkAmp: .high,
                .atk: .low,
                .hpAmp: .none,
                .hp: .none,
                .defAmp: .none,
                .def: .none,
            ]
        case .Itto: return [
                .cr: .highest,
                .cd: .highest,
                .er: .none,
                .em: .none,
                .atkAmp: .medium,
                .atk: .lower,
                .hpAmp: .none,
                .hp: .none,
                .defAmp: .high,
                .def: .none,
            ]
        case .Nahida: return [
                .cr: .highest,
                .cd: .highest,
                .er: .none,
                .em: .highest,
                .atkAmp: .medium,
                .atk: .lower,
                .hpAmp: .none,
                .hp: .none,
                .defAmp: .none,
                .def: .none,
            ]
        case .Nilou: return [
                .cr: .higher,
                .cd: .higher,
                .er: .none,
                .em: .higher,
                .atkAmp: .none,
                .atk: .none,
                .hpAmp: .highest,
                .hp: .high,
                .defAmp: .none,
                .def: .none,
            ]
        case .Ayaka: return [
                .cr: .highest,
                .cd: .highest,
                .er: .none,
                .em: .none,
                .atkAmp: .higher,
                .atk: .medium,
                .hpAmp: .none,
                .hp: .none,
                .defAmp: .none,
                .def: .none,
            ]
        case .Ayato: return [
                .cr: .highest,
                .cd: .highest,
                .er: .none,
                .em: .none,
                .atkAmp: .high,
                .atk: .low,
                .hpAmp: .high,
                .hp: .low,
                .defAmp: .none,
                .def: .none,
            ]
        case .Tighnari: return [
                .cr: .highest,
                .cd: .highest,
                .er: .none,
                .em: .higher,
                .atkAmp: .high,
                .atk: .low,
                .hpAmp: .none,
                .hp: .none,
                .defAmp: .none,
                .def: .none,
            ]
        case .Yoimiya: return [
                .cr: .highest,
                .cd: .highest,
                .er: .none,
                .em: .medium,
                .atkAmp: .high,
                .atk: .low,
                .hpAmp: .none,
                .hp: .none,
                .defAmp: .none,
                .def: .none,
            ]
        case .Eula: return [
                .cr: .highest,
                .cd: .highest,
                .er: .none,
                .em: .medium,
                .atkAmp: .high,
                .atk: .low,
                .hpAmp: .none,
                .hp: .none,
                .defAmp: .none,
                .def: .none,
                .dmgAmp(.physico): .highest, // Shiki Suen
            ]
        case .Tartaglia: return [
                .cr: .highest,
                .cd: .highest,
                .er: .none,
                .em: .high,
                .atkAmp: .high,
                .atk: .low,
                .hpAmp: .none,
                .hp: .none,
                .defAmp: .none,
                .def: .none,
            ]
        case .Zhongli: return [
                .cr: .highest,
                .cd: .highest,
                .er: .lower,
                .em: .high,
                .atkAmp: .medium,
                .atk: .lower,
                .hpAmp: .higher,
                .hp: .medium,
                .defAmp: .none,
                .def: .none,
            ]
        case .Kazuha: return [
                .cr: .highest,
                .cd: .highest,
                .er: .lower,
                .em: .highest,
                .atkAmp: .higher,
                .atk: .medium,
                .hpAmp: .none,
                .hp: .none,
                .defAmp: .none,
                .def: .none,
            ]
        case .Venti: return [
                .cr: .highest,
                .cd: .highest,
                .er: .lower,
                .em: .highest,
                .atkAmp: .higher,
                .atk: .medium,
                .hpAmp: .none,
                .hp: .none,
                .defAmp: .none,
                .def: .none,
            ]
        case .Keqing: return [
                .cr: .highest,
                .cd: .highest,
                .er: .none,
                .em: .higher,
                .atkAmp: .high,
                .atk: .low,
                .hpAmp: .none,
                .hp: .none,
                .defAmp: .none,
                .def: .none,
            ]
        case .Shenhe: return [
                .cr: .highest,
                .cd: .highest,
                .er: .lower,
                .em: .none,
                .atkAmp: .highest,
                .atk: .medium,
                .hpAmp: .none,
                .hp: .none,
                .defAmp: .none,
                .def: .none,
            ]
        case .Diluc: return [
                .cr: .highest,
                .cd: .highest,
                .er: .none,
                .em: .higher,
                .atkAmp: .high,
                .atk: .low,
                .hpAmp: .none,
                .hp: .none,
                .defAmp: .none,
                .def: .none,
            ]
        case .Klee: return [
                .cr: .highest,
                .cd: .highest,
                .er: .none,
                .em: .medium,
                .atkAmp: .high,
                .atk: .low,
                .hpAmp: .none,
                .hp: .none,
                .defAmp: .none,
                .def: .none,
            ]
        case .Jean: return [
                .cr: .highest,
                .cd: .highest,
                .er: .none,
                .em: .none,
                .atkAmp: .higher,
                .atk: .medium,
                .hpAmp: .lower,
                .hp: .lowest,
                .defAmp: .none,
                .def: .none,
            ]
        case .Bennett: return [
                .cr: .highest,
                .cd: .highest,
                .er: .highest,
                .em: .medium,
                .atkAmp: .high,
                .atk: .low,
                .hpAmp: .high,
                .hp: .low,
                .defAmp: .none,
                .def: .none,
            ]
        case .Kokomi: return [
                .cr: .none,
                .cd: .none,
                .er: .higher,
                .em: .none,
                .atkAmp: .high,
                .atk: .low,
                .hpAmp: .highest,
                .hp: .medium,
                .defAmp: .none,
                .def: .none,
            ]
        case .Xingqiu: return [
                .cr: .highest,
                .cd: .highest,
                .er: .high,
                .em: .low,
                .atkAmp: .high,
                .atk: .low,
                .hpAmp: .none,
                .hp: .none,
                .defAmp: .none,
                .def: .none,
            ]
        case .Xiangling: return [
                .cr: .highest,
                .cd: .highest,
                .er: .higher,
                .em: .higher,
                .atkAmp: .high,
                .atk: .low,
                .hpAmp: .none,
                .hp: .none,
                .defAmp: .none,
                .def: .none,
            ]
        case .Fischl: return [
                .cr: .highest,
                .cd: .highest,
                .er: .none,
                .em: .high,
                .atkAmp: .high,
                .atk: .low,
                .hpAmp: .none,
                .hp: .none,
                .defAmp: .none,
                .def: .none,
            ]
        case .Shinobu: return [
                .cr: .highest,
                .cd: .highest,
                .er: .high,
                .em: .highest,
                .atkAmp: .lower,
                .atk: .lowest,
                .hpAmp: .higher,
                .hp: .medium,
                .defAmp: .none,
                .def: .none,
            ]
        case .Dehya: return [
                .cr: .highest,
                .cd: .highest,
                .er: .none,
                .em: .high,
                .atkAmp: .high,
                .atk: .low,
                .hpAmp: .medium,
                .hp: .lower,
                .defAmp: .none,
                .def: .none,
            ]
        case .Faruzan: return [
                .cr: .highest,
                .cd: .highest,
                .er: .high,
                .em: .none,
                .atkAmp: .high,
                .atk: .low,
                .hpAmp: .none,
                .hp: .none,
                .defAmp: .none,
                .def: .none,
            ]
        case .Albedo: return [
                .cr: .highest,
                .cd: .highest,
                .er: .none,
                .em: .none,
                .atkAmp: .lower,
                .atk: .lowest,
                .hpAmp: .none,
                .hp: .none,
                .defAmp: .high,
                .def: .low,
            ]
        case .Mona: return [
                .cr: .highest,
                .cd: .highest,
                .er: .medium,
                .em: .high,
                .atkAmp: .high,
                .atk: .low,
                .hpAmp: .none,
                .hp: .none,
                .defAmp: .none,
                .def: .none,
            ]
        case .Sara: return [
                .cr: .highest,
                .cd: .highest,
                .er: .medium,
                .em: .lower,
                .atkAmp: .medium,
                .atk: .lower,
                .hpAmp: .none,
                .hp: .none,
                .defAmp: .none,
                .def: .none,
            ]
        case .Gorou: return [
                .cr: .highest,
                .cd: .highest,
                .er: .highest,
                .em: .none,
                .atkAmp: .medium,
                .atk: .lower,
                .hpAmp: .none,
                .hp: .none,
                .defAmp: .high,
                .def: .medium,
            ]
        case .Yunjin: return [
                .cr: .highest,
                .cd: .highest,
                .er: .highest,
                .em: .none,
                .atkAmp: .lower,
                .atk: .lowest,
                .hpAmp: .none,
                .hp: .none,
                .defAmp: .highest,
                .def: .high,
            ]
        case .Rosaria: return [
                .cr: .highest,
                .cd: .highest,
                .er: .higher,
                .em: .high,
                .atkAmp: .high,
                .atk: .low,
                .hpAmp: .none,
                .hp: .none,
                .defAmp: .none,
                .def: .none,
            ]
        case .Thoma: return [
                .cr: .highest,
                .cd: .highest,
                .er: .higher,
                .em: .higher,
                .atkAmp: .medium,
                .atk: .lower,
                .hpAmp: .higher,
                .hp: .medium,
                .defAmp: .none,
                .def: .none,
            ]
        case .Layla: return [
                .cr: .highest,
                .cd: .highest,
                .er: .none,
                .em: .none,
                .atkAmp: .medium,
                .atk: .lower,
                .hpAmp: .highest,
                .hp: .high,
                .defAmp: .none,
                .def: .none,
            ]
        case .Diona: return [
                .cr: .highest,
                .cd: .highest,
                .er: .higher,
                .em: .none,
                .atkAmp: .medium,
                .atk: .lower,
                .hpAmp: .highest,
                .hp: .high,
                .defAmp: .none,
                .def: .none,
            ]
        case .Candace: return [
                .cr: .highest,
                .cd: .highest,
                .er: .medium,
                .em: .none,
                .atkAmp: .none,
                .atk: .none,
                .hpAmp: .higher,
                .hp: .medium,
                .defAmp: .none,
                .def: .none,
            ]
        case .Beidou: return [
                .cr: .highest,
                .cd: .highest,
                .er: .medium,
                .em: .medium,
                .atkAmp: .high,
                .atk: .low,
                .hpAmp: .lower,
                .hp: .lowest,
                .defAmp: .none,
                .def: .none,
            ]
        case .Mika: return [
                .cr: .highest,
                .cd: .highest,
                .er: .medium,
                .em: .none,
                .atkAmp: .high,
                .atk: .low,
                .hpAmp: .high,
                .hp: .low,
                .defAmp: .none,
                .def: .none,
            ]
        case .Razor: return [
                .cr: .highest,
                .cd: .highest,
                .er: .lower,
                .em: .none,
                .atkAmp: .high,
                .atk: .low,
                .hpAmp: .none,
                .hp: .none,
                .defAmp: .none,
                .def: .none,
                .dmgAmp(.physico): .highest, // Shiki Suen
            ]
        case .Noelle: return [
                .cr: .highest,
                .cd: .highest,
                .er: .lower,
                .em: .none,
                .atkAmp: .lower,
                .atk: .lowest,
                .hpAmp: .none,
                .hp: .none,
                .defAmp: .high,
                .def: .low,
            ]
        case .Ningguang: return [
                .cr: .highest,
                .cd: .highest,
                .er: .none,
                .em: .none,
                .atkAmp: .high,
                .atk: .low,
                .hpAmp: .none,
                .hp: .none,
                .defAmp: .none,
                .def: .none,
            ]
        case .Sucrose: return [
                .cr: .highest,
                .cd: .highest,
                .er: .lower,
                .em: .highest,
                .atkAmp: .higher,
                .atk: .medium,
                .hpAmp: .none,
                .hp: .none,
                .defAmp: .none,
                .def: .none,
            ]
        case .Yanfei: return [
                .cr: .highest,
                .cd: .highest,
                .er: .none,
                .em: .medium,
                .atkAmp: .high,
                .atk: .low,
                .hpAmp: .lower,
                .hp: .lowest,
                .defAmp: .none,
                .def: .none,
            ]
        case .Heizou: return [
                .cr: .highest,
                .cd: .highest,
                .er: .none,
                .em: .none,
                .atkAmp: .high,
                .atk: .low,
                .hpAmp: .none,
                .hp: .none,
                .defAmp: .none,
                .def: .none,
            ]
        case .Kaeya: return [
                .cr: .highest,
                .cd: .highest,
                .er: .medium,
                .em: .none,
                .atkAmp: .high,
                .atk: .low,
                .hpAmp: .none,
                .hp: .none,
                .defAmp: .none,
                .def: .none,
            ]
        case .Yaoyao: return [
                .cr: .highest,
                .cd: .highest,
                .er: .lower,
                .em: .high,
                .atkAmp: .high,
                .atk: .low,
                .hpAmp: .high,
                .hp: .low,
                .defAmp: .none,
                .def: .none,
            ]
        case .Collei: return [
                .cr: .highest,
                .cd: .highest,
                .er: .medium,
                .em: .high,
                .atkAmp: .high,
                .atk: .low,
                .hpAmp: .none,
                .hp: .none,
                .defAmp: .none,
                .def: .none,
            ]
        case .Sayu: return [
                .cr: .highest,
                .cd: .highest,
                .er: .medium,
                .em: .high,
                .atkAmp: .high,
                .atk: .low,
                .hpAmp: .none,
                .hp: .none,
                .defAmp: .none,
                .def: .none,
            ]
        case .Dori: return [
                .cr: .highest,
                .cd: .highest,
                .er: .medium,
                .em: .low,
                .atkAmp: .high,
                .atk: .low,
                .hpAmp: .high,
                .hp: .low,
                .defAmp: .none,
                .def: .none,
            ]
        case .Chongyun: return [
                .cr: .highest,
                .cd: .highest,
                .er: .low,
                .em: .high,
                .atkAmp: .high,
                .atk: .low,
                .hpAmp: .none,
                .hp: .none,
                .defAmp: .none,
                .def: .none,
            ]
        case .Barbara:
            // By ShikiSuen.
            return [
                .cr: .highest,
                .cd: .highest,
                .er: .higher,
                .em: .high,
                .atkAmp: .high,
                .atk: .low,
                .hpAmp: .highest,
                .hp: .higher,
                .defAmp: .none,
                .def: .none,
            ]
        case .Baizhu:
            // By ShikiSuen.
            return [
                .cr: .highest,
                .cd: .highest,
                .er: .higher,
                .em: .high,
                .atkAmp: .high,
                .atk: .low,
                .hpAmp: .highest,
                .hp: .high,
                .defAmp: .none,
                .def: .none,
            ]
        case .Qiqi: return [
                .cr: .highest,
                .cd: .highest,
                .er: .high,
                .em: .lower,
                .atkAmp: .high,
                .atk: .low,
                .hpAmp: .none,
                .hp: .none,
                .defAmp: .none,
                .def: .none,
            ]
        case .Amber: return [
                .cr: .highest,
                .cd: .highest,
                .er: .medium,
                .em: .high,
                .atkAmp: .high,
                .atk: .low,
                .hpAmp: .lower,
                .hp: .low,
                .defAmp: .none,
                .def: .none,
            ]
        case .Xinyan: return [
                .cr: .highest,
                .cd: .highest,
                .er: .medium,
                .em: .none,
                .atkAmp: .high,
                .atk: .low,
                .hpAmp: .none,
                .hp: .none,
                .defAmp: .high,
                .def: .low,
                .dmgAmp(.physico): .highest, // Shiki Suen
            ]
        case .Lisa: return [
                .cr: .highest,
                .cd: .highest,
                .er: .high,
                .em: .medium,
                .atkAmp: .high,
                .atk: .low,
                .hpAmp: .none,
                .hp: .none,
                .defAmp: .none,
                .def: .none,
            ]
        case .Aloy: return [
                .cr: .highest,
                .cd: .highest,
                .er: .lower,
                .em: .lower,
                .atkAmp: .high,
                .atk: .low,
                .hpAmp: .none,
                .hp: .none,
                .defAmp: .none,
                .def: .none,
            ]
        case .Sora: return [
                .cr: .highest,
                .cd: .highest,
                .er: .high,
                .em: .medium,
                .atkAmp: .high,
                .atk: .low,
                .hpAmp: .none,
                .hp: .none,
                .defAmp: .none,
                .def: .none,
            ]
        case .Hotaru: return [
                .cr: .highest,
                .cd: .highest,
                .er: .high,
                .em: .medium,
                .atkAmp: .high,
                .atk: .low,
                .hpAmp: .none,
                .hp: .none,
                .defAmp: .none,
                .def: .none,
            ]
        case .Lyney: return [
                .cr: .highest,
                .cd: .highest,
                .er: .lower,
                .em: .lower,
                .atkAmp: .high,
                .atk: .low,
                .hpAmp: .none,
                .hp: .none,
                .defAmp: .high,
                .def: .low,
            ]
        case .Wriothesley: return [
                .cr: .highest,
                .cd: .highest,
                .er: .low,
                .em: .low,
                .atkAmp: .high,
                .atk: .low,
                .hpAmp: .none,
                .hp: .none,
                .defAmp: .none,
                .def: .none,
            ]
        case .Neuvillette: return [
                .cr: .highest,
                .cd: .highest,
                .er: .low,
                .em: .none,
                .atkAmp: .none,
                .atk: .none,
                .hpAmp: .highest,
                .hp: .medium,
                .defAmp: .none,
                .def: .none,
            ]
        case .Furina: return [
                .cr: .highest,
                .cd: .highest,
                .er: .high,
                .em: .none,
                .atkAmp: .none,
                .atk: .none,
                .hpAmp: .highest,
                .hp: .medium,
                .defAmp: .none,
                .def: .none,
            ]
        case .Navia: return [
                .cr: .highest,
                .cd: .highest,
                .er: .low,
                .em: .none,
                .atkAmp: .high,
                .atk: .low,
                .hpAmp: .none,
                .hp: .none,
                .defAmp: .none,
                .def: .none,
            ]
        // 此处为止的内容是截至 2024 年 2 月时的爱丽丝工房原始脚本内容。
        // 派蒙不是可控角色（而是类似于 null value 的存在），所以所有圣遗物都给 none。
        case .Paimon: return [
                .cr: .none,
                .cd: .none,
                .er: .none,
                .em: .none,
                .atkAmp: .none,
                .atk: .none,
                .hpAmp: .none,
                .hp: .none,
                .defAmp: .none,
                .def: .none,
            ]
        case .Kaveh:
            // By ShikiSuen, referring Bilibili Wiki.
            return [
                .cr: .medium,
                .cd: .medium,
                .er: .high,
                .em: .highest,
                .atkAmp: .medium,
                .atk: .medium,
                .hpAmp: .none,
                .hp: .none,
                .defAmp: .none,
                .def: .none,
            ]
        case .Kirara:
            // By ShikiSuen, referring Bilibili Wiki.
            return [
                .cr: .medium, // 西风剑加成
                .cd: .none,
                .er: .high,
                .em: .none,
                .atkAmp: .none,
                .atk: .none,
                .hpAmp: .highest,
                .hp: .higher,
                .defAmp: .none,
                .def: .none,
            ]
        case .Lynette:
            // By ShikiSuen, referring Bilibili Wiki.
            return [
                .cr: .highest,
                .cd: .highest,
                .er: .highest,
                .em: .high,
                .atkAmp: .higher,
                .atk: .high,
                .hpAmp: .none,
                .hp: .none,
                .defAmp: .none,
                .def: .none,
            ]
        case .Freminet:
            // By ShikiSuen, referring Bilibili Wiki.
            return [
                .cr: .highest,
                .cd: .highest,
                .er: .none,
                .em: .none,
                .atkAmp: .higher,
                .atk: .high,
                .hpAmp: .none,
                .hp: .none,
                .defAmp: .none,
                .def: .none,
            ]
        case .Charlotte:
            // By ShikiSuen, referring Bilibili Wiki.
            return [
                .cr: .higher,
                .cd: .none,
                .er: .highest,
                .em: .none,
                .atkAmp: .highest,
                .atk: .highest,
                .hpAmp: .none,
                .hp: .none,
                .defAmp: .none,
                .def: .none,
                .heal: .high,
            ]
        case .Chevreuse:
            // By ShikiSuen, referring Bilibili Wiki.
            return [
                .cr: .higher,
                .cd: .none,
                .er: .higher,
                .em: .none,
                .atkAmp: .none,
                .atk: .none,
                .hpAmp: .highest,
                .hp: .highest,
                .defAmp: .none,
                .def: .none,
            ]
        case .Gaming:
            // By ShikiSuen, referring Bilibili Wiki.
            return [
                .cr: .highest,
                .cd: .highest,
                .er: .medium,
                .em: .highest,
                .atkAmp: .highest,
                .atk: .higher,
                .hpAmp: .none,
                .hp: .none,
                .defAmp: .none,
                .def: .none,
            ]
        case .Xianyun:
            // By ShikiSuen, referring Bilibili Wiki.
            return [
                .cr: .higher,
                .cd: .medium,
                .er: .highest,
                .em: .none,
                .atkAmp: .highest,
                .atk: .high,
                .hpAmp: .none,
                .hp: .none,
                .defAmp: .none,
                .def: .none,
            ]
        case .Chiori:
            // By Kamihimmel:
            return [
                .cr: .highest,
                .cd: .highest,
                .er: .low,
                .em: .none,
                .atkAmp: .medium,
                .atk: .low,
                .hpAmp: .none,
                .hp: .none,
                .defAmp: .highest,
                .def: .medium,
            ]
        case .Sigewinne:
            // By ShikiSuen.
            return [
                .cr: .medium,
                .cd: .medium,
                .er: .medium,
                .em: .medium,
                .atkAmp: .high,
                .atk: .low,
                .hpAmp: .highest,
                .hp: .higher,
                .defAmp: .none,
                .def: .none,
            ]
        case .Arlecchino:
            // By Kamihimmel:
            return [
                .cr: .highest,
                .cd: .highest,
                .er: .none,
                .em: .medium,
                .atkAmp: .high,
                .atk: .low,
                .hpAmp: .none,
                .hp: .none,
                .defAmp: .none,
                .def: .none,
            ]
        case .Sethos:
            // By ShikiSuen.
            return [
                .cr: .highest,
                .cd: .highest,
                .er: .none,
                .em: .highest,
                .atkAmp: .high,
                .atk: .low,
                .hpAmp: .none,
                .hp: .none,
                .defAmp: .none,
                .def: .none,
            ]
        case .Clorinde:
            // By Kamihimmel.
            return [
                .cr: .highest,
                .cd: .highest,
                .er: .low,
                .em: .medium,
                .atkAmp: .high,
                .atk: .low,
                .hpAmp: .none,
                .hp: .none,
                .defAmp: .none,
                .def: .none,
            ]
        case .Emilie:
            // By ShikiSuen.
            return [
                .cr: .highest,
                .cd: .highest,
                .er: .medium,
                .em: .higher,
                .atkAmp: .higher,
                .atk: .medium,
                .hpAmp: .none,
                .hp: .none,
                .defAmp: .none,
                .def: .none,
            ]
        case .Kachina:
            // By ShikiSuen.
            return [
                .cr: .highest,
                .cd: .highest,
                .er: .none,
                .em: .none,
                .atkAmp: .medium,
                .atk: .lower,
                .hpAmp: .none,
                .hp: .none,
                .defAmp: .high,
                .def: .none,
            ]
        case .Kinich:
            // By ShikiSuen.
            return [
                .cr: .highest,
                .cd: .highest,
                .er: .none,
                .em: .higher,
                .atkAmp: .high,
                .atk: .low,
                .hpAmp: .none,
                .hp: .none,
                .defAmp: .none,
                .def: .none,
            ]
        case .Mualani:
            // By ShikiSuen.
            return [
                .cr: .highest,
                .cd: .highest,
                .er: .low,
                .em: .none,
                .atkAmp: .none,
                .atk: .none,
                .hpAmp: .highest,
                .hp: .medium,
                .defAmp: .none,
                .def: .none,
            ]
        case .Xilonen:
            // By ShikiSuen.
            return [
                .cr: .highest,
                .cd: .highest,
                .er: .none,
                .em: .none,
                .atkAmp: .medium,
                .atk: .lower,
                .hpAmp: .none,
                .hp: .none,
                .defAmp: .high,
                .def: .none,
            ]
        }
    }
}
