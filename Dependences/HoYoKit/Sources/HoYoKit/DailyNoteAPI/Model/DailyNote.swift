//
//  File.swift
//
//
//  Created by 戴藏龙 on 2023/11/29.
//

import Foundation

// MARK: - DailyNote

public protocol DailyNote {
    associatedtype DailyTaskInformation: HoYoKit.DailyTaskInformation
    var dailyTaskInformation: DailyTaskInformation { get }
    associatedtype ExpeditionInformation: HoYoKit.ExpeditionInformation
    var expeditionInformation: ExpeditionInformation { get }
    associatedtype HomeCoinInformation: HoYoKit.HomeCoinInformation
    var homeCoinInformation: HomeCoinInformation { get }
    associatedtype ResinInformation: HoYoKit.ResinInformation
    var resinInformation: ResinInformation { get }
}

// MARK: - DailyTaskInformation

public protocol DailyTaskInformation {
    var totalTaskCount: Int { get }
    var finishedTaskCount: Int { get }
    var isExtraRewardReceived: Bool { get }
}

// MARK: - ExpeditionInformation

public protocol ExpeditionInformation {
    var maxExpeditionsCount: Int { get }
    associatedtype Expedition: HoYoKit.Expedition
    var expeditions: [Expedition] { get }
}

extension ExpeditionInformation {
    public var ongoingExpeditionCount: Int {
        expeditions.filter { !$0.isFinished }.count
    }

    public var allCompleted: Bool {
        expeditions.filter { !$0.isFinished }.count == 0
    }
}

// MARK: - Expedition

public protocol Expedition {
    var isFinished: Bool { get }
    var iconURL: URL { get }
}

// MARK: - HomeCoinInformation

public protocol HomeCoinInformation {
    var maxHomeCoin: Int { get }
    var currentHomeCoin: Int { get }
    var fullTime: Date { get }
}

// MARK: - ResinInformation

public protocol ResinInformation {
    var maxResin: Int { get }
    var currentResin: Int { get }
    var resinRecoveryTime: Date { get }
}
