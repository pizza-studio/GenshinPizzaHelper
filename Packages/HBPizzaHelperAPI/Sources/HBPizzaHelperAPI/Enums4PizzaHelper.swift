//
//  File.swift
//
//
//  Created by ShikiSuen on 2023/10/8.
//

import Defaults
import Foundation
import HBMihoyoAPI
import HoYoKit

// MARK: - EnkaResourceType

public enum EnkaResourceType: String {
    case affixes
    case characters
    case costumes
    case loc
    case namecards
    case pfps
    case honker_avatars
    case honker_characters
    case honker_meta
    case honker_ranks
    case honker_relics
    case honker_skills
    case honker_skilltree
    case honker_weps

    // MARK: Public

    public var json: String {
        rawValue.contains("honker_") ? "hsr/\(rawValue).json" : "\(rawValue).json"
    }

    public func subURLComponents(serverType: EnkaJSONGitServerType? = nil) -> String {
        serverType != nil ? "store/\(json)" : "api/players/\(json)"
    }
}

// MARK: - HostType

public enum HostType: String {
    case generalHost = "https://gi.pizzastudio.org/"
    case artifactRatingHost = "https://artifact-rating.pizzastudio.org/"
    case abyssHost = "http://81.70.76.222/"
    case enkaJSONGitCN = "https://gitcode.net/SHIKISUEN/Enka-API-docs/-/raw/master/"
    case enkaJSONGitGlobal = "https://raw.githubusercontent.com/EnkaNetwork/API-docs/master/"

    // MARK: Public

    public var hostBase: String { rawValue }
}

// MARK: - EnkaJSONGitServerType

public enum EnkaJSONGitServerType: Int {
    case global = 1
    case mainlandCN = 2
}

extension Server {
    public var jsonServer: EnkaJSONGitServerType {
        [.china, .bilibili].contains(self) ? .mainlandCN : .global
    }
}
