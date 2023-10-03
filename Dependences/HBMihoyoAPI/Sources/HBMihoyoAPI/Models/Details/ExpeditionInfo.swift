//
//  ExpeditionDetail.swift
//  GenshinPizzaHepler
//
//  Created by 戴藏龙 on 2022/8/7.
//  探索派遣信息

import Foundation

// MARK: - ExpeditionInfo

public struct ExpeditionInfo: Codable {
    public let currentExpedition: Int
    public let maxExpedition: Int

    public let expeditions: [Expedition]

    public var currentOngoingTask: Int {
        expeditions.isEmpty
            ? currentExpedition
            : expeditions.filter { expedition in
                expedition.isComplete == false
            }
            .count
    }

    public var anyCompleted: Bool {
        expeditions.isEmpty ? false : currentOngoingTask < maxExpedition
    }

    public var nextCompleteExpedition: Expedition? {
        expeditions.min {
            $0.recoveryTime.second < $1.recoveryTime.second
        }
    }

    public var nextCompleteTime: RecoveryTime {
        RecoveryTime(second: nextCompleteExpedition?.recoveryTime.second ?? 0)
    }

    public var nextCompletePercentage: Double {
        nextCompleteExpedition?.percentage ?? 0
    }

    public var allCompleted: Bool {
        expeditions.isEmpty ? false : currentOngoingTask == 0
    }

    public var allCompleteTime: RecoveryTime {
        RecoveryTime(second: expeditions.max {
            $0.recoveryTime.second < $1.recoveryTime.second
        }?.recoveryTime.second ?? 0)
    }

    public var maxTotalTime: Double {
        expeditions.map { $0.totalTime }
            .max {
                $0 < $1
            } ?? 72000.0
    }

    public var allCompletedPercentage: Double {
        (maxTotalTime - Double(allCompleteTime.second)) / maxTotalTime
    }

    public var nextCompleteExpeditionIgnoreFinished: Expedition? {
        expeditions.filter { expedition in
            !expedition.isComplete
        }.min {
            $0.recoveryTime.second < $1.recoveryTime.second
        }
    }

    public var nextCompleteTimeIgnoreFinished: RecoveryTime {
        RecoveryTime(second: nextCompleteExpedition?.recoveryTime.second ?? 0)
    }

    public var nextCompletePercentageIgnoreFinished: Double {
        nextCompleteExpedition?.percentage ?? 0
    }

    public var score: Float {
        if allCompleted { return 120.0 / 160.0 } else if anyCompleted { return 40.0 / 160.0 } else { return 0 }
    }
}

// MARK: - Expedition

public struct Expedition: Codable {
    public enum CodingKeys: String, CodingKey {
        case avatarSideIcon
        case remainedTimeStr = "remainedTime"
        case statusStr = "status"
    }

    public let avatarSideIcon: String
    public let remainedTimeStr: String
    public let statusStr: String

    public let totalTime: Double = .init(20 * 60 * 60)

    public var percentage: Double {
        (totalTime - Double(recoveryTime.second)) / totalTime
    }

    public var charactersEnglishName: String {
        let components = avatarSideIcon.components(separatedBy: "_")
        let fileName = components.last ?? ""
        return (fileName as NSString).deletingPathExtension
    }

    public var avatarSideIconUrl: URL { URL(string: avatarSideIcon)! }
    public var recoveryTime: RecoveryTime {
        RecoveryTime(second: Int(remainedTimeStr)!)
    }

    public var isComplete: Bool {
        recoveryTime.isComplete
    }

    public var characterName: String {
        // TODO: 从瑶瑶开始就没整修过，需要熟悉这个模组的人整修之。
        let strResult: String = {
            switch charactersEnglishName {
            case "Gunnhildr":
                return "Jean"
            case "Ambor":
                return "Amber"
            case "Alberich":
                return "Kaeya"
            case "Minci":
                return "Lisa"
            case "Noel":
                return "Noelle"
            case "Astrologist", "Megistus":
                return "Mona"
            case "Hu", "Hutao", "HuTao", "Tao":
                return "Hutao"
            case "Jin", "Yun", "Yunjin", "YunJin":
                return "Yunjin"
            case "Kaedehara":
                return "Kazuha"
            case "Kamisato", "KamisatoAyaka":
                return "Ayaka"
            case "KamisatoAyato":
                return "Ayato"
            case "Tohma":
                return "Thoma"
            case "Yae":
                return "Miko"
            case "Arataki":
                return "Itto"
            case "Sangonomiya":
                return "Kokomi"
            case "Shikanoin":
                return "Heizou"
            case "Raiden", "Shogun":
                return "Ei"
            case "Ajax", "Childe":
                return "Tartaglia"
            case "Wanderer":
                return "Kunikuzushi"
            case "Alhatham":
                return "Alhaitham"
            default:
                return ""
            }

        }()
        guard !strResult.isEmpty else {
            return NSLocalizedString("expedition.info.unknownCharacter.braced", comment: "")
        }
        return NSLocalizedString("$asset.character:" + strResult, comment: "")
    }
}
