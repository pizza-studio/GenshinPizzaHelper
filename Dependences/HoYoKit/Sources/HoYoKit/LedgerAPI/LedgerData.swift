//
//  LedgerData.swift
//
//
//  Created by Bill Haku on 2023/3/26.
//

import Foundation

// MARK: - LedgerData

public struct LedgerData: Codable {
    // MARK: Public

    public struct MonthData: Codable {
        // MARK: Public

        public struct LedgerDataGroup: Codable {
            // MARK: Public

            public var percent: Int
            public var num: Int
            public var actionId: Int
            public var action: String

            // MARK: Internal

            enum CodingKeys: String, CodingKey {
                case percent
                case num
                case actionId = "action_id"
                case action
            }
        }

        public var currentPrimogems: Int
        /// 国际服没有
        public var currentPrimogemsLevel: Int?
        public var lastMora: Int
        /// 国服使用
        public var primogemsRate: Int?
        /// 国际服使用
        public var primogemRate: Int?
        public var moraRate: Int
        public var groupBy: [LedgerDataGroup]
        public var lastPrimogems: Int
        public var currentMora: Int

        // MARK: Internal

        enum CodingKeys: String, CodingKey {
            case currentPrimogems = "current_primogems"
            case currentPrimogemsLevel = "current_primogems_level"
            case lastMora = "last_mora"
            case primogemsRate = "primogems_rate"
            case primogemRate = "primogem_rate"
            case moraRate = "mora_rate"
            case groupBy = "group_by"
            case lastPrimogems = "last_primogems"
            case currentMora = "current_mora"
        }
    }

    public struct DayData: Codable {
        // MARK: Public

        public var currentMora: Int
        /// 国际服没有
        public var lastPrimogems: Int?
        /// 国际服没有
        public var lastMora: Int?
        public var currentPrimogems: Int

        // MARK: Internal

        enum CodingKeys: String, CodingKey {
            case currentMora = "current_mora"
            case lastPrimogems = "last_primogems"
            case lastMora = "last_mora"
            case currentPrimogems = "current_primogems"
        }
    }

    public var uid: Int
    public var monthData: MonthData
    public var dataMonth: Int
    /// 国际服没有
    public var date: String?
    /// 国际服没有
    public var dataLastMonth: Int?
    public var region: String
    public var optionalMonth: [Int]
    public var month: Int
    public var nickname: String
    /// 国际服没有
    public var accountId: Int?
    /// 国际服没有
    public var lantern: Bool?
    public var dayData: DayData

    // MARK: Internal

    enum CodingKeys: String, CodingKey {
        case uid
        case monthData = "month_data"
        case dataMonth = "data_month"
        case date
        case dataLastMonth = "data_last_month"
        case region
        case optionalMonth = "optional_month"
        case month
        case nickname
        case accountId = "account_id"
        case lantern
        case dayData = "day_data"
    }
}

// MARK: DecodableFromMiHoYoAPIJSONResult

extension LedgerData: DecodableFromMiHoYoAPIJSONResult {}
