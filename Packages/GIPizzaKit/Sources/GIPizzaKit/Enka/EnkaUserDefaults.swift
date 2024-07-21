// (c) 2022 and onwards Pizza Studio (GPL v3.0 License).
// ====================
// This code is released under the GPL v3.0 License (SPDX-License-Identifier: GPL-3.0)

import Defaults
import Foundation

#if !os(watchOS)
extension UserDefaults {
    public static let enkaSuite = UserDefaults(suiteName: "group.GenshinPizzaHelper.storageForEnka") ?? .opSuite
}

extension Defaults.Keys {
    public static let lastEnkaDataCheckDate = Key<Date>(
        "lastEnkaDataCheckDate",
        default: .init(timeIntervalSince1970: 0),
        suite: .enkaSuite
    )
    public static let enkaDBData = Key<EnkaGI.EnkaDB>(
        "enkaDBData",
        default: EnkaGI.EnkaDB(locTag: Locale.langCodeForEnkaAPI)!,
        suite: .enkaSuite
    )
    public static let queriedEnkaProfiles = Key<[String: EnkaGI.QueryRelated.ProfileRAW]>(
        "queriedEnkaProfiles",
        default: [:],
        suite: .enkaSuite
    )
}

extension EnkaGI.EnkaDB: _DefaultsSerializable {}

extension EnkaGI.QueryRelated.ProfileRAW: _DefaultsSerializable {}

#endif
