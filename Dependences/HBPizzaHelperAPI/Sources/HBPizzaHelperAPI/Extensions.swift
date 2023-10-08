//
//  Extensions.swift
//
//
//  Created by Bill Haku on 2023/3/25.
//

import CommonCrypto
import CryptoKit
import Defaults
import Foundation

// MARK: - String

extension String {
    var localized: String {
        String(format: NSLocalizedString(self, comment: "namecards"))
    }
}

extension String {
    @available(iOS 15, watchOS 8, *)
    public func toAttributedString() -> AttributedString {
        let attributedString = try? AttributedString(markdown: self)
        return attributedString ?? ""
    }
}

extension String {
    /**
     - returns: the String, as an MD5 hash.
     */
    public var md5: String {
        let digest = Insecure.MD5.hash(data: Data(utf8))
        return digest.map {
            String(format: "%02hhx", $0)
        }.joined()
    }

    public var sha256: String {
        let digest = SHA256.hash(data: Data(utf8))
        return digest.map {
            String(format: "%02hhx", $0)
        }.joined()
    }
}

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
