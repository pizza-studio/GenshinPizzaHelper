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
    
    @Published var result: FetchResult = .failure(.defaultStatus)
    
    static let shared = ViewModel()

    func get_data(uid: String, server_id: String, cookie: String, region: Region) {
        API.Features.fetchInfos(region: region,
                                serverID: server_id,
                                uid: uid,
                                cookie: cookie)
        { self.result = $0 }
    }
    

}
