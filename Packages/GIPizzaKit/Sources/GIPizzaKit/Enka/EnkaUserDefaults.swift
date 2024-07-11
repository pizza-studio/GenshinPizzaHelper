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
    public static let enkaMapLoc = Key<Data>(
        "enkaMapLoc",
        default: try! Data(contentsOf: Bundle.module.url(forResource: "loc", withExtension: "json")!),
        suite: .enkaSuite
    )
    public static let enkaMapCharacters = Key<Data>(
        "enkaMapLoc",
        default: try! Data(contentsOf: Bundle.module.url(forResource: "characters", withExtension: "json")!),
        suite: .enkaSuite
    )
}
#endif
