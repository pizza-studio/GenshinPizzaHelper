//
//  md5.swift
//  原神披萨小助手
//
//  Created by Bill Haku on 2022/8/6.
//  计算md5的扩展

import CryptoKit
import Foundation

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

extension Data {
    public var sha256: String {
        let digest = SHA256.hash(data: self)
        return digest.map {
            String(format: "%02hhx", $0)
        }.joined()
    }
}

extension Double {
    public func selfTimes(p: Int) -> Double {
        var res = self
        var x = p - 1
        while x > 0 {
            res *= res
            x -= 1
        }
        return res
    }
}

extension String {
    @available(iOS 15, *)
    public func toAttributedString() -> AttributedString {
        let attributedString = try? AttributedString(markdown: self)
        return attributedString ?? ""
    }
}
