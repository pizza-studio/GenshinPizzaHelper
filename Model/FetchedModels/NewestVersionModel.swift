//
//  NewestVersionModel.swift
//  GenshinPizzaHelper
//
//  Created by Bill Haku on 2022/9/26.
//

import Foundation

struct NewestVersion: Codable {
    var shortVersion: String
    var buildVersion: Int
    var updates: MultiLanguageContents
    var notice: MultiLanguageContents

    struct MultiLanguageContents: Codable {
        var en: [String]
        var zhcn: [String]
        var ja: [String]
        var fr: [String]
    }
}
