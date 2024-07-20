// (c) 2022 and onwards Pizza Studio (GPL v3.0 License).
// ====================
// This code is released under the GPL v3.0 License (SPDX-License-Identifier: GPL-3.0)

import Defaults
import Foundation

// MARK: - Enka Sputnik

#if !os(watchOS)
extension EnkaGI {
    public enum Sputnik {
        public typealias CharLoc = EnkaGI.CharacterLoc.LocDict
        public typealias CharMap = EnkaGI.CharacterMap

        public struct DataSet {
            public let charLoc: CharLoc
            public let charMap: CharMap
        }

        public static var sharedDB: EnkaGI.EnkaDB = {
            let result = Defaults[.enkaDBData]
            return result
        }()

        public static func resetLocalEnkaStorage() {
            Defaults.reset(.enkaDBData)
        }

        public static func getEnkaDB(updateCheck: ((CharMap) -> Bool)? = nil) async throws
            -> EnkaDB {
            var enkaDataExpired = Calendar.current.date(
                byAdding: .hour,
                value: 2,
                to: Defaults[.lastEnkaDataCheckDate]
            )! < Date()

            if Locale.langCodeForEnkaAPI != sharedDB.langTag {
                enkaDataExpired = true
            }

            if let updateCheck = updateCheck, !updateCheck(sharedDB.characters) {
                enkaDataExpired = true
            }

            let needUpdate = enkaDataExpired

            if !needUpdate {
                return sharedDB
            } else {
                // fetch data
                async let charLocRaw = try await Task {
                    do {
                        return try await PizzaHelperAPI.fetchCharacterLocData(from: .mainlandCN)
                    } catch {
                        return try await PizzaHelperAPI.fetchCharacterLocData(from: .global)
                    }
                }.value
                async let charMapRaw = try await Task {
                    do {
                        return try await PizzaHelperAPI.fetchENCharacterDetailData(from: .mainlandCN)
                    } catch {
                        return try await PizzaHelperAPI.fetchENCharacterDetailData(from: .global)
                    }
                }.value

                let locTag = Locale.langCodeForEnkaAPI
                // save charLoc and charMap to UserDefault
                guard let newMapLoc = try await charLocRaw[locTag],
                      let newMapCharacters = try? await charMapRaw
                else {
                    throw EnkaGI.Exception
                        .enkaDBOnlineFetchFailure(details: "Language Tag Matching Error.")
                }

                let newDB = EnkaGI.EnkaDB(
                    locTag: locTag,
                    locTable: newMapLoc,
                    characters: newMapCharacters
                )

                Defaults[.enkaDBData] = newDB
                Self.sharedDB.update(new: newDB)
                Defaults[.lastEnkaDataCheckDate] = Date()

                return newDB
            }
        }
    }
}

// MARK: - Fetch Errors

extension EnkaGI.Sputnik {
    public enum DataFetchError: Error {
        case charMapInvalid
        case charLocInvalid
    }
}

#endif
