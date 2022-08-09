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
