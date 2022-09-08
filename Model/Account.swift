//
//  Account.swift
//  GenshinPizzaHepler
//
//  Created by 戴藏龙 on 2022/8/9.
//  Account所需的所有信息

import Foundation

struct Account: Equatable {
    static func == (lhs: Account, rhs: Account) -> Bool {
        return lhs.config == rhs.config
    }

    var config: AccountConfiguration
    var result: FetchResult
    var background: WidgetBackground = WidgetBackground.randomNamecardBackground

    var fetchComplete: Bool

    init(config: AccountConfiguration) {
        self.config = config
        self.result = .failure(.defaultStatus)
        self.fetchComplete = false
    }
    
    init(config: AccountConfiguration, result: FetchResult) {
        self.config = config
        self.result = result
        self.fetchComplete = true
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
