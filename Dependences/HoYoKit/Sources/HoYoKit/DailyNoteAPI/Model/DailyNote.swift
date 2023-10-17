//
//  File.swift
//
//
//  Created by 戴藏龙 on 2023/10/16.
//

import Foundation

// MARK: - DailyNote

public struct DailyNote: Decodable {
    // MARK: Lifecycle

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        self.dailyTaskInformation = try container.decode(DailyTaskInformation.self)
        self.resinInformation = try container.decode(ResinInformation.self)
        self.weeklyBossesInformation = try container.decode(WeeklyBossesInformation.self)
        self.expeditionInformation = try container.decode(ExpeditionInformation.self)
        self.transformerInformation = try container.decode(TransformerInformation.self)
    }

    // MARK: Internal

    let dailyTaskInformation: DailyTaskInformation
    let resinInformation: ResinInformation
    let weeklyBossesInformation: WeeklyBossesInformation
    let expeditionInformation: ExpeditionInformation
    let transformerInformation: TransformerInformation
}

// MARK: - TransformerInformation

public struct TransformerInformation: Decodable {
    // MARK: Lifecycle

    public init(from decoder: Decoder) throws {
        let basicContainer = try decoder.container(keyedBy: BasicCodingKeys.self)
        let container = try basicContainer.nestedContainer(keyedBy: CodingKeys.self, forKey: .transformer)
        self.obtained = try container.decode(Bool.self, forKey: .obtained)

        let recoveryTimeContainer = try container.nestedContainer(
            keyedBy: RecoveryTimeCodingKeys.self,
            forKey: .recoveryTime
        )
        let reached = try recoveryTimeContainer.decode(Bool.self, forKey: .reached)
        if reached {
            self.recoveryTime = .now
        } else {
            let day = try recoveryTimeContainer.decode(Int.self, forKey: .day)
            let minute = try recoveryTimeContainer.decode(Int.self, forKey: .minute)
            let hour = try recoveryTimeContainer.decode(Int.self, forKey: .hour)
            let second = try recoveryTimeContainer.decode(Int.self, forKey: .second)
            let timeInterval = TimeInterval() + Double(day * 24 * 60 * 60) + Double(minute * 60) +
                Double(hour * 60 * 60) + Double(second)
            self.recoveryTime = Date(timeIntervalSinceNow: timeInterval)
        }
    }

    // MARK: Public

    public let obtained: Bool
    public let recoveryTime: Date

    // MARK: Private

    private enum BasicCodingKeys: String, CodingKey {
        case transformer
    }

    private enum CodingKeys: String, CodingKey {
        case obtained
        case recoveryTime = "recovery_time"
    }

    private enum RecoveryTimeCodingKeys: String, CodingKey {
        case day = "Day"
        case minute = "Minute"
        case second = "Second"
        case hour = "Hour"
        case reached
    }
}

// MARK: - ExpeditionInformation

public struct ExpeditionInformation: Decodable {
    // MARK: Public

    public struct Expedition: Decodable {
        // MARK: Lifecycle

        public init(from decoder: Decoder) throws {
            let container: KeyedDecodingContainer<ExpeditionInformation.Expedition.CodingKeys> = try decoder
                .container(keyedBy: ExpeditionInformation.Expedition.CodingKeys.self)
            if let timeIntervalUntilFinish = TimeInterval(try container.decode(
                String.self,
                forKey: ExpeditionInformation.Expedition.CodingKeys.finishTime
            )) {
                self.finishTime = Date(timeIntervalSinceNow: timeIntervalUntilFinish)
            } else {
                throw DecodingError.typeMismatch(
                    Double.self,
                    .init(
                        codingPath: decoder.codingPath,
                        debugDescription: "Unable to parse time interval until finished expedition"
                    )
                )
            }
            self.iconURL = try container.decode(URL.self, forKey: ExpeditionInformation.Expedition.CodingKeys.iconURL)
        }

        // MARK: Public

        public let finishTime: Date
        public let iconURL: URL

        // MARK: Private

        private enum CodingKeys: String, CodingKey {
            case finishTime = "remained_time"
            case iconURL = "avatar_side_icon"
        }
    }

    public let maxExpeditionsCount: Int
    public let expeditions: [Expedition]

    // MARK: Private

    private enum CodingKeys: String, CodingKey {
        case maxExpeditionsCount = "max_expedition_num"
        case expeditions
    }
}

// MARK: - WeeklyBossesInformation

public struct WeeklyBossesInformation: Decodable {
    // MARK: Public

    public let totalResinDiscount: Int
    public let remainResinDiscount: Int

    // MARK: Private

    private enum CodingKeys: String, CodingKey {
        case totalResinDiscount = "resin_discount_num_limit"
        case remainResinDiscount = "remain_resin_discount_num"
    }
}

// MARK: - ResinInformation

public struct ResinInformation: Decodable {
    // MARK: Lifecycle

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.maxResin = try container.decode(Int.self, forKey: .maxResin)
        self.currentResin = try container.decode(Int.self, forKey: .currentResin)
        if let resinRecoveryTimeInterval = TimeInterval(try container.decode(String.self, forKey: .resinRecoveryTime)) {
            self.resinRecoveryTime = Date(timeInterval: resinRecoveryTimeInterval, since: .now)
        } else {
            throw DecodingError.typeMismatch(
                Double.self,
                .init(
                    codingPath: decoder.codingPath,
                    debugDescription: "Unable to parse time interval of resin recovery time"
                )
            )
        }
    }

    // MARK: Public

    public let maxResin: Int
    public let currentResin: Int
    public let resinRecoveryTime: Date

    // MARK: Private

    private enum CodingKeys: String, CodingKey {
        case maxResin = "max_resin"
        case currentResin = "current_resin"
        case resinRecoveryTime = "resin_recovery_time"
    }
}

// MARK: - DailyTaskInformation

public struct DailyTaskInformation: Decodable {
    // MARK: Lifecycle

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        self.totalTaskCount = try container.decode(Int.self, forKey: .totalTaskCount)

        let dailyTaskContainer = try container.nestedContainer(keyedBy: DailyTaskCodingKeys.self, forKey: .dailyTask)

        self.finishedTaskCount = try dailyTaskContainer.decode(Int.self, forKey: .finishedNumber)
        self.isExtraRewardReceived = try dailyTaskContainer.decode(Bool.self, forKey: .isExtraRewardReceived)

        var taskRewardsContainer = try dailyTaskContainer.nestedUnkeyedContainer(forKey: .taskRewards)
        var taskRewards = [TaskReward]()
        while !taskRewardsContainer.isAtEnd {
            let taskRewardContainer = try taskRewardsContainer.nestedContainer(keyedBy: TaskRewardCodingKeys.self)
            taskRewards.append(try taskRewardContainer.decode(TaskReward.self, forKey: .status))
        }
        self.taskRewards = taskRewards

        var attendanceRewardsContainer = try dailyTaskContainer.nestedUnkeyedContainer(forKey: .attendanceRewards)
        var attendanceRewards = [Double]()
        while !attendanceRewardsContainer.isAtEnd {
            let attendanceRewardContainer = try attendanceRewardsContainer
                .nestedContainer(keyedBy: AttendanceRewardCodingKeys.self)
            attendanceRewards.append(Double(try attendanceRewardContainer.decode(Int.self, forKey: .progress)) / 2000.0)
        }
        self.attendanceRewards = attendanceRewards
    }

    // MARK: Public

    /// 每个每日任务状态
    public enum TaskReward: String, Decodable {
        // TODO: add more case
        case unfinished = "TaskRewardStatusUnfinished"
    }

    public let totalTaskCount: Int
    public let finishedTaskCount: Int
    public let isExtraRewardReceived: Bool

    /// 历练点进度百分比
    public let attendanceRewards: [Double]

    /// 每个每日任务状态
    public let taskRewards: [TaskReward]

    // MARK: Private

    private enum CodingKeys: String, CodingKey {
        case totalTaskCount = "total_task_num"
        case dailyTask = "daily_task"
    }

    private enum DailyTaskCodingKeys: String, CodingKey {
        case finishedNumber = "finished_num"
        case attendanceRewards = "attendance_rewards"
        case taskRewards = "task_rewards"
        case isExtraRewardReceived = "is_extra_task_reward_received"
    }

    private enum AttendanceRewardCodingKeys: String, CodingKey {
        case status
        case progress
    }

    private enum TaskRewardCodingKeys: String, CodingKey {
        case status
    }
}

// MARK: - DailyNote + DecodableFromMiHoYoAPIJSONResult

extension DailyNote: DecodableFromMiHoYoAPIJSONResult {}
