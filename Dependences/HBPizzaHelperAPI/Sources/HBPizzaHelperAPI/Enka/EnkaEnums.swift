//
//  File.swift
//
//
//  Created by ShikiSuen on 2023/10/18.
//

import Defaults
import Foundation
import HBMihoyoAPI
import HoYoKit

extension Enka {
    // MARK: - Enka.ResourceType

    public enum ResourceType: String {
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

        public func subURLComponents(serverType: Enka.JSONGitServerType? = nil) -> String {
            serverType != nil ? "store/\(json)" : "api/players/\(json)"
        }
    }
}

// MARK: - Enka.JSONGitServerType

extension Enka {
    public enum JSONGitServerType: Int {
        case global = 1
        case mainlandCN = 2
    }
}

extension Server {
    public var jsonServer: Enka.JSONGitServerType {
        [.chinaMainland, .bilibili].contains(self) ? .mainlandCN : .global
    }
}
