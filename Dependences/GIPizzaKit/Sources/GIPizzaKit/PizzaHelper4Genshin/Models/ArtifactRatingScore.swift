//
//  ArtifactRatingScore.swift
//
//
//  Created by Bill Haku on 2023/3/30.
//

import Foundation

// MARK: - ArtifactRatingScoreResult

public struct ArtifactRatingScoreResult: Codable, Equatable {
    var charactername: String
    public var stat1pt: Double
    public var stat2pt: Double
    public var stat3pt: Double
    public var stat4pt: Double
    public var stat5pt: Double
    public var allpt: Double
    public var result: String

    public var isValid: Bool {
        guard allpt == stat1pt + stat2pt + stat3pt + stat4pt + stat5pt
        else { return false }
        guard stat1pt >= 0 else { return false }
        guard stat2pt >= 0 else { return false }
        guard stat3pt >= 0 else { return false }
        guard stat4pt >= 0 else { return false }
        guard stat5pt >= 0 else { return false }
        return true
    }

    public func convert2ArtifactScoreCollectModel(
        uid: String,
        charId: String
    )
        -> ArtifactScoreCollectModel {
        ArtifactScoreCollectModel(
            uid: uid,
            charId: charId,
            totalScore: allpt,
            stat1Score: stat1pt,
            stat2Score: stat2pt,
            stat3Score: stat3pt,
            stat4Score: stat4pt,
            stat5Score: stat5pt
        )
    }
}

// MARK: - ArtifactRatingRequest

public struct ArtifactRatingRequest {
    // MARK: Lifecycle

    public init(
        cid: Int,
        characterElement: Int,
        flower: Artifact,
        plume: Artifact,
        sands: Artifact,
        goblet: Artifact,
        circlet: Artifact
    ) {
        self.cid = cid
        self.characterElement = characterElement
        self.flower = flower
        self.plume = plume
        self.sands = sands
        self.goblet = goblet
        self.circlet = circlet
    }

    // MARK: Public

    public struct Artifact {
        // MARK: Lifecycle

        public init() {}

        // MARK: Public

        public var mainProp3: Artifact3MainProp?
        public var mainProp4: Artifact4MainProp?
        public var mainProp5: Artifact5MainProp?
        public var star: Int = 5
        public var lv: Int = 20
        public var setId: Int = -114_514
        public var atkPercent: Double = 0
        public var hpPercent: Double = 0
        public var defPercent: Double = 0
        public var em: Double = 0
        public var erPercent: Double = 0
        public var crPercent: Double = 0
        public var cdPercent: Double = 0
        public var atk: Double = 0
        public var hp: Double = 0
        public var def: Double = 0

        public var isNull: Bool {
            setId == -114_514
        }

        public var isValid: Bool {
            !isNull
        }
    }

    public enum Artifact3MainProp: Int {
        case hpPercentage = 1
        case atkPercentage = 2
        case defPercentage = 3
        case em = 4
        case er = 5

        // MARK: Internal

        var translated: ArtifactRatingSputnik.Param {
            switch self {
            case .hpPercentage: return .hpR
            case .atkPercentage: return .atkR
            case .defPercentage: return .defR
            case .em: return .em
            case .er: return .er
            }
        }
    }

    public enum Artifact4MainProp: Int {
        case hpPercentage = 1
        case atkPercentage = 2
        case defPercentage = 3
        case em = 4
        case physicoDmg = 5
        case pyroDmg = 6
        case hydroDmg = 7
        case cryoDmg = 8
        case electroDmg = 9
        case anemoDmg = 10
        case geoDmg = 11
        case dendroDmg = 12

        // MARK: Internal

        var translated: ArtifactRatingSputnik.Param {
            switch self {
            case .hpPercentage: return .hpR
            case .atkPercentage: return .atkR
            case .defPercentage: return .defR
            case .em: return .em
            case .physicoDmg: return .emd(.physico)
            case .pyroDmg: return .emd(.pyro)
            case .hydroDmg: return .emd(.hydro)
            case .cryoDmg: return .emd(.cryo)
            case .electroDmg: return .emd(.electro)
            case .anemoDmg: return .emd(.anemo)
            case .geoDmg: return .emd(.geo)
            case .dendroDmg: return .emd(.dendro)
            }
        }
    }

    public enum Artifact5MainProp: Int {
        case hpPercentage = 1
        case atkPercentage = 2
        case defPercentage = 3
        case em = 4
        case critRate = 5
        case critDmg = 6
        case healingBonus = 7

        // MARK: Internal

        var translated: ArtifactRatingSputnik.Param {
            switch self {
            case .hpPercentage: return .hpR
            case .atkPercentage: return .atkR
            case .defPercentage: return .defR
            case .em: return .em
            case .critRate: return .cr
            case .critDmg: return .cd
            case .healingBonus: return .heal
            }
        }
    }

    /// 角色ID
    public var cid: Int
    /// 角色元素能力属性，依照原神提瓦特大陆游历顺序起算。物理属性为 0、风属性为 1、岩 2、雷 3，依次类推。
    public var characterElement: Int = 0
    /// 花
    public var flower: Artifact
    /// 羽毛
    public var plume: Artifact
    /// 沙漏
    public var sands: Artifact
    /// 杯子
    public var goblet: Artifact
    /// 头
    public var circlet: Artifact

    public var allArtifacts: [Artifact] {
        [flower, plume, sands, goblet, circlet]
    }

    public var allValidArtifacts: [Artifact] {
        allArtifacts.filter(\.isValid)
    }
}

// MARK: - ArtifactScoreCollectModel

public struct ArtifactScoreCollectModel: Codable {
    public var uid: String
    public var charId: String
    public var totalScore: Double
    public var stat1Score: Double
    public var stat2Score: Double
    public var stat3Score: Double
    public var stat4Score: Double
    public var stat5Score: Double
}
