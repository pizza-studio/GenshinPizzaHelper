//
//  File.swift
//
//
//  Created by ShikiSuen on 2023/10/18.
//

import Defaults
import Foundation
import HBMihoyoAPI

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
