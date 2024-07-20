// (c) 2022 and onwards Pizza Studio (GPL v3.0 License).
// ====================
// This code is released under the GPL v3.0 License (SPDX-License-Identifier: GPL-3.0)

import Foundation

// MARK: - Data Implementation

extension Data {
    public func parseAs<T: Decodable>(_ type: T.Type) throws -> T {
        try JSONDecoder().decode(T.self, from: self)
    }
}

extension Data? {
    public func parseAs<T: Decodable>(_ type: T.Type) throws -> T? {
        guard let this = self else { return nil }
        return try JSONDecoder().decode(T.self, from: this)
    }

    public func assertedParseAs<T: Decodable>(_ type: T.Type) throws -> T {
        try JSONDecoder().decode(T.self, from: self ?? .init([]))
    }
}
