//
//  RequestResult.swift
//  原神披萨小助手
//
//  Created by Bill Haku on 2022/8/6.
//  正常请求返回信息

import Foundation
import SwiftUI

// MARK: - RequestResult

struct RequestResult: Codable {
    let data: FetchData?
    let message: String
    let retcode: Int
}

// MARK: - WidgetRequestResult

struct WidgetRequestResult: Codable {
    let data: WidgetUserData?
    let message: String
    let retcode: Int
}

// MARK: - BasicInfoRequestResult

struct BasicInfoRequestResult: Codable {
    let data: BasicInfos?
    let message: String
    let retcode: Int
}

// MARK: - LedgerDataRequestResult

struct LedgerDataRequestResult: Codable {
    let data: LedgerData?
    let message: String
    let retcode: Int
}

// MARK: - AllAvatarDetailRequestDetail

struct AllAvatarDetailRequestDetail: Codable {
    let data: AllAvatarDetailModel?
    let message: String
    let retcode: Int
}

#if !os(watchOS)
    struct SpiralAbyssDetailRequestResult: Codable {
        let data: SpiralAbyssDetail?
        let message: String
        let retcode: Int
    }
#endif
