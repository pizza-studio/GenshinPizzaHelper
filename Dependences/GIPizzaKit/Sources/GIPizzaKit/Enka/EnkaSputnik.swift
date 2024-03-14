//
//  EnkaSputnik.swift
//
//
//  Created by ShikiSuen on 2023/10/18.
//

import Defaults
import Foundation

// MARK: - Enka Sputnik

#if !os(watchOS)
extension Enka {
    public class Sputnik {
        // MARK: Lifecycle

        private init() {}

        // MARK: Public

        public typealias CharLoc = Enka.CharacterLoc.LocDict
        public typealias CharMap = Enka.CharacterMap

        public struct DataSet {
            public let charLoc: CharLoc
            public let charMap: CharMap
        }

        public static let shared = Enka.Sputnik()

        public func resetLocalEnkaStorage() {
            Defaults.reset(.enkaMapLoc)
            Defaults.reset(.enkaMapCharacters)
        }

        public func getEnkaDataSet() async throws -> (charLoc: CharLoc, charMap: CharMap) {
            // Read charloc and charmap from UserDefault
            let storedCharLoc = try? JSONDecoder().decode(Enka.CharacterLoc.self, from: Defaults[.enkaMapLoc])
                .getLocalizedDictionary()
            let storedCharMap = try? JSONDecoder()
                .decode(Enka.CharacterMap.self, from: Defaults[.enkaMapCharacters])

            let enkaDataWrecked = storedCharLoc == nil || storedCharMap == nil || (storedCharLoc?.count ?? 0) *
                (storedCharMap?.count ?? 0) == 0
            if enkaDataWrecked { resetLocalEnkaStorage() }

            let enkaDataExpired = Calendar.current.date(
                byAdding: .hour,
                value: 2,
                to: Defaults[.lastEnkaDataCheckDate]
            )! < Date()

            let needUpdate = enkaDataWrecked || enkaDataExpired

            if !needUpdate, let storedCharLoc, let storedCharMap {
                return (storedCharLoc, storedCharMap)
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

                // save charLoc and charMap to UserDefault
                if let newMapLoc = try? await JSONEncoder().encode(charLocRaw) {
                    Defaults[.enkaMapLoc] = newMapLoc
                }

                if let newMapCharacters = try? await JSONEncoder().encode(charMapRaw) {
                    Defaults[.enkaMapCharacters] = newMapCharacters
                }

                Defaults[.lastEnkaDataCheckDate] = Date()

                return try await (charLocRaw.getLocalizedDictionary(), charMapRaw)
            }
        }
    }
}

// MARK: - Fetch Errors

extension Enka.Sputnik {
    public enum DataFetchError: Error {
        case charMapInvalid
        case charLocInvalid
    }
}

#endif
