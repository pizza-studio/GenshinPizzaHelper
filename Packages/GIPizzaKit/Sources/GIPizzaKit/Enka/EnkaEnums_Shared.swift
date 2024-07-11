// (c) 2022 and onwards Pizza Studio (GPL v3.0 License).
// ====================
// This code is released under the GPL v3.0 License (SPDX-License-Identifier: GPL-3.0)

import Defaults
import Foundation
import HBMihoyoAPI
import HoYoKit

// MARK: - Enka.ResourceType

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

extension HoYoKit.Server {
    public var jsonServer: Enka.JSONGitServerType {
        [.china, .bilibili].contains(self) ? .mainlandCN : .global
    }
}
