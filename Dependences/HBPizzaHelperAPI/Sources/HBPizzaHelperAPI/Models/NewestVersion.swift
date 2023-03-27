//
//  NewestVersion.swift
//  
//
//  Created by Bill Haku on 2023/3/27.
//

import Foundation

struct NewestVersion: Codable {
    struct MultiLanguageContents: Codable {
        var en: [String]
        var zhcn: [String]
        var ja: [String]
        var fr: [String]
        var zhtw: [String]?
        var ru: [String]?
    }

    struct VersionHistory: Codable {
        struct MultiLanguageContents: Codable {
            var en: [String]
            var zhcn: [String]
            var ja: [String]
            var fr: [String]
            var zhtw: [String]?
            var ru: [String]?
        }

        var shortVersion: String
        var buildVersion: Int
        var updates: MultiLanguageContents
    }

    var shortVersion: String
    var buildVersion: Int
    var updates: MultiLanguageContents
    var notice: MultiLanguageContents
    var updateHistory: [VersionHistory]
}
