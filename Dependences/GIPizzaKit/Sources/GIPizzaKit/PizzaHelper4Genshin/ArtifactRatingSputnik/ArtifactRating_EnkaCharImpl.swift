//
//  ArtifactRating_EnkaCharImpl.swift
//
//
//  Created by ShikiSuen on 2024/3/15.
//

import Foundation

// MARK: - ArtifactSubStatScore

enum ArtifactSubStatScore: Double, Codable {
    case highest = 30
    case higher = 20
    case high = 15
    case medium = 10
    case low = 7.5
    case lower = 5
    case lowest = 2.5
    case none = 0
}

// MARK: - CharacterStatScoreModel

typealias CharacterStatScoreModel = [ArtifactRatingSputnik.Param: ArtifactSubStatScore]

extension CharacterStatScoreModel {
    func getRaw(_ param: ArtifactRatingSputnik.Param) -> Double {
        self[param]?.rawValue ?? 0
    }
}

extension CharacterAsset {
    /// 这个部分的角色排序暂时按照爱丽丝工房的脚本来处理。
    func getArtifactRatingModel() -> CharacterStatScoreModel {
        switch self {
        case .Miko: return [
                .cr: .highest,
                .cd: .highest,
                .er: .none,
                .em: .higher,
                .atkR: .high,
                .atk: .lower,
                .hpR: .none,
                .hp: .none,
                .defR: .none,
                .def: .none,
            ]
        case .Xiao: return [
                .cr: .highest,
                .cd: .highest,
                .er: .none,
                .em: .none,
                .atkR: .high,
                .atk: .low,
                .hpR: .none,
                .hp: .none,
                .defR: .none,
                .def: .none,
            ]
        case .Hutao: return [
                .cr: .highest,
                .cd: .highest,
                .er: .none,
                .em: .higher,
                .atkR: .medium,
                .atk: .lower,
                .hpR: .high,
                .hp: .low,
                .defR: .none,
                .def: .none,
            ]
        case .Ganyu: return [
                .cr: .highest,
                .cd: .highest,
                .er: .none,
                .em: .higher,
                .atkR: .higher,
                .atk: .medium,
                .hpR: .none,
                .hp: .none,
                .defR: .none,
                .def: .none,
            ]
        case .Yelan: return [
                .cr: .highest,
                .cd: .highest,
                .er: .medium,
                .em: .medium,
                .atkR: .none,
                .atk: .none,
                .hpR: .highest,
                .hp: .medium,
                .defR: .none,
                .def: .none,
            ]
        case .Ei: return [
                .cr: .highest,
                .cd: .highest,
                .er: .highest,
                .em: .none,
                .atkR: .high,
                .atk: .low,
                .hpR: .none,
                .hp: .none,
                .defR: .none,
                .def: .none,
            ]
        case .Kunikuzushi: return [
                .cr: .highest,
                .cd: .highest,
                .er: .none,
                .em: .none,
                .atkR: .high,
                .atk: .low,
                .hpR: .none,
                .hp: .none,
                .defR: .none,
                .def: .none,
            ]
        case .Cyno: return [
                .cr: .highest,
                .cd: .highest,
                .er: .lower,
                .em: .higher,
                .atkR: .high,
                .atk: .low,
                .hpR: .none,
                .hp: .none,
                .defR: .none,
                .def: .none,
            ]
        case .Alhaitham: return [
                .cr: .highest,
                .cd: .highest,
                .er: .none,
                .em: .higher,
                .atkR: .high,
                .atk: .low,
                .hpR: .none,
                .hp: .none,
                .defR: .none,
                .def: .none,
            ]
        case .Itto: return [
                .cr: .highest,
                .cd: .highest,
                .er: .none,
                .em: .none,
                .atkR: .medium,
                .atk: .lower,
                .hpR: .none,
                .hp: .none,
                .defR: .high,
                .def: .none,
            ]
        case .Nahida: return [
                .cr: .highest,
                .cd: .highest,
                .er: .none,
                .em: .highest,
                .atkR: .medium,
                .atk: .lower,
                .hpR: .none,
                .hp: .none,
                .defR: .none,
                .def: .none,
            ]
        case .Nilou: return [
                .cr: .higher,
                .cd: .higher,
                .er: .none,
                .em: .higher,
                .atkR: .none,
                .atk: .none,
                .hpR: .highest,
                .hp: .high,
                .defR: .none,
                .def: .none,
            ]
        case .Ayaka: return [
                .cr: .highest,
                .cd: .highest,
                .er: .none,
                .em: .none,
                .atkR: .higher,
                .atk: .medium,
                .hpR: .none,
                .hp: .none,
                .defR: .none,
                .def: .none,
            ]
        case .Ayato: return [
                .cr: .highest,
                .cd: .highest,
                .er: .none,
                .em: .none,
                .atkR: .high,
                .atk: .low,
                .hpR: .high,
                .hp: .low,
                .defR: .none,
                .def: .none,
            ]
        case .Tighnari: return [
                .cr: .highest,
                .cd: .highest,
                .er: .none,
                .em: .higher,
                .atkR: .high,
                .atk: .low,
                .hpR: .none,
                .hp: .none,
                .defR: .none,
                .def: .none,
            ]
        case .Yoimiya: return [
                .cr: .highest,
                .cd: .highest,
                .er: .none,
                .em: .medium,
                .atkR: .high,
                .atk: .low,
                .hpR: .none,
                .hp: .none,
                .defR: .none,
                .def: .none,
            ]
        case .Eula: return [
                .cr: .highest,
                .cd: .highest,
                .er: .none,
                .em: .medium,
                .atkR: .high,
                .atk: .low,
                .hpR: .none,
                .hp: .none,
                .defR: .none,
                .def: .none,
            ]
        case .Tartaglia: return [
                .cr: .highest,
                .cd: .highest,
                .er: .none,
                .em: .high,
                .atkR: .high,
                .atk: .low,
                .hpR: .none,
                .hp: .none,
                .defR: .none,
                .def: .none,
            ]
        case .Zhongli: return [
                .cr: .highest,
                .cd: .highest,
                .er: .lower,
                .em: .high,
                .atkR: .medium,
                .atk: .lower,
                .hpR: .higher,
                .hp: .medium,
                .defR: .none,
                .def: .none,
            ]
        case .Kazuha: return [
                .cr: .highest,
                .cd: .highest,
                .er: .lower,
                .em: .highest,
                .atkR: .higher,
                .atk: .medium,
                .hpR: .none,
                .hp: .none,
                .defR: .none,
                .def: .none,
            ]
        case .Venti: return [
                .cr: .highest,
                .cd: .highest,
                .er: .lower,
                .em: .highest,
                .atkR: .higher,
                .atk: .medium,
                .hpR: .none,
                .hp: .none,
                .defR: .none,
                .def: .none,
            ]
        case .Keqing: return [
                .cr: .highest,
                .cd: .highest,
                .er: .none,
                .em: .higher,
                .atkR: .high,
                .atk: .low,
                .hpR: .none,
                .hp: .none,
                .defR: .none,
                .def: .none,
            ]
        case .Shenhe: return [
                .cr: .highest,
                .cd: .highest,
                .er: .lower,
                .em: .none,
                .atkR: .highest,
                .atk: .medium,
                .hpR: .none,
                .hp: .none,
                .defR: .none,
                .def: .none,
            ]
        case .Diluc: return [
                .cr: .highest,
                .cd: .highest,
                .er: .none,
                .em: .higher,
                .atkR: .high,
                .atk: .low,
                .hpR: .none,
                .hp: .none,
                .defR: .none,
                .def: .none,
            ]
        case .Klee: return [
                .cr: .highest,
                .cd: .highest,
                .er: .none,
                .em: .medium,
                .atkR: .high,
                .atk: .low,
                .hpR: .none,
                .hp: .none,
                .defR: .none,
                .def: .none,
            ]
        case .Jean: return [
                .cr: .highest,
                .cd: .highest,
                .er: .none,
                .em: .none,
                .atkR: .higher,
                .atk: .medium,
                .hpR: .lower,
                .hp: .lowest,
                .defR: .none,
                .def: .none,
            ]
        case .Bennett: return [
                .cr: .highest,
                .cd: .highest,
                .er: .highest,
                .em: .medium,
                .atkR: .high,
                .atk: .low,
                .hpR: .high,
                .hp: .low,
                .defR: .none,
                .def: .none,
            ]
        case .Kokomi: return [
                .cr: .none,
                .cd: .none,
                .er: .higher,
                .em: .none,
                .atkR: .high,
                .atk: .low,
                .hpR: .highest,
                .hp: .medium,
                .defR: .none,
                .def: .none,
            ]
        case .Xingqiu: return [
                .cr: .highest,
                .cd: .highest,
                .er: .high,
                .em: .low,
                .atkR: .high,
                .atk: .low,
                .hpR: .none,
                .hp: .none,
                .defR: .none,
                .def: .none,
            ]
        case .Xiangling: return [
                .cr: .highest,
                .cd: .highest,
                .er: .higher,
                .em: .higher,
                .atkR: .high,
                .atk: .low,
                .hpR: .none,
                .hp: .none,
                .defR: .none,
                .def: .none,
            ]
        case .Fischl: return [
                .cr: .highest,
                .cd: .highest,
                .er: .none,
                .em: .high,
                .atkR: .high,
                .atk: .low,
                .hpR: .none,
                .hp: .none,
                .defR: .none,
                .def: .none,
            ]
        case .Shinobu: return [
                .cr: .highest,
                .cd: .highest,
                .er: .high,
                .em: .highest,
                .atkR: .lower,
                .atk: .lowest,
                .hpR: .higher,
                .hp: .medium,
                .defR: .none,
                .def: .none,
            ]
        case .Dehya: return [
                .cr: .highest,
                .cd: .highest,
                .er: .none,
                .em: .high,
                .atkR: .high,
                .atk: .low,
                .hpR: .medium,
                .hp: .lower,
                .defR: .none,
                .def: .none,
            ]
        case .Faruzan: return [
                .cr: .highest,
                .cd: .highest,
                .er: .high,
                .em: .none,
                .atkR: .high,
                .atk: .low,
                .hpR: .none,
                .hp: .none,
                .defR: .none,
                .def: .none,
            ]
        case .Albedo: return [
                .cr: .highest,
                .cd: .highest,
                .er: .none,
                .em: .none,
                .atkR: .lower,
                .atk: .lowest,
                .hpR: .none,
                .hp: .none,
                .defR: .high,
                .def: .low,
            ]
        case .Mona: return [
                .cr: .highest,
                .cd: .highest,
                .er: .medium,
                .em: .high,
                .atkR: .high,
                .atk: .low,
                .hpR: .none,
                .hp: .none,
                .defR: .none,
                .def: .none,
            ]
        case .Sara: return [
                .cr: .highest,
                .cd: .highest,
                .er: .medium,
                .em: .lower,
                .atkR: .medium,
                .atk: .lower,
                .hpR: .none,
                .hp: .none,
                .defR: .none,
                .def: .none,
            ]
        case .Gorou: return [
                .cr: .highest,
                .cd: .highest,
                .er: .highest,
                .em: .none,
                .atkR: .medium,
                .atk: .lower,
                .hpR: .none,
                .hp: .none,
                .defR: .high,
                .def: .medium,
            ]
        case .Yunjin: return [
                .cr: .highest,
                .cd: .highest,
                .er: .highest,
                .em: .none,
                .atkR: .lower,
                .atk: .lowest,
                .hpR: .none,
                .hp: .none,
                .defR: .highest,
                .def: .high,
            ]
        case .Rosaria: return [
                .cr: .highest,
                .cd: .highest,
                .er: .higher,
                .em: .high,
                .atkR: .high,
                .atk: .low,
                .hpR: .none,
                .hp: .none,
                .defR: .none,
                .def: .none,
            ]
        case .Thoma: return [
                .cr: .highest,
                .cd: .highest,
                .er: .higher,
                .em: .higher,
                .atkR: .medium,
                .atk: .lower,
                .hpR: .higher,
                .hp: .medium,
                .defR: .none,
                .def: .none,
            ]
        case .Layla: return [
                .cr: .highest,
                .cd: .highest,
                .er: .none,
                .em: .none,
                .atkR: .medium,
                .atk: .lower,
                .hpR: .highest,
                .hp: .high,
                .defR: .none,
                .def: .none,
            ]
        case .Diona: return [
                .cr: .highest,
                .cd: .highest,
                .er: .higher,
                .em: .none,
                .atkR: .medium,
                .atk: .lower,
                .hpR: .highest,
                .hp: .high,
                .defR: .none,
                .def: .none,
            ]
        case .Candace: return [
                .cr: .highest,
                .cd: .highest,
                .er: .medium,
                .em: .none,
                .atkR: .none,
                .atk: .none,
                .hpR: .higher,
                .hp: .medium,
                .defR: .none,
                .def: .none,
            ]
        case .Beidou: return [
                .cr: .highest,
                .cd: .highest,
                .er: .medium,
                .em: .medium,
                .atkR: .high,
                .atk: .low,
                .hpR: .lower,
                .hp: .lowest,
                .defR: .none,
                .def: .none,
            ]
        case .Mika: return [
                .cr: .highest,
                .cd: .highest,
                .er: .medium,
                .em: .none,
                .atkR: .high,
                .atk: .low,
                .hpR: .high,
                .hp: .low,
                .defR: .none,
                .def: .none,
            ]
        case .Razor: return [
                .cr: .highest,
                .cd: .highest,
                .er: .lower,
                .em: .none,
                .atkR: .high,
                .atk: .low,
                .hpR: .none,
                .hp: .none,
                .defR: .none,
                .def: .none,
            ]
        case .Noelle: return [
                .cr: .highest,
                .cd: .highest,
                .er: .lower,
                .em: .none,
                .atkR: .lower,
                .atk: .lowest,
                .hpR: .none,
                .hp: .none,
                .defR: .high,
                .def: .low,
            ]
        case .Ningguang: return [
                .cr: .highest,
                .cd: .highest,
                .er: .none,
                .em: .none,
                .atkR: .high,
                .atk: .low,
                .hpR: .none,
                .hp: .none,
                .defR: .none,
                .def: .none,
            ]
        case .Sucrose: return [
                .cr: .highest,
                .cd: .highest,
                .er: .lower,
                .em: .highest,
                .atkR: .higher,
                .atk: .medium,
                .hpR: .none,
                .hp: .none,
                .defR: .none,
                .def: .none,
            ]
        case .Yanfei: return [
                .cr: .highest,
                .cd: .highest,
                .er: .none,
                .em: .medium,
                .atkR: .high,
                .atk: .low,
                .hpR: .lower,
                .hp: .lowest,
                .defR: .none,
                .def: .none,
            ]
        case .Heizou: return [
                .cr: .highest,
                .cd: .highest,
                .er: .none,
                .em: .none,
                .atkR: .high,
                .atk: .low,
                .hpR: .none,
                .hp: .none,
                .defR: .none,
                .def: .none,
            ]
        case .Kaeya: return [
                .cr: .highest,
                .cd: .highest,
                .er: .medium,
                .em: .none,
                .atkR: .high,
                .atk: .low,
                .hpR: .none,
                .hp: .none,
                .defR: .none,
                .def: .none,
            ]
        case .Yaoyao: return [
                .cr: .highest,
                .cd: .highest,
                .er: .lower,
                .em: .high,
                .atkR: .high,
                .atk: .low,
                .hpR: .high,
                .hp: .low,
                .defR: .none,
                .def: .none,
            ]
        case .Collei: return [
                .cr: .highest,
                .cd: .highest,
                .er: .medium,
                .em: .high,
                .atkR: .high,
                .atk: .low,
                .hpR: .none,
                .hp: .none,
                .defR: .none,
                .def: .none,
            ]
        case .Sayu: return [
                .cr: .highest,
                .cd: .highest,
                .er: .medium,
                .em: .high,
                .atkR: .high,
                .atk: .low,
                .hpR: .none,
                .hp: .none,
                .defR: .none,
                .def: .none,
            ]
        case .Dori: return [
                .cr: .highest,
                .cd: .highest,
                .er: .medium,
                .em: .low,
                .atkR: .high,
                .atk: .low,
                .hpR: .high,
                .hp: .low,
                .defR: .none,
                .def: .none,
            ]
        case .Chongyun: return [
                .cr: .highest,
                .cd: .highest,
                .er: .low,
                .em: .high,
                .atkR: .high,
                .atk: .low,
                .hpR: .none,
                .hp: .none,
                .defR: .none,
                .def: .none,
            ]
        case .Barbara: return [
                .cr: .highest,
                .cd: .highest,
                .er: .medium,
                .em: .medium,
                .atkR: .high,
                .atk: .low,
                .hpR: .high,
                .hp: .low,
                .defR: .none,
                .def: .none,
            ]
        case .Baizhu: return [
                .cr: .highest,
                .cd: .highest,
                .er: .high,
                .em: .high,
                .atkR: .high,
                .atk: .low,
                .hpR: .highest,
                .hp: .high,
                .defR: .none,
                .def: .none,
            ]
        case .Qiqi: return [
                .cr: .highest,
                .cd: .highest,
                .er: .high,
                .em: .lower,
                .atkR: .high,
                .atk: .low,
                .hpR: .none,
                .hp: .none,
                .defR: .none,
                .def: .none,
            ]
        case .Amber: return [
                .cr: .highest,
                .cd: .highest,
                .er: .medium,
                .em: .high,
                .atkR: .high,
                .atk: .low,
                .hpR: .lower,
                .hp: .low,
                .defR: .none,
                .def: .none,
            ]
        case .Xinyan: return [
                .cr: .highest,
                .cd: .highest,
                .er: .medium,
                .em: .none,
                .atkR: .high,
                .atk: .low,
                .hpR: .none,
                .hp: .none,
                .defR: .high,
                .def: .low,
            ]
        case .Lisa: return [
                .cr: .highest,
                .cd: .highest,
                .er: .high,
                .em: .medium,
                .atkR: .high,
                .atk: .low,
                .hpR: .none,
                .hp: .none,
                .defR: .none,
                .def: .none,
            ]
        case .Aloy: return [
                .cr: .highest,
                .cd: .highest,
                .er: .lower,
                .em: .lower,
                .atkR: .high,
                .atk: .low,
                .hpR: .none,
                .hp: .none,
                .defR: .none,
                .def: .none,
            ]
        case .Sora: return [
                .cr: .highest,
                .cd: .highest,
                .er: .high,
                .em: .medium,
                .atkR: .high,
                .atk: .low,
                .hpR: .none,
                .hp: .none,
                .defR: .none,
                .def: .none,
            ]
        case .Hotaru: return [
                .cr: .highest,
                .cd: .highest,
                .er: .high,
                .em: .medium,
                .atkR: .high,
                .atk: .low,
                .hpR: .none,
                .hp: .none,
                .defR: .none,
                .def: .none,
            ]
        case .Lyney: return [
                .cr: .highest,
                .cd: .highest,
                .er: .lower,
                .em: .lower,
                .atkR: .high,
                .atk: .low,
                .hpR: .none,
                .hp: .none,
                .defR: .high,
                .def: .low,
            ]
        case .Wriothesley: return [
                .cr: .highest,
                .cd: .highest,
                .er: .low,
                .em: .low,
                .atkR: .high,
                .atk: .low,
                .hpR: .none,
                .hp: .none,
                .defR: .none,
                .def: .none,
            ]
        case .Neuvillette: return [
                .cr: .highest,
                .cd: .highest,
                .er: .low,
                .em: .none,
                .atkR: .none,
                .atk: .none,
                .hpR: .highest,
                .hp: .medium,
                .defR: .none,
                .def: .none,
            ]
        case .Furina: return [
                .cr: .highest,
                .cd: .highest,
                .er: .high,
                .em: .none,
                .atkR: .none,
                .atk: .none,
                .hpR: .highest,
                .hp: .medium,
                .defR: .none,
                .def: .none,
            ]
        case .Navia: return [
                .cr: .highest,
                .cd: .highest,
                .er: .low,
                .em: .none,
                .atkR: .high,
                .atk: .low,
                .hpR: .none,
                .hp: .none,
                .defR: .none,
                .def: .none,
            ]
        // 此处为止的内容是截至 2024 年 2 月时的爱丽丝工房原始脚本内容。
        // 派蒙不是可控角色（而是类似于 null value 的存在），所以所有圣遗物都给 none。
        case .Paimon: return [
                .cr: .none,
                .cd: .none,
                .er: .none,
                .em: .none,
                .atkR: .none,
                .atk: .none,
                .hpR: .none,
                .hp: .none,
                .defR: .none,
                .def: .none,
            ]
        case .Kaveh:
            // By ShikiSuen, referring Bilibili Wiki.
            return [
                .cr: .medium,
                .cd: .medium,
                .er: .high,
                .em: .highest,
                .atkR: .medium,
                .atk: .medium,
                .hpR: .none,
                .hp: .none,
                .defR: .none,
                .def: .none,
            ]
        case .Kirara:
            // By ShikiSuen, referring Bilibili Wiki.
            return [
                .cr: .medium, // 西风剑加成
                .cd: .none,
                .er: .high,
                .em: .none,
                .atkR: .none,
                .atk: .none,
                .hpR: .highest,
                .hp: .higher,
                .defR: .none,
                .def: .none,
            ]
        case .Lynette:
            // By ShikiSuen, referring Bilibili Wiki.
            return [
                .cr: .highest,
                .cd: .highest,
                .er: .highest,
                .em: .high,
                .atkR: .higher,
                .atk: .high,
                .hpR: .none,
                .hp: .none,
                .defR: .none,
                .def: .none,
            ]
        case .Freminet:
            // By ShikiSuen, referring Bilibili Wiki.
            return [
                .cr: .highest,
                .cd: .highest,
                .er: .none,
                .em: .none,
                .atkR: .higher,
                .atk: .high,
                .hpR: .none,
                .hp: .none,
                .defR: .none,
                .def: .none,
            ]
        case .Charlotte:
            // By ShikiSuen, referring Bilibili Wiki.
            return [
                .cr: .higher,
                .cd: .none,
                .er: .highest,
                .em: .none,
                .atkR: .highest,
                .atk: .highest,
                .hpR: .none,
                .hp: .none,
                .defR: .none,
                .def: .none,
            ]
        case .Chevreuse:
            // By ShikiSuen, referring Bilibili Wiki.
            return [
                .cr: .higher,
                .cd: .none,
                .er: .higher,
                .em: .none,
                .atkR: .none,
                .atk: .none,
                .hpR: .highest,
                .hp: .highest,
                .defR: .none,
                .def: .none,
            ]
        case .Gaming:
            // By ShikiSuen, referring Bilibili Wiki.
            return [
                .cr: .highest,
                .cd: .highest,
                .er: .medium,
                .em: .highest,
                .atkR: .highest,
                .atk: .higher,
                .hpR: .none,
                .hp: .none,
                .defR: .none,
                .def: .none,
            ]
        case .Xianyun:
            // By ShikiSuen, referring Bilibili Wiki.
            return [
                .cr: .higher,
                .cd: .medium,
                .er: .highest,
                .em: .none,
                .atkR: .highest,
                .atk: .high,
                .hpR: .none,
                .hp: .none,
                .defR: .none,
                .def: .none,
            ]
        case .Chiori:
            // By Kamihimmel:
            return [
                .cr: .highest,
                .cd: .highest,
                .er: .low,
                .em: .none,
                .atkR: .medium,
                .atk: .low,
                .hpR: .none,
                .hp: .none,
                .defR: .highest,
                .def: .medium,
            ]
        }
    }
}
