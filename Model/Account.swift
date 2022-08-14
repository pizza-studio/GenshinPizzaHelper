//
//  Account.swift
//  GenshinPizzaHepler
//
//  Created by 戴藏龙 on 2022/8/9.
//

import Foundation

struct Account {
    var config: AccountConfiguration
    var result: FetchResult
    
    init(config: AccountConfiguration) {
        self.config = config
        self.result = .failure(.defaultStatus)
    }
    
    init(config: AccountConfiguration, result: FetchResult) {
        self.config = config
        self.result = result
    }
    
    
    
}

extension AccountConfiguration {
    func fetchResult(_ completion: @escaping (FetchResult) -> ()) {
        guard (uid != nil) || (cookie != nil) else { return }
        
        API.Features.fetchInfos(region: self.server.region,
                                serverID: self.server.id,
                                uid: self.uid!,
                                cookie: self.cookie!)
        { completion($0) }
    }
}

