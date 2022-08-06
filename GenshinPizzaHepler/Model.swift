//
//  Model.swift
//  Genshin Resin Checker
//
//  Created by 戴藏龙 on 2022/7/12.
//

import Foundation
import SwiftUI

class ViewModel: ObservableObject {
    // TODO: 增加错误信息说明
    typealias QueryResult = (isValid: Bool, retcode: Int, data: UserData?)
    
    @Published var result: QueryResult = (false, 1, nil)

    func get_data(uid: String, server_id: String, cookie: String) -> (isValid: Bool, retcode: Int, data: UserData?) {
        API.Features.fetchInfos(region: .cn,
                                serverID: server_id,
                                uid: uid,
                                cookie: cookie)
        { retCode, userLoginData, errorInfo in
            if retCode != 0 {
                self.result = (false, retCode, nil)
            } else {
                self.result = (true, retCode, userLoginData!.data!)
            }
        }
        return result
    }
}
