//
//  PSAServerAPI.swift
//  GenshinPizzaHelper
//
//  Created by Bill Haku on 2022/10/26.
//

import Foundation

extension API {
    struct PSAServer {
        /// 上传数据
        static func uploadUserData(
            path: String,
            ds: String,
            dseed: String,
            data: Data,
            _ completion: @escaping (PSAServerPostResultModel) -> ()
        ) {

        }

        /// 深渊角色使用率
        static func fetchAbyssUtilizationData(
            season: Int = { () -> Int in
                let component = Calendar.current.dateComponents([.day, .month, .year], from: Date())
                if component.day! >= 16 {
                    return Int(String(component.year!)+String(component.month!)+"0")!
                } else {
                    return Int(String(component.year!)+String(component.month!)+"1")!
                }
            }(),
            server: Server? = nil,
            floor: Int = 12,
            _ completion: @escaping (UltilizationDataFetchModelResult) -> ()
        ) {

        }

        /// 满星玩家持有率
        static func fetchFullStarHoldingRateData(
            season: Int = { () -> Int in
                let component = Calendar.current.dateComponents([.day, .month, .year], from: Date())
                if component.day! >= 16 {
                    return Int(String(component.year!)+String(component.month!)+"0")!
                } else {
                    return Int(String(component.year!)+String(component.month!)+"1")!
                }
            }(),
            server: Server? = nil,
            _ completion: @escaping (AvatarHoldingReceiveDataFetchModelResult) -> ()
        ) {

        }

        /// 所有玩家持有率
        static func fetchHoldingRateData(
            queryStartDate: Date
            ,
            server: Server? = nil,
            _ completion: @escaping (AvatarHoldingReceiveDataFetchModelResult) -> ()
        ) {

        }

        /// 后台服务器版本
        static func fetchHomeServerVersion(
            _ completion: @escaping (HomeServerVersionFetchModelResult) -> ()
        ) {

        }

    }
}
