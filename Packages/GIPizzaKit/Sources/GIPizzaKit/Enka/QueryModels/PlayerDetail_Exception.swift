// (c) 2022 and onwards Pizza Studio (GPL v3.0 License).
// ====================
// This code is released under the GPL v3.0 License (SPDX-License-Identifier: GPL-3.0)

import Foundation

extension EnkaGI.QueryRelated {
    public enum Exception: Error {
        case failToGetLocalizedDictionary
        case failToGetCharacterDictionary
        case failToGetCharacterData(message: String)
        case refreshTooFast(dateWhenRefreshable: Date)
    }
}
