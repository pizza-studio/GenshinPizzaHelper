// (c) 2022 and onwards Pizza Studio (GPL v3.0 License).
// ====================
// This code is released under the GPL v3.0 License (SPDX-License-Identifier: GPL-3.0)

import Defaults

// MARK: - Local Query APIs.

#if !os(watchOS)
extension EnkaGI.EnkaDB {
    public func queryLocalizedNameForChar(
        id: String,
        officialNameOnly: Bool = false,
        fallbackValue: (() -> String)? = nil
    )
        -> String {
        guard let character = characters[id] else { return fallbackValue?() ?? "NULL-CHAR(\(id))" }
        let nameHash = character.NameTextMapHash
        let officialName = EnkaGI.Sputnik.sharedDB
            .locTable[nameHash.description] ?? fallbackValue?() ?? "NULL-LOC(\(id))"
        let realName = CharacterAsset(rawValue: Int(id) ?? -1)?.localized
            ?? WeaponAsset(rawValue: Int(id) ?? -1)?.localized
        return officialNameOnly ? officialName : realName ?? officialName
    }

    public func asyncOnMainAndForceUpdateEnkaDB() {
        isExpired = true
        Task.detached { @MainActor [self] in
            if let newDB = try? await EnkaGI.Sputnik.getEnkaDB() {
                update(new: newDB)
            }
        }
    }
}

#endif
