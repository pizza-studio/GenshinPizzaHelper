//
//  LedgerData.swift
//  GenshinPizzaHelper
//
//  Created by Bill Haku on 2022/10/9.
//

import Foundation

struct LedgerData: Codable {
    var uid: Int
    var monthData: MonthData
    var dataMonth: Int
    var date: String
    var dataLastMonth: Int
    var region: String
    var optionalMonth: [Int]
    var month: Int
    var nickname: String
    var accountId: Int
    var lantern: Bool
    var dayData: DayData

    struct MonthData: Codable {
        var currentPrimogems: Int
        var currentPrimogemsLevel: Int
        var lastMora: Int
        var primogemsRate: Int
        var moraRate: Int
        var groupBy: [LedgerDataGroup]
        var lastPrimogems: Int
        var currentMora: Int

        struct LedgerDataGroup: Codable {
            var percent: Int
            var num: Int
            var actionId: Int
            var action: String
        }
    }

    struct DayData: Codable {
        var currentMora: Int
        var lastPrimogems: Int
        var lastMora: Int
        var currentPrimogems: Int
    }
}
