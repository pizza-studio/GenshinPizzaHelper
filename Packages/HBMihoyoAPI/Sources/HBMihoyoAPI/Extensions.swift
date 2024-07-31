//
//  Extensions.swift
//
//
//  Created by Bill Haku on 2023/3/25.
//

import CommonCrypto
import CryptoKit
import Foundation

// MARK: - String

extension String {
    var localized: String {
        String(format: NSLocalizedString(self, comment: "namecards"))
    }
}

extension String {
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

extension Locale {
    public static var langCodeForAPI: String {
        let bmpf = Bundle.main.preferredLocalizations.first
        let languageCode = bmpf ?? "en-us"
        print(languageCode)
        switch languageCode.prefix(2) {
        case "zh": return "zh-cn"
        case "ja": return "ja-jp"
        case "ru": return "ru-ru"
        case "en": return "en-us"
        default: return languageCode
        }
    }
}

extension Date {
    /// Create a new date from the current timezone.
    public init?(day: Int, month: Int, year: Int) {
        let month = max(1, min(12, month))
        let year = max(1965, min(9999, year))
        var day = max(1, min(31, day))
        var comps = DateComponents()
        comps.setValue(day, for: .day)
        comps.setValue(month, for: .month)
        comps.setValue(year, for: .year)
        let gregorian = Calendar(identifier: .gregorian)
        var date = gregorian.date(from: comps)
        while date == nil, day > 28 {
            day -= 1
            comps.setValue(day, for: .day)
            date = gregorian.date(from: comps)
        }
        guard let date = date else { return nil }
        self = date
    }
}
