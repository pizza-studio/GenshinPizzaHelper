//
//  Model.swift
//  Genshin Resin Checker
//
//  Created by 戴藏龙 on 2022/7/12.
//

import Foundation
import SwiftUI
import WidgetKit

struct ResinEntry: TimelineEntry {
    let date: Date
    var queryResult: (isValid: Bool, retcode: Int, data: UserData?)
    var userData: UserData? {
        queryResult.data
    }
}

struct ResinLoader {
    typealias QueryResult = (isValid: Bool, retcode: Int, data: UserData?)
    
    static func fetch(uid: String, server_id: String, cookie: String, completion: @escaping ((QueryResult) -> Void)) {
        var result: QueryResult = (false, 1, nil)

        API.Features.fetchInfos(region: .cn,
                                serverID: server_id,
                                uid: uid,
                                cookie: cookie) { retCode, userLoginData, errorInfo in
            if retCode < 0 {
                result = (false, -1, nil)
            } else if retCode > 0 {
                result = (false, retCode, nil)
            } else {
                result = (true, retCode, userLoginData!.data!)
            }
            completion(result)
        }
    }
    
    static func get_data(from requestResult: RequestResult?) -> (isValid: Bool, retcode: Int, data: UserData?) {
        var result: (isValid: Bool, retcode: Int, data: UserData?) = (false, 1, nil)
            
        if requestResult == nil {
            result = (false, 1, nil)
        } else if requestResult!.retcode != 0 {
            result = (false, requestResult!.retcode, nil)
        } else {
            result = (true, requestResult!.retcode, requestResult!.data!)
        }
        
        return result
    }
}
