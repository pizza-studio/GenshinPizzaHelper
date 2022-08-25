//
//  StringLocalized.swift
//  GenshinPizzaHelper
//
//  Created by 戴藏龙 on 2022/8/25.
//

import Foundation

extension String {
    var localized: String {
        return String(format: NSLocalizedString(self, comment: "namecards"))
    }
}
